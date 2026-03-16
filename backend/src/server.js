import sensible from '@fastify/sensible';
import cors from '@fastify/cors';
import jwt from '@fastify/jwt';
import fastify from 'fastify';
import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
const app = fastify({ logger: true });
app.register(cors, { origin: true });
app.register(jwt, { secret: 'KJ' });
app.register(sensible);
app.register(authRoutes);
app.register(userRoutes);
app.get('/health', async () => ({ status: 'ok' }));
const port = 3000;
app.listen({ port, host: '0.0.0.0' }, (err) => {
  if (err) {
    app.log.error(err);
    process.exit(1);
  }
});