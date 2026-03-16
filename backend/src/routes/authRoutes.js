import bcrypt from 'bcryptjs';
import { dbGet, dbRun } from '../db';
import { sendCode } from '../plugins/mailerPlugin';
function generateCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}
function expiresAt() {
  const minutes = 10;
  return Date.now() + minutes * 60 * 1000;
}
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
    const code = generateCode();
    dbRun(
      'INSERT INTO users (email, passwordHash, verificationCode, codeExpiresAt) VALUES (?, ?, ?, ?)',
      [email, passwordHash, code, expiresAt()]
    );
    await sendCode(email, 'KJ Verification Code', code);
    return reply.code(201).send({ message: 'Registered! Check Your Email For The Verification Code!' });
  });
  fastify.post('/auth/verify', {
    schema: {
      body: {
        type: 'object',
        required: ['email', 'code'],
        properties: {
          email: { type: 'string' },
          code: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { email, code } = request.body;
    const user = dbGet('SELECT * FROM users WHERE email = ?', [email]);
    if (!user) return reply.notFound('User Not Found!');
    if (user.isVerified) return reply.badRequest('Already Verified!');
    if (user.verificationCode !== code) return reply.badRequest('Invalid Code!');
    if (Date.now() > user.codeExpiresAt) return reply.badRequest('Code Expired!');
    dbRun('UPDATE users SET isVerified = 1, verificationCode = NULL, codeExpiresAt = NULL WHERE id = ?', [user.id]);
    const token = fastify.jwt.sign({ userId: user.id, email: user.email }, { expiresIn: '7d' });
    return { token, email: user.email };
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
    if (!user.isVerified) return reply.forbidden('Email Not Verified!');
    const token = fastify.jwt.sign({ userId: user.id, email: user.email }, { expiresIn: '7d' });
    return { token, email: user.email };
  });
  fastify.post('/auth/forgotPassword', {
    schema: {
      body: {
        type: 'object',
        required: ['email'],
        properties: { email: { type: 'string' } },
      },
    },
  }, async (request, reply) => {
    const { email } = request.body;
    const user = dbGet('SELECT id FROM users WHERE email = ?', [email]);
    if (!user) return reply.notFound('User Not Found!');
    const code = generateCode();
    dbRun('UPDATE users SET resetCode = ?, resetExpiresAt = ? WHERE id = ?', [code, expiresAt(), user.id]);
    await sendCode(email, 'KJ Password Reset Code', code);
    return { message: 'Reset Code Sent To Your Email!' };
  });
  fastify.post('/auth/resetPassword', {
    schema: {
      body: {
        type: 'object',
        required: ['email', 'code', 'newPassword'],
        properties: {
          email: { type: 'string' },
          code: { type: 'string' },
          newPassword: { type: 'string', minLength: 6 },
        },
      },
    },
  }, async (request, reply) => {
    const { email, code, newPassword } = request.body;
    const user = dbGet('SELECT * FROM users WHERE email = ?', [email]);
    if (!user) return reply.notFound('User Not Found!');
    if (user.resetCode !== code) return reply.badRequest('Invalid Reset Code!');
    if (Date.now() > user.resetExpiresAt) return reply.badRequest('Reset Code Expired!');
    const passwordHash = await bcrypt.hash(newPassword, 12);
    dbRun('UPDATE users SET passwordHash = ?, resetCode = NULL, resetExpiresAt = NULL WHERE id = ?', [passwordHash, user.id]);
    return { message: 'Password Reset Successfully!' };
  });
}
export default authRoutes;