 * 影视数据路由 — 从 MySQL 提供电影/电视剧数据
 */
const express = require('express');
const { pool } = require('../db');

const router = express.Router();

// GET /api/movies — 电影列表（分页 + 筛选 + 排序）
router.get('/', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const pageSize = parseInt(req.query.pageSize) || 20;
    const offset = (page - 1) * pageSize;
    const mediaType = req.query.type || 'movie';   // movie | tv
    const genre = req.query.genre || '';
    const year = req.query.year || '';
    const region = req.query.region || '';
    const sort = req.query.sort || 'popularity';

    let sql = 'SELECT * FROM movies WHERE media_type = ?';
    const params = [mediaType];

    if (genre) {
      sql += ' AND FIND_IN_SET(?, genre_ids) > 0';
      params.push(genre);
    }
    if (year) {
      sql += ' AND release_date LIKE ?';
      params.push(year + '%');
    }

    // 排序
    if (sort === 'vote_average') {
      sql += ' ORDER BY vote_average DESC';
    } else if (sort === 'release_date') {
      sql += ' ORDER BY release_date DESC';
    } else {
      sql += ' ORDER BY popularity DESC';
    }

    // 总数
    const countSql = sql.replace('SELECT *', 'SELECT COUNT(*) as total');
    const [countRows] = await pool.execute(countSql, params);
    const total = countRows[0].total;

    // 分页
    sql += ' LIMIT ? OFFSET ?';
    params.push(String(pageSize), String(offset));

    const [rows] = await pool.execute(sql, params);

    res.json({
      code: 0,
      data: rows,
      page: page,
      totalPages: Math.ceil(total / pageSize),
      totalResults: total
    });
  } catch (err) {
    console.error('Get movies error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// GET /api/movies/search?q=xxx — 搜索
router.get('/search', async (req, res) => {
  try {
    const q = req.query.q || '';
    const [rows] = await pool.execute(
      "SELECT * FROM movies WHERE title LIKE ? OR original_title LIKE ? LIMIT 50",
      ['%' + q + '%', '%' + q + '%']
    );
    res.json({ code: 0, data: rows });
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ code: 500, message: '搜索失败' });
  }
});

// GET /api/movies/today-updates — 今日更新剧集
router.get('/today-updates', async (_req, res) => {
  try {
    const [rows] = await pool.execute(
      "SELECT * FROM movies WHERE media_type = 'tv' AND status = 'Returning Series' ORDER BY popularity DESC LIMIT 8"
    );
    res.json({ code: 0, data: rows });
  } catch (err) {
    console.error('Today updates error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

// GET /api/movies/:id — 电影/电视剧详情
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM movies WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ code: 404, message: '影片不存在' });
    }

    const movie = rows[0];

    // 如果是电视剧，附加季信息
    if (movie.media_type === 'tv') {
      const [seasons] = await pool.execute(
        'SELECT * FROM seasons WHERE movie_id = ? ORDER BY season_number',
        [movie.id]
      );
      movie.seasons = seasons;

      // 下一集/上一集
      const [nextEp] = await pool.execute(
        'SELECT * FROM episodes WHERE movie_id = ? AND air_date >= CURDATE() ORDER BY air_date ASC LIMIT 1',
        [movie.id]
      );
      movie.nextEpisode = nextEp.length > 0 ? nextEp[0] : null;

      const [lastEp] = await pool.execute(
        'SELECT * FROM episodes WHERE movie_id = ? AND air_date < CURDATE() ORDER BY air_date DESC LIMIT 1',
        [movie.id]
      );
      movie.lastEpisode = lastEp.length > 0 ? lastEp[0] : null;
    }

    res.json({ code: 0, data: movie });
  } catch (err) {
    console.error('Get movie detail error:', err);
    res.status(500).json({ code: 500, message: '服务器错误' });
  }
});

module.exports = router;
