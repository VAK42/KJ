import bcrypt from 'bcryptjs';
import dbModule from '../db.js';
const { dbGet, dbRun } = dbModule;
async function authRoutes(fastify) {
  fastify.post('/auth/register', {
    schema: {
      body: {
        type: 'object',
        required: ['email', 'password'],
        properties: {
          email: { type: 'string', format: 'email' },
          password: { type: 'string', minLength: 6 },
        },
      },
    },
  }, async (request, reply) => {
    const { email, password } = request.body;
    const existing = dbGet('SELECT id FROM users WHERE email = ?', [email]);
    if (existing) return reply.conflict('Email Already Registered!');
    const passwordHash = await bcrypt.hash(password, 12);
    dbRun('INSERT INTO users (email, passwordHash) VALUES (?, ?)', [email, passwordHash]);
    const user = dbGet('SELECT * FROM users WHERE email = ?', [email]);
    const token = fastify.jwt.sign({ userId: user.id, email: user.email }, { expiresIn: '7d' });
    return reply.code(201).send({ token, email: user.email });
  });
  fastify.post('/auth/login', {
    schema: {
      body: {
        type: 'object',
        required: ['email', 'password'],
        properties: {
          email: { type: 'string' },
          password: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { email, password } = request.body;
    const user = dbGet('SELECT * FROM users WHERE email = ?', [email]);
    if (!user) return reply.unauthorized('Invalid Credentials!');
    const match = await bcrypt.compare(password, user.passwordHash);
    if (!match) return reply.unauthorized('Invalid Credentials!');
    const token = fastify.jwt.sign({ userId: user.id, email: user.email }, { expiresIn: '7d' });
    return { token, email: user.email };
  });
}
export default authRoutes;