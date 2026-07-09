# 观影追剧助手 - 项目分工说明

## 👥 开发人员

| 姓名 | 角色 | 负责模块 |
|------|------|----------|
| **江志鹏** | 数据/网络层 | 公开影视API、云数据库后端 |
| **涂子杰** | UI/导航层 | 页面导航、影视分类筛选、UI组件 |

---

## 📂 文件结构

### 江志鹏 — 数据/网络层

```
entry/src/main/ets/
├── api/
│   ├── MovieApi.ets        # 公开影视API（爱奇艺接口）
│   └── BackendApi.ets      # 云数据库API（HTTP请求后端）
└── model/
    └── MovieModel.ets      # 数据模型定义

server/                     # 后端服务（Express + MySQL + JWT）
├── app.js                  # 服务入口
├── db.js                   # 数据库连接与表结构
├── init-db.js              # 数据库初始化脚本
├── seed-movies.js          # 种子数据脚本
├── middleware/auth.js       # JWT认证中间件
├── routes/
│   ├── auth.js             # 注册/登录
│   ├── favorites.js        # 收藏接口
│   ├── watching.js         # 追剧接口
│   ├── reviews.js          # 评分接口
│   ├── history.js          # 观看历史接口
│   └── movies.js           # 影视数据接口
└── public/demo.mp4         # 演示视频
```

### 涂子杰 — UI/导航层

```
entry/src/main/ets/
├── pages/
│   ├── Index.ets            # 首页（推荐Tab + 收藏Tab + 我的Tab）
│   ├── MovieDetailPage.ets  # 影视详情页
│   ├── MovieListPage.ets    # 影视列表（含筛选排序）
│   ├── PlayerPage.ets       # 视频播放器
│   ├── LoginPage.ets        # 登录页
│   ├── RegisterPage.ets     # 注册页
│   ├── HistoryPage.ets      # 观看历史页
│   └── ReviewsPage.ets      # 评分列表页
├── components/
│   ├── FilterBar.ets        # 多维度筛选栏（类型/地区/年份/排序）
│   ├── MovieCard.ets        # 影视卡片组件
│   └── RatingBar.ets        # 评分组件（5星制）
├── viewmodel/
│   ├── MovieDetailViewModel.ets  # 详情页ViewModel
│   └── ProfileViewModel.ets      # 个人中心ViewModel
├── utils/
│   ├── AuthManager.ets      # 认证管理器
│   └── DateUtils.ets        # 日期工具
├── entryability/
│   ├── EntryAbility.ets     # 应用入口
│   └── EntryBackupAbility.ets # 备份恢复
```

---

## 🔗 数据流示意

```
涂子杰（UI）
  Pages/Components
    ↓ 调用
  ViewModel
    ↓ 调用
---------------
江志鹏（数据层）
  Api (MovieApi / BackendApi)
    ↓ HTTP
  server (Express + MySQL)
```
