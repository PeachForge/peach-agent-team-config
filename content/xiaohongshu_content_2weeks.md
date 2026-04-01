# 小红书内容计划（2 周）

---

## 第一篇 - 2026-04-02

### 标题：
零基础学 Docker，看这一篇就够了

### 正文：
容器化技术现在是开发者必备技能，今天用大白话给你讲清楚 Docker 的核心概念。

📌 三个核心概念

1. 镜像（Image）
就像是一个打包好的应用模板，包含了运行所需的所有依赖。可以理解为「安装包」。

2. 容器（Container）
镜像运行起来的实例。一个镜像可以运行多个容器，互相隔离。

3. Dockerfile
用来构建镜像的脚本文件，定义了镜像的组成。

📌 快速上手

安装 Docker 后，试试这些命令：

# 拉取镜像
docker pull nginx

# 运行容器
docker run -d -p 8080:80 nginx

# 查看运行中的容器
docker ps

# 查看日志
docker logs <container_id>

# 停止容器
docker stop <container_id>

📌 实战：打包自己的应用

创建一个 Dockerfile：

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

然后构建和运行：

```bash
docker build -t myapp .
docker run -p 3000:3000 myapp
```

📌 学习建议

1. 先理解概念，不要死记命令
2. 多动手实践，跑通第一个容器
3. 遇到问题看官方文档
4. 学习优秀项目的 Dockerfile 写法

💡 小结

Docker 让应用部署变得简单一致，「一次构建，到处运行」不是梦。

有问题评论区交流～

### 标签：
#Docker #程序员 #编程学习 #技术教程 #DevOps #容器化 #开发者 #自学编程

---

## 第二篇 - 2026-04-04

### 标题：
Git 这 5 个命令，让我效率翻倍

### 正文：
用了 5 年 Git，发现真正高频的就这几个命令。今天分享最实用的，建议收藏！

📌 1. git switch - 分支切换

```bash
# 创建并切换到新分支
git switch -c feature/login

# 切换回主分支
git switch main
```

比 git checkout 更语义化，不容易误操作。

📌 2. git restore - 撤销修改

```bash
# 撤销工作区的修改
git restore filename.js

# 撤销暂存的修改
git restore --staged filename.js
```

Git 2.23+ 的新命令，专门用来撤销，更安全。

📌 3. git log --oneline --graph - 查看历史

```bash
git log --oneline --graph --all
```

一行一个提交，带分支图，清晰直观。

📌 4. git stash - 临时保存

```bash
# 暂存当前修改
git stash

# 恢复暂存
git stash pop

# 查看暂存列表
git stash list
```

切换分支前不想提交？用 stash 临时保存。

📌 5. git cherry-pick - 挑选提交

```bash
git cherry-pick <commit_hash>
```

把某个特定提交「摘」到当前分支，适合 hotfix。

📌 Bonus: 配置别名

在 ~/.gitconfig 添加：

```ini
[alias]
    co = checkout
    br = branch
    st = status
    lg = log --oneline --graph
```

然后就可以 git st / git lg 了，更快捷！

📌 学习建议

- 理解每个命令的作用场景
- 先在测试仓库练习
- 常用命令形成肌肉记忆
- 了解原理，遇到问题不慌

💡 小结

工具用得好，下班下得早。这些命令日常开发真的够用了。

你还有哪些 Git 技巧？评论区分享～

### 标签：
#Git #程序员 #编程 #效率工具 #技术分享 #开发者 #代码管理 #工作技巧

---

## 第三篇 - 2026-04-07

### 标题：
API 设计避坑指南，后端开发必看

### 正文：
做了几年后端，踩过不少 API 设计的坑。今天总结几个关键原则，帮你少走弯路。

📌 1. 使用名词，不用动词

❌ /getUsers
❌ /createUser
✅ /users

HTTP 方法已经表达了操作意图：
- GET /users - 获取用户列表
- POST /users - 创建用户
- PUT /users/1 - 更新用户
- DELETE /users/1 - 删除用户

📌 2. 资源嵌套要适度

❌ /users/1/posts/2/comments/3
✅ /comments/3?post=2&user=1

嵌套过深难以维护，用查询参数更灵活。

📌 3. 统一的错误响应格式

