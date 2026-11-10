import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface MediaPoolAttributes {
  id: string;
  albumId: string;
  uploaderId: string;
  uploaderName: string;
  originalUrl: string;
  thumbUrl: string;
  width?: number | null;
  height?: number | null;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface MediaPoolCreationAttributes
  extends Optional<MediaPoolAttributes, 'id' | 'createdAt' | 'updatedAt' | 'width' | 'height'> {}

export class MediaPool extends Model<MediaPoolAttributes, MediaPoolCreationAttributes> implements MediaPoolAttributes {
  declare id: string;
  declare albumId: string;
  declare uploaderId: string;
  declare uploaderName: string;
  declare originalUrl: string;
  declare thumbUrl: string;
  declare width: number | null;
  declare height: number | null;

  declare readonly createdAt: Date;
  declare readonly updatedAt: Date;
}

export function initMediaPoolModel(): typeof MediaPool {
  MediaPool.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      albumId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      uploaderId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      uploaderName: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      originalUrl: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      thumbUrl: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      width: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      height: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
    },
    {
      sequelize,
      tableName: 'media_pool',
      timestamps: true,
    }
  );

  return MediaPool;
}
