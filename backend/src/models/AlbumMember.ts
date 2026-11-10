import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface AlbumMemberAttributes {
  id: string;
  albumId: string;
  userId: string;
  role: 'host' | 'editor' | 'viewer';
  joinedAt?: Date;
}

export interface AlbumMemberCreationAttributes extends Optional<AlbumMemberAttributes, 'id' | 'joinedAt'> {}

export class AlbumMember extends Model<AlbumMemberAttributes, AlbumMemberCreationAttributes> implements AlbumMemberAttributes {
  declare id: string;
  declare albumId: string;
  declare userId: string;
  declare role: 'host' | 'editor' | 'viewer';

  declare readonly joinedAt: Date;
}

export function initAlbumMemberModel(): typeof AlbumMember {
  AlbumMember.init(
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
      userId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      role: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: 'editor',
      },
    },
    {
      sequelize,
      tableName: 'album_members',
      timestamps: true,
      createdAt: 'joinedAt',
      updatedAt: false,
    }
  );

  return AlbumMember;
}
