import { Pool } from 'pg';
import { env } from '../config/env.js';
import { logger } from '../config/logger.js';

let _pool: Pool | null = null;

/**
 * Returns a singleton PostgreSQL connection pool.
 * Lazy-initialised on first call so the backend can boot
 * even when DATABASE_URL is unset (e.g. in early dev).
 */
export const getPool = (): Pool => {
  if (_pool) return _pool;

  if (!env.databaseUrl) {
    throw new Error('DATABASE_URL is not configured');
  }

  _pool = new Pool({
    connectionString: env.databaseUrl,
    // RDS supports SSL; we accept the server cert without root-CA validation
    // for now. Phase 11 will wire the official RDS CA bundle for verify-full.
    ssl: env.nodeEnv === 'production' ? { rejectUnauthorized: false } : false,
    max: 10,
    idleTimeoutMillis: 30_000,
    connectionTimeoutMillis: 5_000,
  });

  _pool.on('error', (err) => {
    logger.error({ err }, 'Unexpected error on idle PostgreSQL client');
  });

  logger.info('PostgreSQL pool initialised');
  return _pool;
};
