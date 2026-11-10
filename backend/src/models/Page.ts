import { DataTypes, Model, Optional } from 'sequelize';
import { sequelize } from '../config/database.js';

export interface PageAttributes {
  id: string;
  albumId: string;
  pageNumber: number;
  side: 'left' | 'right';
  layoutType: 'grid_4' | 'split_2' | 'single';
  createdAt?: Date;
  updatedAt?: Date;
}

export interface PageCreationAttributes
  extends Optional<PageAttributes, 'id' | 'createdAt' | 'updatedAt' | 'layoutType'> {}

export class Page extends Model<PageAttributes, PageCreationAttributes> implements PageAttributes {
  declare id: string;
  declare albumId: string;
  declare pageNumber: number;
  declare side: 'left' | 'right';
  declare layoutType: 'grid_4' | 'split_2' | 'single';

  declare readonly createdAt: Date;
  declare readonly updatedAt: Date;
}

export function initPageModel(): typeof Page {
  Page.init(
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
      pageNumber: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      side: {
        type: DataTypes.STRING(10),
        allowNull: false,
      },
      layoutType: {
        type: DataTypes.STRING(20),
        allowNull: false,
        defaultValue: 'grid_4',
      },
    },
    {
      sequelize,
      tableName: 'pages',
      timestamps: true,
    }
  );

  return Page;
}
