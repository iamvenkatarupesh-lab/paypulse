import type { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger.js';

export const notFoundHandler = (req: Request, res: Response) => {
  res.status(404).json({ error: 'Not found', path: req.path });
};

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
) => {
  logger.error({ err }, 'Unhandled error');
  res.status(500).json({ error: 'Internal server error' });
};
