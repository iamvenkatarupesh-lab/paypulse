import type { Request, Response } from 'express';

const stubPayments = [
  { id: 'pay_001', amount: 4999, currency: 'USD', status: 'succeeded' },
  { id: 'pay_002', amount: 12500, currency: 'USD', status: 'pending' },
];

export const listPayments = (_req: Request, res: Response) => {
  res.status(200).json({ data: stubPayments });
};

export const createPayment = (req: Request, res: Response) => {
  const { amount, currency = 'USD' } = req.body ?? {};
  if (typeof amount !== 'number' || amount <= 0) {
    return res
      .status(400)
      .json({ error: 'amount must be a positive number' });
  }
  return res.status(201).json({
    id: `pay_${Date.now()}`,
    amount,
    currency,
    status: 'pending',
    createdAt: new Date().toISOString(),
  });
};
