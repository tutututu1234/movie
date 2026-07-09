 * 用户收藏路由 — 仅收藏/取消收藏
 */
const express = require('express');
const { pool } = require('../db');
const { authMiddleware } = require('../middleware/auth');
const router = express.Router();

router.get('/', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM favorites WHERE user_id = ? ORDER BY add_time DESC',
      [req.userId]
    );
    res.json({ code: 0, message: 'success', data: rows });
  } catch (err) { res.status(500).json({ code: 500, message: '服务器错误' }); }
});

router.post('/', authMiddleware, async (req, res) => {
  try {
    const { movieId, movieTitle, posterPath, mediaType } = req.body;
    const [existing] = await pool.execute(
      'SELECT id FROM favorites WHERE user_id = ? AND movie_id = ?',
      [req.userId, movieId]
    );
    if (existing.length > 0) {
      return res.status(409).json({ code: 409, message: '已收藏' });
    }
    await pool.execute(
      'INSERT INTO favorites (user_id, movie_id, movie_title, poster_path, media_type, add_time) VALUES (?, ?, ?, ?, ?, ?)',
      [req.userId, movieId, movieTitle, posterPath, mediaType || 'movie', Date.now()]
    );
    res.json({ code: 0, message: '收藏成功' });
  } catch (err) { res.status(500).json({ code: 500, message: '服务器错误' }); }
});

router.delete('/:movieId', authMiddleware, async (req, res) => {
  try {
    await pool.execute('DELETE FROM favorites WHERE user_id = ? AND movie_id = ?',
      [req.userId, req.params.movieId]);
    res.json({ code: 0, message: '已取消收藏' });
  } catch (err) { res.status(500).json({ code: 500, message: '服务器错误' }); }
});

module.exports = router;
