import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

const dbDialect = process.env.DB_DIALECT || 'auto';
const dbUrl = process.env.DATABASE_URL || 'postgres://picpac_user:picpac_password@localhost:5432/picpac_db';

let sequelize: Sequelize;

export async function initDatabase(): Promise<Sequelize> {
  if (dbDialect === 'sqlite') {
    return createSqliteInstance();
  }

  try {
    sequelize = new Sequelize(dbUrl, {
      dialect: 'postgres',
      logging: false,
      dialectOptions: {
        connectTimeout: 2000,
      },
    });

    // Проверяем доступность PostgreSQL
    await sequelize.authenticate();
    console.log('✅ Успешное подключение к PostgreSQL 16 (picpac_db)');
    return sequelize;
  } catch (err: any) {
    if (dbDialect === 'auto') {
      console.warn('⚠️  PostgreSQL недоступен, переключаемся на локальную базу SQLite для разработки');
      return createSqliteInstance();
    }
    throw err;
  }
}

function createSqliteInstance(): Sequelize {
  const dbPath = path.resolve(process.cwd(), 'picpac_dev.sqlite');
  sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: dbPath,
    logging: false,
  });
  console.log(`✅ Инициализирована локальная SQLite база: ${dbPath}`);
  return sequelize;
}

export { sequelize };

