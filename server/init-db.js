/**
 * 数据库初始化脚本
 * 运行方式: node init-db.js
 */
const { initDatabase } = require('./db');

async function main() {
  console.log('正在初始化数据库...');
  try {
    await initDatabase();
    console.log('✅ 数据库初始化完成！');
    console.log('');
    console.log('现在可以启动服务: npm start');
    process.exit(0);
  } catch (err) {
    console.error('❌ 数据库初始化失败:', err.message);
    console.error('请确保:');
    console.error('  1. MySQL 服务已启动');
    console.error('  2. 修改 db.js 中的数据库连接配置');
    process.exit(1);
  }
}

main();
