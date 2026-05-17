import { Router } from 'express';
import {
  listPayments,
  createPayment,
} from '../controllers/payments.controller.js';

export const paymentsRouter = Router();
paymentsRouter.get('/payments', listPayments);
paymentsRouter.post('/payments', createPayment);