```json
{
  "success": false,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "用户不存在",
    "details": {}
  }
}
```

前端处理起来更统一，调试也方便。

📌 4. 版本控制不能少

/api/v1/users
/api/v2/users

接口变更时，旧版本还能继续用，平滑过渡。

📌 5. 分页参数标准化

```
GET /users?page=1&limit=20
```

返回时带上总数：

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100
  }
}
```

📌 6. 合理的状态码

200 - 成功
201 - 创建成功
400 - 请求参数错误
401 - 未授权
403 - 禁止访问
404 - 资源不存在
500 - 服务器错误

别全都用 200，状态码本身就在传递信息。

📌 7. 文档！文档！文档！

用 Swagger/OpenAPI 自动生成文档，保持文档和代码同步。

💡 小结

好的 API 设计让前后端协作更顺畅，后期维护成本也低。

核心原则：清晰、一致、可扩展。

你设计 API 时有什么心得？欢迎交流～

### 标签：
#API 设计 #后端开发 #程序员 #技术教程 #RESTful #软件开发 #工程师 #编程

---

## 第四篇 - 2026-04-09

### 标题：
TypeScript 工具类型，让代码更优雅

### 正文：
TypeScript 内置了很多实用的工具类型，用好它们可以少写很多重复代码。

📌 Partial<T> - 全部属性可选

```typescript
interface User {
  id: number
  name: string
  email: string
}

// 更新用户时，可能只传部分字段
type UpdateUser = Partial<User>
// { id?: number; name?: string; email?: string }
```

📌 Required<T> - 全部属性必填

```typescript
// 配置项必须有所有字段
type Config = Required<PartialConfig>
```

📌 Pick<T, K> - 挑选部分属性

```typescript
// 只想要 id 和 name
type UserBasic = Pick<User, 'id' | 'name'>
// { id: number; name: string }
```

📌 Omit<T, K> - 排除部分属性

```typescript
// 不想要 password 字段
type UserPublic = Omit<User, 'password'>
```

📌 ReturnType<T> - 获取函数返回类型

```typescript
function createUser() {
  return { id: 1, name: 'Tom' }
}

type User = ReturnType<typeof createUser>
```

📌 Parameters<T> - 获取函数参数类型

```typescript
function greet(name: string, age: number) {}

type GreetParams = Parameters<typeof greet>
// [string, number]
```

📌 Record<K, T> - 键值对对象

```typescript
// 定义一个字符串键、数字值的对象
type ScoreMap = Record<string, number>
// { [key: string]: number }
```

📌 实战场景

```typescript
// 创建请求
type CreateUserRequest = Omit<User, 'id'>

// 更新请求
type UpdateUserRequest = Partial<Omit<User, 'id'>>

// 响应数据
type UserResponse = {
  success: boolean
  data: User
}

// 列表响应
type UserListResponse = {
  success: boolean
  data: User[]
  pagination: PaginationInfo
}
```

📌 学习建议

1. 先掌握常用的 5-6 个
2. 看源码理解实现原理
3. 在实际项目中应用
4. 不要过度使用，保持可读性

💡 小结

工具类型是 TypeScript 的利器，用好了代码质量提升明显。

建议收藏，写 TS 的时候随时查阅！

### 标签：
#TypeScript #前端开发 #程序员 #编程 #技术分享 #JavaScript #代码质量 #开发者

---

## 第五篇 - 2026-04-11

### 标题：
数据库查询慢？先检查这 5 点

### 正文：
线上遇到慢查询别慌，按这个排查流程走，90% 的问题都能解决。

📌 1. 开启慢查询日志

MySQL 配置：

```ini
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 1  # 超过 1 秒的记录
```

先知道哪些查询慢，才能针对性优化。

📌 2. 用 EXPLAIN 看执行计划

```sql
EXPLAIN SELECT * FROM users WHERE email = 'test@example.com';
```

重点关注：
- type: 是否用到索引（ALL 最差，ref/eq_ref 较好）
- key: 实际使用的索引
- rows: 扫描的行数
- Extra: 是否有 Using filesort/Using temporary

📌 3. 检查索引是否生效

```sql
-- 查看表的索引
SHOW INDEX FROM users;

