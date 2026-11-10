import { Router } from 'express';
import { guestLogin } from '../controllers/auth.controller.js';

const router = Router();

router.post('/guest', guestLogin);

export default router;

