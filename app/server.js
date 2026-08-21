require('dotenv').config();
const path = require('path');
const express = require('express');
const pool = require('./db/connection');

const app = express();
const PORT = process.env.PORT || 3000;
const WA_NUMBER = process.env.WA_NUMBER || '6281234567890';
const CATEGORIES = ['kopi', 'non-kopi', 'snack', 'dessert'];

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

app.use((req, res, next) => {
  res.locals.formatRupiah = (num) => `Rp${Number(num).toLocaleString('id-ID')}`;
  res.locals.waLink = (menuName) =>
    `https://wa.me/${WA_NUMBER}?text=${encodeURIComponent(`Halo, saya mau pesan ${menuName}. Apakah masih tersedia?`)}`;
  res.locals.categories = CATEGORIES;
  next();
});

app.get('/', async (req, res, next) => {
  try {
    const [featured] = await pool.query(
      'SELECT * FROM menus WHERE is_available = TRUE ORDER BY id LIMIT 6'
    );
    const [countRows] = await pool.query('SELECT COUNT(*) AS total FROM menus WHERE is_available = TRUE');
    res.render('index', {
      featured,
      totalMenus: countRows[0].total,
    });
  } catch (err) {
    next(err);
  }
});

app.get('/search', async (req, res, next) => {
  try {
    const q = (req.query.q || '').trim();
    const category = (req.query.category || '').trim();

    let sql = 'SELECT * FROM menus WHERE is_available = TRUE';
    const params = [];

    if (q) {
      sql += ' AND (name LIKE ? OR description LIKE ?)';
      params.push(`%${q}%`, `%${q}%`);
    }
    if (category && CATEGORIES.includes(category)) {
      sql += ' AND category = ?';
      params.push(category);
    }
    sql += ' ORDER BY name ASC';

    const [results] = await pool.query(sql, params);
    res.render('search', { results, q, category });
  } catch (err) {
    next(err);
  }
});

app.use((req, res) => {
  res.status(404).send('Halaman tidak ditemukan');
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).send('Terjadi kesalahan pada server');
});

app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});
