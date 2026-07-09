 * JWT 认证中间件
 */
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'movie_tracker_jwt_secret_key_2026';
const JWT_EXPIRES_IN = '7d';

/**
 * 生成 JWT Token
 */
function generateToken(userId, username) {
  return jwt.sign(
    { userId: userId, username: username },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

/**
 * 验证 Token 中间件
 */
function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ code: 401, message: '未登录，请先登录' });
  }

  const token = authHeader.substring(7);
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    req.username = decoded.username;
    next();
  } catch (err) {
    return res.status(401).json({ code: 401, message: '登录已过期，请重新登录' });
  }
}

module.exports = { JWT_SECRET, generateToken, authMiddleware };
