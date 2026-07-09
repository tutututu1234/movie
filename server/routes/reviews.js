 * 用户评分与短评路由
 */
const express = require('express');
const { pool } = require('../db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /api/reviews - 获取所有评分
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM reviews WHERE user_id = ? ORDER BY update_time DESC',
      [req.userId]
    );
    res.json({ code: 0, message: 'success', data: rows });
  } catch (err) {
    console.error('Get reviews error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// GET /api/reviews/:movieId - 获取单个影片的评分
router.get('/:movieId', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM reviews WHERE user_id = ? AND movie_id = ?',
      [req.userId, req.params.movieId]
    );
    const review = rows.length > 0 ? rows[0] : null;
    res.json({ code: 0, message: 'success', data: review });
  } catch (err) {
    console.error('Get review error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// POST /api/reviews - 添加/更新评分
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { movieId, movieTitle, rating, review } = req.body;
    const now = Date.now();

    const [existing] = await pool.execute(
      'SELECT id FROM reviews WHERE user_id = ? AND movie_id = ?',
      [req.userId, movieId]
    );

    if (existing.length > 0) {
      await pool.execute(
        'UPDATE reviews SET rating = ?, review = ?, update_time = ? WHERE user_id = ? AND movie_id = ?',
        [rating || 0, review || '', now, req.userId, movieId]
      );
    } else {
      await pool.execute(
        'INSERT INTO reviews (user_id, movie_id, movie_title, rating, review, create_time, update_time) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [req.userId, movieId, movieTitle || '', rating || 0, review || '', now, now]
      );
    }

    res.json({ code: 0, message: '评分提交成功' });
  } catch (err) {
    console.error('Save review error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// DELETE /api/reviews/:movieId - 删除评分
router.delete('/:movieId', authMiddleware, async (req, res) => {
  try {
    await pool.execute(
      'DELETE FROM reviews WHERE user_id = ? AND movie_id = ?',
      [req.userId, req.params.movieId]
    );
    res.json({ code: 0, message: '已删除评分' });
  } catch (err) {
    console.error('Delete review error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

module.exports = router;
