import type { Request, Response } from 'express';
import { getPool } from '../db/pool.js';
import { logger } from '../config/logger.js';

/**
 * GET /api/db-health
 * Proves the backend can reach PostgreSQL with valid credentials.
 * Returns 200 + DB version on success, 503 + error message on failure.
 */
export const getDbHealth = async (_req: Request, res: Response): Promise<void> => {
  try {
    const pool = getPool();
    const result = await pool.query<{ now: Date; version: string }>(
      'SELECT NOW() AS now, version() AS version'
    );
    res.json({
      status: 'ok',
      now: result.rows[0].now,
      version: result.rows[0].version,
    });
  } catch (err) {
    logger.error({ err }, 'db-health check failed');
    res.status(503).json({
      status: 'error',
      message: err instanceof Error ? err.message : 'Database health check failed',
    });
  }
};
