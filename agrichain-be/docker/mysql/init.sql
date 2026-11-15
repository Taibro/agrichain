-- Initial MySQL database settings for supermarket_db
CREATE DATABASE IF NOT EXISTS supermarket_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- Application user privileges (agrichain_app is created by MYSQL_USER env)
GRANT ALL PRIVILEGES ON supermarket_db.* TO 'agrichain_app'@'%';
FLUSH PRIVILEGES;
