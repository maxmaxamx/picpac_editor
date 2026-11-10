import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface SlotReactionAttributes {
  id: string;
  slotId: string;
  userId: string;
  emoji: string;
  createdAt?: Date;
}

export interface SlotReactionCreationAttributes extends Optional<SlotReactionAttributes, 'id' | 'createdAt'> {}

export class SlotReaction extends Model<SlotReactionAttributes, SlotReactionCreationAttributes> implements SlotReactionAttributes {
  declare id: string;
  declare slotId: string;
  declare userId: string;
  declare emoji: string;

  declare readonly createdAt: Date;
}

export function initSlotReactionModel(): typeof SlotReaction {
  SlotReaction.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      slotId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      userId: {
        type: DataTypes.UUID,
        allowNull: false,
      },
      emoji: {
        type: DataTypes.STRING(10),
        allowNull: false,
      },
    },
    {
      sequelize,
      tableName: 'slot_reactions',
      timestamps: true,
      createdAt: true,
      updatedAt: false,
    }
  );

  return SlotReaction;
}