-- 查看索引使用情况
SELECT * FROM sys.schema_unused_indexes;
```

常见问题：
- 查询条件字段没索引
- 复合索引字段顺序不对
- 索引列上做了计算或函数

📌 4. 避免常见陷阱

❌ SELECT * - 只查需要的字段
❌ WHERE name LIKE '%abc' - 前缀通配符无法用索引
❌ WHERE YEAR(created_at) = 2024 - 对索引列做计算
❌ OR 连接不同字段 - 可能导致索引失效

✅ WHERE name LIKE 'abc%'
✅ WHERE created_at >= '2024-01-01'

📌 5. 考虑查询优化

- 大表分页：用 id 范围代替 LIMIT offset
- 热点数据：加缓存（Redis）
- 复杂查询：拆分成多个简单查询
- 批量操作：用批量插入/更新

📌 实战案例

优化前（2.3 秒）：
```sql
SELECT * FROM orders 
WHERE DATE(created_at) = '2024-04-01'
ORDER BY amount DESC
LIMIT 20;
```

优化后（0.05 秒）：
```sql
SELECT * FROM orders 
WHERE created_at >= '2024-04-01 00:00:00'
  AND created_at < '2024-04-02 00:00:00'
ORDER BY amount DESC
LIMIT 20;
```

加了 created_at 索引，避免函数计算。

💡 小结

性能优化是个系统工程，索引只是其中一环。

核心思路：先测量，再优化；先索引，再架构。

有具体问题的可以评论区交流～

### 标签：
#数据库 #MySQL #性能优化 #后端开发 #程序员 #SQL #技术教程 #工程师

---

## 第六篇 - 2026-04-14

### 标题：
我的技术学习路径，从零到进阶

### 正文：
经常有人问怎么系统学习编程。分享我的学习方法，亲测有效。

📌 阶段一：打基础（1-3 个月）

目标：掌握一门语言的核心语法

做法：
1. 选一门主流语言（Python/JS/Java）
2. 找一套系统教程（视频/书）
3. 每天 2 小时，坚持写代码
4. 完成所有课后练习

推荐资源：
- freeCodeCamp - 免费互动教程
- Codecademy - 交互式学习
- 官方文档 - 最权威

📌 阶段二：做项目（3-6 个月）

目标：把知识用起来

做法：
1. 从简单项目开始（待办清单、博客）
2. 逐步增加复杂度
3. 学习使用 Git 版本控制
4. 部署到线上让别人访问

项目灵感：
- 个人博客/作品集
- 天气查询应用
- 记账小程序
- 爬虫工具

📌 阶段三：学框架（2-3 个月）

目标：掌握业界常用技术栈

前端：React/Vue + TypeScript
后端：Node.js/Spring/Django
数据库：MySQL/PostgreSQL + Redis

做法：
1. 跟着官方教程走一遍
2. 理解核心概念
3. 用框架重写之前的项目

📌 阶段四：读源码（持续）

目标：理解优秀代码怎么写

做法：
1. 选一个中等规模的开源项目
2. 从入口文件开始追踪
3. 画流程图帮助理解
4. 尝试贡献文档或修复 bug

推荐项目：
- axios - HTTP 客户端
- lodash - 工具函数库
- express - Web 框架

📌 阶段五：输出分享（持续）

目标：巩固知识，建立影响力

做法：
1. 写技术博客
2. 在 GitHub 分享项目
3. 参与技术社区讨论
4. 给开源项目提 PR

费曼学习法：能讲清楚才是真懂。

📌 我的日常学习节奏

工作日：
- 早上 30 分钟：读技术文章
- 晚上 1-2 小时：写代码/学新东西

周末：
- 3-4 小时：做项目/深入研究

碎片时间：
- 刷技术 Twitter/Reddit
- 听技术播客

📌 关键建议

✅ 动手比看书重要
✅ 项目驱动学习
✅ 遇到问题先自己查
✅ 加入技术社区
✅ 定期复盘总结
❌ 不要只看不练
❌ 不要追求完美再开始
❌ 不要同时学太多东西

💡 小结

学习编程是场马拉松，不是短跑。

保持好奇心，持续积累，时间会给你答案。

你在学什么？有什么困惑？评论区聊聊～

### 标签：
#编程学习 #程序员 #自学编程 #技术成长 #学习方法 #开发者 #职业规划 #自我提升
