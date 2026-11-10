import { Router } from 'express';
import authRoutes from './auth.routes.js';
import albumRoutes from './album.routes.js';

const apiRouter = Router();

apiRouter.use('/auth', authRoutes);
apiRouter.use('/albums', albumRoutes);

export default apiRouter;

