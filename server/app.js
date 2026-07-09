/**
 * 观影追剧助手 - 后端服务入口
 * Express + MySQL + JWT 认证
 */
const express = require('express');
const path = require('path');
const cors = require('cors');
const { initDatabase } = require('./db');

// 路由
const authRoutes = require('./routes/auth');
const favoritesRoutes = require('./routes/favorites');
const watchingRoutes = require('./routes/watching');
const reviewsRoutes = require('./routes/reviews');
const historyRoutes = require('./routes/history');

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use('/video', express.static(path.join(__dirname, 'public')));

// 请求日志
app.use((req, _res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// 根路由
app.get('/', (_req, res) => {
  res.json({
    name: '观影追剧助手 API',
    version: '1.0.0',
    endpoints: {
      'POST /api/auth/register': '注册',
      'POST /api/auth/login': '登录',
      'GET  /api/auth/profile': '用户信息',
      'GET  /api/favorites': '收藏列表',
      'POST /api/favorites': '添加收藏',
      'DELETE /api/favorites/:id': '取消收藏',
      'GET  /api/favorites/watching/list': '追剧列表',
      'PUT  /api/favorites/:id/progress': '更新进度',
      'GET  /api/reviews': '评分列表',
      'POST /api/reviews': '提交评分',
      'GET  /api/history': '观看历史',
      'POST /api/history': '添加记录',
      'GET  /api/history/last/record': '最近记录',
      'DELETE /api/history': '清除历史'
    }
  });
});

// 路由注册
app.use('/api/auth', authRoutes);
app.use('/api/favorites', favoritesRoutes);
app.use('/api/watching', watchingRoutes);
app.use('/api/reviews', reviewsRoutes);
app.use('/api/history', historyRoutes);

// 健康检查
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

// 启动服务
async function start() {
  try {
    // 初始化数据库
    await initDatabase();
    console.log('✅ 数据库初始化完成');

    app.listen(PORT, () => {
      console.log('═══════════════════════════════════');
      console.log(`  🎬 观影追剧助手后端已启动`);
      console.log(`  📡 端口: ${PORT}`);
      console.log(`  🌐 http://localhost:${PORT}`);
      console.log(`  📋 API 前缀: /api`);
      console.log('  ┌─────────────────────────────┐');
      console.log('  │ POST /api/auth/register     │ 注册');
      console.log('  │ POST /api/auth/login        │ 登录');
      console.log('  │ GET  /api/auth/profile      │ 用户信息');
      console.log('  │ GET  /api/favorites         │ 收藏列表');
      console.log('  │ POST /api/favorites         │ 添加收藏');
      console.log('  │ DEL  /api/favorites/:id     │ 取消收藏');
      console.log('  │ GET  /api/favorites/watching│ 追剧列表');
      console.log('  │ PUT  /api/favorites/progress│ 更新进度');
      console.log('  │ GET  /api/reviews           │ 评分列表');
      console.log('  │ POST /api/reviews           │ 提交评分');
      console.log('  │ GET  /api/history           │ 观看历史');
      console.log('  │ POST /api/history           │ 添加记录');
      console.log('  │ GET  /api/history/last      │ 最近记录');
      console.log('  └─────────────────────────────┘');
      console.log('═══════════════════════════════════');
    });
  } catch (err) {
    console.error('❌ 启动失败:', err.message);
    process.exit(1);
  }
}

start();
