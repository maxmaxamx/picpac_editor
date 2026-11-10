import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface CoverVoteAttributes {
  id: string;
  albumId: string;
  mediaId: string;
  userId: string;
  createdAt?: Date;
}

export interface CoverVoteCreationAttributes extends Optional<CoverVoteAttributes, 'id' | 'createdAt'> {}

export class CoverVote extends Model<CoverVoteAttributes, CoverVoteCreationAttributes> implements CoverVoteAttributes {
  declare id: string;
  declare albumId: string;
  declare mediaId: string;
  declare userId: string;

  declare readonly createdAt: Date;
}

export function initCoverVoteModel(): typeof CoverVote {
  CoverVote.init(
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
      mediaId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      userId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
    },
    {
      sequelize,
      tableName: 'cover_votes',
      timestamps: true,
      createdAt: true,
      updatedAt: false,
      indexes: [
        {
          unique: true,
          fields: ['albumId', 'userId'],
        },
      ],
    }
  );

  return CoverVote;
}
