import { Router } from 'express';
import multer from 'multer';
import {
  createAlbum,
  joinAlbum,
  getAlbumFull,
  assignSlotMedia,
  clearSlotMedia,
  updatePageLayout,
  getAlbumMedia,
  createOrder,
} from '../controllers/album.controller.js';
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
router.get('/:id/media', authMiddleware, getAlbumMedia);
router.post('/:id/media', authMiddleware, upload.single('file'), uploadMedia);
router.post('/:id/slots/:slotId/assign', authMiddleware, assignSlotMedia);
router.post('/:id/slots/:slotId/clear', authMiddleware, clearSlotMedia);
router.post('/:id/pages/:pageNumber/layout', authMiddleware, updatePageLayout);
router.post('/:id/checkout', authMiddleware, createOrder);

export default router;


