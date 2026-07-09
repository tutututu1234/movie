/**
 * MySQL 数据库连接与表结构初始化
 */
const mysql = require('mysql2/promise');

const dbConfig = {
  host: 'localhost', port: 3306, user: 'root',
  password: 'root', database: 'movie_tracker',
  waitForConnections: true, connectionLimit: 10, queueLimit: 0
};

const pool = mysql.createPool(dbConfig);

async function initDatabase() {
  const initPool = mysql.createPool({
    host: dbConfig.host, port: dbConfig.port,
    user: dbConfig.user, password: dbConfig.password
  });
  try {
    await initPool.execute(
      `CREATE DATABASE IF NOT EXISTS \`${dbConfig.database}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`
    );
    console.log('✅ 数据库已就绪:', dbConfig.database);
  } finally { await initPool.end(); }

  const tables = [
    { sql: `CREATE TABLE IF NOT EXISTS users (
      id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(50) NOT NULL UNIQUE,
      phone VARCHAR(11) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL,
      avatar VARCHAR(255) DEFAULT '', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`, name: 'users' },
    { sql: `CREATE TABLE IF NOT EXISTS favorites (
      id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL,
      movie_id BIGINT NOT NULL, movie_title VARCHAR(200) NOT NULL,
      poster_path VARCHAR(500) DEFAULT '', media_type VARCHAR(10) DEFAULT 'movie',
      add_time BIGINT NOT NULL, UNIQUE KEY uk_uf (user_id, movie_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`, name: 'favorites' },
    { sql: `CREATE TABLE IF NOT EXISTS watching (
      id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL,
      movie_id BIGINT NOT NULL, movie_title VARCHAR(200) NOT NULL,
      poster_path VARCHAR(500) DEFAULT '', media_type VARCHAR(10) DEFAULT 'tv',
      current_episode INT DEFAULT 0, current_season INT DEFAULT 1,
      total_episodes INT DEFAULT 0, watch_progress DECIMAL(5,2) DEFAULT 0,
      add_time BIGINT NOT NULL, UNIQUE KEY uk_uw (user_id, movie_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`, name: 'watching' },
    { sql: `CREATE TABLE IF NOT EXISTS reviews (
      id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL,
      movie_id BIGINT NOT NULL, movie_title VARCHAR(200) NOT NULL,
      rating DECIMAL(2,1) DEFAULT 0, review TEXT,
      create_time BIGINT NOT NULL, update_time BIGINT NOT NULL,
      UNIQUE KEY uk_ur (user_id, movie_id),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`, name: 'reviews' },
    { sql: `CREATE TABLE IF NOT EXISTS watch_history (
      id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL,
      movie_id BIGINT NOT NULL, movie_title VARCHAR(200) NOT NULL,
      poster_path VARCHAR(500) DEFAULT '', media_type VARCHAR(10) DEFAULT 'movie',
      episode_id BIGINT DEFAULT 0, episode_name VARCHAR(200) DEFAULT '',
      season_number INT DEFAULT 0, episode_number INT DEFAULT 0,
      watch_time INT DEFAULT 0, duration INT DEFAULT 0,
      progress DECIMAL(5,2) DEFAULT 0, last_watch_time BIGINT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4`, name: 'watch_history' }
  ];

  try {
    for (const t of tables) {
      await pool.execute(t.sql);
      console.log('✅ ' + t.name + ' 表已就绪');
    }
  } catch (err) {
    console.error('❌ 表初始化失败:', err.message);
    throw err;
  }
}

module.exports = { pool, initDatabase };
