import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface AlbumAttributes {
  id: string;
  inviteCode: string;
  title: string;
  hostUserId: string;
  format: 'square_20x20' | 'vertical_21x30';
  lamination: 'glossy' | 'grainy';
  totalSpreads: number;
  totalPages: number;
  winningCoverId?: string | null;
  status: 'draft' | 'voting' | 'locked' | 'ordered';
  copiesCount: number;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface AlbumCreationAttributes
  extends Optional<
    AlbumAttributes,
    | 'id'
    | 'createdAt'
    | 'updatedAt'
    | 'winningCoverId'
    | 'status'
    | 'copiesCount'
    | 'totalSpreads'
    | 'totalPages'
    | 'format'
    | 'lamination'
  > {}

export class Album extends Model<AlbumAttributes, AlbumCreationAttributes> implements AlbumAttributes {
  declare id: string;
  declare inviteCode: string;
  declare title: string;
  declare hostUserId: string;
  declare format: 'square_20x20' | 'vertical_21x30';
  declare lamination: 'glossy' | 'grainy';
  declare totalSpreads: number;
  declare totalPages: number;
  declare winningCoverId: string | null;
  declare status: 'draft' | 'voting' | 'locked' | 'ordered';
  declare copiesCount: number;

  declare readonly createdAt: Date;
  declare readonly updatedAt: Date;
}

export function initAlbumModel(): typeof Album {
  Album.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      inviteCode: {
        type: DataTypes.STRING(6),
        allowNull: false,
        unique: true,
      },
      title: {
        type: DataTypes.STRING(150),
        allowNull: false,
      },
      hostUserId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      format: {
        type: DataTypes.STRING(30),
        allowNull: false,
        defaultValue: 'vertical_21x30',
      },
      lamination: {
        type: DataTypes.STRING(30),
        allowNull: false,
        defaultValue: 'glossy',
      },
      totalSpreads: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 10,
      },
      totalPages: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 20,
      },
      winningCoverId: {
        type: DataTypes.UUID,
        allowNull: true,
      },
      status: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: 'draft',
      },
      copiesCount: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 1,
      },
    },
    {
      sequelize,
      tableName: 'albums',
      timestamps: true,
    }
  );

  return Album;
}
