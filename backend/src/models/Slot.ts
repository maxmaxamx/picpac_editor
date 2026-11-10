import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface SlotAttributes {
  id: string;
  pageId: string;
  slotIndex: number;
  mediaId?: string | null;
  caption?: string | null;
  authorName?: string | null;
  lockedByUserId?: string | null;
  lockedByName?: string | null;
  lockedUntil?: Date | null;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface SlotCreationAttributes
  extends Optional<
    SlotAttributes,
    | 'id'
    | 'createdAt'
    | 'updatedAt'
    | 'mediaId'
    | 'caption'
    | 'authorName'
    | 'lockedByUserId'
    | 'lockedByName'
    | 'lockedUntil'
  > {}

export class Slot extends Model<SlotAttributes, SlotCreationAttributes> implements SlotAttributes {
  declare id: string;
  declare pageId: string;
  declare slotIndex: number;
  declare mediaId: string | null;
  declare caption: string | null;
  declare authorName: string | null;
  declare lockedByUserId: string | null;
  declare lockedByName: string | null;
  declare lockedUntil: Date | null;

  declare readonly createdAt: Date;
  declare readonly updatedAt: Date;
}

export function initSlotModel(): typeof Slot {
  Slot.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      pageId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      slotIndex: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      mediaId: {
        type: DataTypes.UUID,
        allowNull: true,
      },
      caption: {
        type: DataTypes.STRING(50),
        allowNull: true,
      },
      authorName: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      lockedByUserId: {
        type: DataTypes.UUID,
        allowNull: true,
      },
      lockedByName: {
        type: DataTypes.STRING(100),
        allowNull: true,
      },
      lockedUntil: {
        type: DataTypes.DATE,
        allowNull: true,
      },
    },
    {
      sequelize,
      tableName: 'slots',
      timestamps: true,
    }
  );

  return Slot;
}
