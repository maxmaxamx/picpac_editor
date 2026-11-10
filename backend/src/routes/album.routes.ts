import { Router } from 'express';
import multer from 'multer';
import { createAlbum, joinAlbum, getAlbumFull } from '../controllers/album.controller.js';
import { uploadMedia } from '../controllers/media.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 15 * 1024 * 1024 }, // 15 MB limit
});

const router = Router();

router.post('/', authMiddleware, createAlbum);
router.post('/join', authMiddleware, joinAlbum);
router.get('/:id/full', authMiddleware, getAlbumFull);
router.post('/:id/media', authMiddleware, upload.single('file'), uploadMedia);

export default router;


