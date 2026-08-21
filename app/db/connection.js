require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'db',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'contoh_user',
  password: process.env.DB_PASSWORD || 'contoh_password',
  database: process.env.DB_NAME || 'contoh_db',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;
