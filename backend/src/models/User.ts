import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface UserAttributes {
  id: string;
  displayName: string;
  avatarColor: string;
  avatarUrl?: string | null;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface UserCreationAttributes extends Optional<UserAttributes, 'id' | 'createdAt' | 'updatedAt' | 'avatarUrl'> {}

export class User extends Model<UserAttributes, UserCreationAttributes> implements UserAttributes {
  declare id: string;
  declare displayName: string;
  declare avatarColor: string;
  declare avatarUrl: string | null;

  declare readonly createdAt: Date;
  declare readonly updatedAt: Date;
}

export function initUserModel(): typeof User {
  User.init(
    {
      id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
      },
      displayName: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      avatarColor: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: '#FF4D4D',
      },
      avatarUrl: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
    },
    {
      sequelize,
      tableName: 'users',
      timestamps: true,
    }
  );

  return User;
}
