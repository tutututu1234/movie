 * 用户认证路由 - 手机号登录 / 注册
 */
const express = require('express');
const bcrypt = require('bcryptjs');
const { pool } = require('../db');
const { generateToken, authMiddleware } = require('../middleware/auth');

const router = express.Router();

// POST /api/auth/register - 注册
router.post('/register', async (req, res) => {
  try {
    const { username, phone, password } = req.body;

    if (!username || !phone || !password) {
      return res.status(400).json({ code: 400, message: '用户名、手机号和密码不能为空' });
    }
    if (username.length < 2 || username.length > 20) {
      return res.status(400).json({ code: 400, message: '用户名长度应在2-20个字符之间' });
    }
    if (!/^1[3-9]\d{9}$/.test(phone)) {
      return res.status(400).json({ code: 400, message: '请输入正确的手机号' });
    }
    if (password.length < 6 || password.length > 30) {
      return res.status(400).json({ code: 400, message: '密码长度应在6-30个字符之间' });
    }

    const [existing] = await pool.execute(
      'SELECT id FROM users WHERE username = ? OR phone = ?',
      [username, phone]
    );
    if (existing.length > 0) {
      return res.status(409).json({ code: 409, message: '用户名或手机号已被注册' });
    }

    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    const [result] = await pool.execute(
      'INSERT INTO users (username, phone, password_hash) VALUES (?, ?, ?)',
      [username, phone, passwordHash]
    );

    const token = generateToken(result.insertId, username);

    res.json({
      code: 0,
      message: '注册成功',
      data: {
        userId: result.insertId,
        username: username,
        phone: phone,
        token: token
      }
    });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ code: 500, message: '服务器内部错误' });
  }
});

// POST /api/auth/login - 登录
router.post('/login', async (req, res) => {
  try {
    const { phone, password } = req.body;

    if (!phone || !password) {
      return res.status(400).json({ code: 400, message: '手机号和密码不能为空' });
    }

    const [users] = await pool.execute(
      'SELECT id, username, phone, password_hash, avatar FROM users WHERE phone = ?',
      [phone]
    );

    if (users.length === 0) {
      return res.status(401).json({ code: 401, message: '手机号或密码错误' });
    }

    const user = users[0];
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({ code: 401, message: '手机号或密码错误' });
    }

    const token = generateToken(user.id, user.username);

    res.json({
      code: 0,
      message: '登录成功',
      data: {
        userId: user.id,
        username: user.username,
        phone: user.phone,
        avatar: user.avatar,
        token: token
      }
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ code: 500, message: '服务器内部错误' });
  }
});

// GET /api/auth/profile - 获取当前用户信息
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const [users] = await pool.execute(
      'SELECT id, username, phone, avatar, created_at FROM users WHERE id = ?',
      [req.userId]
    );

    if (users.length === 0) {
      return res.status(404).json({ code: 404, message: '用户不存在' });
    }

    const user = users[0];
    res.json({
      code: 0,
      message: 'success',
      data: {
        userId: user.id,
        username: user.username,
        phone: user.phone,
        avatar: user.avatar
      }
    });
  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ code: 500, message: '服务器内部错误' });
  }
});

module.exports = router;
