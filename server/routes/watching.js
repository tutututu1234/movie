 * 追剧路由 — 独立于收藏
 */
const express = require('express');
const { pool } = require('../db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// GET /api/watching - 获取追剧列表
router.get('/', authMiddleware, async (req, res) => {
  try {
    const [rows] = await pool.execute(
      'SELECT * FROM watching WHERE user_id = ? ORDER BY add_time DESC',
      [req.userId]
    );
    res.json({ code: 0, message: 'success', data: rows });
  } catch (err) {
    console.error('Get watching error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// POST /api/watching - 添加追剧
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { movieId, movieTitle, posterPath, mediaType, totalEpisodes } = req.body;
    const addTime = Date.now();

    const [existing] = await pool.execute(
      'SELECT id FROM watching WHERE user_id = ? AND movie_id = ?',
      [req.userId, movieId]
    );
    if (existing.length > 0) {
      return res.status(409).json({ code: 409, message: '已在追剧列表中' });
    }

    await pool.execute(
      `INSERT INTO watching (user_id, movie_id, movie_title, poster_path, media_type, total_episodes, add_time)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [req.userId, movieId, movieTitle, posterPath, mediaType || 'tv', totalEpisodes || 0, addTime]
    );
    res.json({ code: 0, message: '已添加追剧' });
  } catch (err) {
    console.error('Add watching error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// DELETE /api/watching/:movieId - 取消追剧
router.delete('/:movieId', authMiddleware, async (req, res) => {
  try {
    await pool.execute('DELETE FROM watching WHERE user_id = ? AND movie_id = ?',
      [req.userId, req.params.movieId]);
    res.json({ code: 0, message: '已取消追剧' });
  } catch (err) {
    console.error('Delete watching error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// PUT /api/watching/:movieId - 更新追剧进度
router.put('/:movieId', authMiddleware, async (req, res) => {
  try {
    const { currentEpisode, currentSeason, watchProgress } = req.body;
    const sets = [];
    const vals = [];
    if (currentEpisode !== undefined) { sets.push('current_episode = ?'); vals.push(currentEpisode); }
    if (currentSeason !== undefined) { sets.push('current_season = ?'); vals.push(currentSeason); }
    if (watchProgress !== undefined) { sets.push('watch_progress = ?'); vals.push(watchProgress); }
    if (sets.length === 0) {
      return res.json({ code: 0, message: '无需更新' });
    }
    vals.push(req.userId, req.params.movieId);
    await pool.execute(
      `UPDATE watching SET ${sets.join(', ')} WHERE user_id = ? AND movie_id = ?`,
      vals
    );
    res.json({ code: 0, message: '进度已更新' });
  } catch (err) {
    console.error('Update watching error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

module.exports = router;
