import dbModule from '../db.js';
const { dbAll, dbRun } = dbModule;
async function userRoutes(fastify) {
  fastify.addHook('preHandler', async (request, reply) => {
    try {
      await request.jwtVerify();
    } catch {
      reply.unauthorized('Invalid Or Expired Token!');
    }
  });
  fastify.get('/user/quizResults', async (request) => {
    return dbAll('SELECT * FROM quizResults WHERE userId = ? ORDER BY date DESC', [request.user.userId]);
  });
  fastify.post('/user/quizResults', {
    schema: {
      body: {
        type: 'object',
        required: ['level', 'score', 'total', 'date'],
        properties: {
          level: { type: 'string' },
          score: { type: 'integer' },
          total: { type: 'integer' },
          date: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { level, score, total, date } = request.body;
    dbRun(
      'INSERT INTO quizResults (userId, level, score, total, date) VALUES (?, ?, ?, ?, ?)',
      [request.user.userId, level, score, total, date]
    );
    return reply.code(201).send({ message: 'Quiz Result Saved!' });
  });
}
export default userRoutes;