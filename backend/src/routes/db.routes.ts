import { Router } from 'express';
import { getDbHealth } from '../controllers/db.controller.js';

export const dbRouter = Router();

dbRouter.get('/db-health', getDbHealth);
