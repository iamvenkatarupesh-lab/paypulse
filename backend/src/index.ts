import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import pinoHttp from 'pino-http';

import { env } from './config/env.js';
import { logger } from './config/logger.js';
import { healthRouter } from './routes/health.routes.js';
import { paymentsRouter } from './routes/payments.routes.js';
import {
  errorHandler,
  notFoundHandler,
} from './middleware/error.middleware.js';

const app = express();

// Security & infrastructure middleware
app.use(helmet());
app.use(cors({ origin: env.corsOrigin }));
app.use(express.json({ limit: '1mb' }));
app.use(pinoHttp({ logger }));

// Routes
app.use('/', healthRouter); // GET /health
app.use('/api', paymentsRouter); // /api/payments

// 404 + error handlers (must be LAST)
app.use(notFoundHandler);
app.use(errorHandler);

const server = app.listen(env.port, () => {
  logger.info(`PayPulse backend listening on port ${env.port}`);
});

// Graceful shutdown
const shutdown = (signal: string) => {
  logger.info(`Received ${signal}, shutting down gracefully`);
  server.close(() => {
    logger.info('HTTP server closed');
    process.exit(0);
  });
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
