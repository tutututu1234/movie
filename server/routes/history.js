 * 观看历史路由
 */
const express = require('express');
const { pool } = require('../db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /api/history - 获取所有观看历史
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM watch_history WHERE user_id = ? ORDER BY last_watch_time DESC',
      [req.userId]
    );
    res.json({ code: 0, message: 'success', data: rows });
  } catch (err) {
    console.error('Get history error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// GET /api/history/last - 获取最近一次观看记录
router.get('/last/record', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM watch_history WHERE user_id = ? ORDER BY last_watch_time DESC LIMIT 1',
      [req.userId]
    );
    const record = rows.length > 0 ? rows[0] : null;
    res.json({ code: 0, message: 'success', data: record });
  } catch (err) {
    console.error('Get last history error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// POST /api/history - 添加观看记录
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { movieId, movieTitle, posterPath, mediaType, episodeId, episodeName,
      seasonNumber, episodeNumber, watchTime, duration, progress } = req.body;

    // 先删除同一影片的旧记录
    await pool.execute(
      'DELETE FROM watch_history WHERE user_id = ? AND movie_id = ?',
      [req.userId, movieId]
    );

    const lastWatchTime = Date.now();
    await pool.execute(
      `INSERT INTO watch_history (user_id, movie_id, movie_title, poster_path, media_type,
        episode_id, episode_name, season_number, episode_number,
        watch_time, duration, progress, last_watch_time)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [req.userId, movieId, movieTitle || '', posterPath || '', mediaType || 'movie',
        episodeId || 0, episodeName || '', seasonNumber || 0, episodeNumber || 0,
        watchTime || 0, duration || 0, progress || 0, lastWatchTime]
    );

    res.json({ code: 0, message: '记录成功' });
  } catch (err) {
    console.error('Add history error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// DELETE /api/history - 清除观看历史
router.delete('/', authMiddleware, async (req, res) => {
  try {
    await pool.execute('DELETE FROM watch_history WHERE user_id = ?', [req.userId]);
    res.json({ code: 0, message: '历史已清除' });
  } catch (err) {
    console.error('Clear history error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

module.exports = router;
