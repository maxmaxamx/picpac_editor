import { User, initUserModel } from './User.js';
import { Album, initAlbumModel } from './Album.js';
import { AlbumMember, initAlbumMemberModel } from './AlbumMember.js';
import { Page, initPageModel } from './Page.js';
import { Slot, initSlotModel } from './Slot.js';
import { MediaPool, initMediaPoolModel } from './MediaPool.js';
import { SlotReaction, initSlotReactionModel } from './SlotReaction.js';
import { CoverVote, initCoverVoteModel } from './CoverVote.js';
import { sequelize } from '../config/database.js';

export function setupModels() {
  initUserModel();
  initAlbumModel();
  initAlbumMemberModel();
  initPageModel();
  initSlotModel();
  initMediaPoolModel();
  initSlotReactionModel();
  initCoverVoteModel();

  // Связи моделей (Associations)
  Album.hasMany(Page, { foreignKey: 'albumId', as: 'pages', onDelete: 'CASCADE' });
  Page.belongsTo(Album, { foreignKey: 'albumId', as: 'album' });

  Page.hasMany(Slot, { foreignKey: 'pageId', as: 'slots', onDelete: 'CASCADE' });
  Slot.belongsTo(Page, { foreignKey: 'pageId', as: 'page' });

  Slot.belongsTo(MediaPool, { foreignKey: 'mediaId', as: 'media' });
  MediaPool.hasMany(Slot, { foreignKey: 'mediaId', as: 'slots' });

  Slot.hasMany(SlotReaction, { foreignKey: 'slotId', as: 'reactions', onDelete: 'CASCADE' });
  SlotReaction.belongsTo(Slot, { foreignKey: 'slotId', as: 'slot' });

  Album.hasMany(MediaPool, { foreignKey: 'albumId', as: 'mediaPool', onDelete: 'CASCADE' });
  MediaPool.belongsTo(Album, { foreignKey: 'albumId', as: 'album' });

  Album.hasMany(CoverVote, { foreignKey: 'albumId', as: 'coverVotes', onDelete: 'CASCADE' });
  CoverVote.belongsTo(Album, { foreignKey: 'albumId', as: 'album' });

  Album.hasMany(AlbumMember, { foreignKey: 'albumId', as: 'members', onDelete: 'CASCADE' });
  AlbumMember.belongsTo(Album, { foreignKey: 'albumId', as: 'album' });

  AlbumMember.belongsTo(User, { foreignKey: 'userId', as: 'user' });
}

export {
  sequelize,
  User,
  Album,
  AlbumMember,
  Page,
  Slot,
  MediaPool,
  SlotReaction,
  CoverVote,
};

