# 微博内容计划（7 天）

## Day 1 - 2026-04-02

### 早上 8:30
【Git 实用技巧】

工作中常用的 5 个 Git 命令，提升效率：

1. git switch -c <branch> - 创建并切换新分支
2. git restore <file> - 撤销工作区修改
3. git log --oneline --graph - 查看简洁提交历史
4. git stash pop - 恢复暂存内容
5. git cherry-pick <commit> - 挑选特定提交

建议收藏，日常开发真的用得上！

#Git #开发工具 #程序员

### 晚上 20:00
【VS Code 效率插件】

分享几个我离不开的 VS Code 插件：

🔹 GitLens - Git 集成神器
🔹 Prettier - 代码格式化
🔹 Path Intellisense - 路径自动补全
🔹 Thunder Client - 轻量 API 测试
🔹 Error Lens - 错误即时显示

不用装太多，这几个足够提升日常编码体验。

#VSCode #编程 #效率工具

---

## Day 2 - 2026-04-03

### 早上 8:30
【Docker 入门要点】

新手学 Docker 记住这 3 个核心概念：

1️⃣ 镜像（Image）- 打包好的应用模板
2️⃣ 容器（Container）- 镜像的运行实例
3️⃣ Dockerfile - 构建镜像的脚本

常用命令：
- docker build -t myapp . 
- docker run -p 3000:3000 myapp
- docker ps / docker logs

容器化是必备技能，早学早受益。

#Docker #容器化 #DevOps

### 晚上 20:00
【API 设计最佳实践】

设计 RESTful API 的几个原则：

✅ 使用名词而非动词 /users 而非 /getUsers
✅ 用 HTTP 方法表达操作 GET/POST/PUT/DELETE
✅ 返回一致的错误格式
✅ 版本控制 /api/v1/users
✅ 分页参数 page&limit

好的 API 设计让前后端协作更顺畅。

#API #后端开发 #技术分享

---

## Day 3 - 2026-04-04

### 早上 8:30
【JavaScript 异步处理】

async/await 错误处理的最佳写法：

```javascript
// ❌ 不推荐
try {
  const data = await fetch()
  process(data)
} catch(e) {
  handleError(e)
}

// ✅ 推荐 - 分别处理
const [data, err] = await safeFetch()
if (err) return handleError(err)
process(data)
```

用 try-catch 包裹最小范围，错误定位更清晰。

#JavaScript #前端开发 #代码质量

### 晚上 20:00
【GitHub 优质项目推荐】

最近发现的实用开源项目：

📦 t3-env - 类型安全的环境变量
📦 shadcn/ui - 可复制的 UI 组件
📦 vite - 下一代前端构建工具
📦 prisma - 现代数据库 ORM

这些项目文档完善，代码质量高，值得学习参考。

#GitHub #开源 #技术栈

---

## Day 4 - 2026-04-05

### 早上 8:30
【数据库索引优化】

查询慢？先检查索引：

🔍 高频查询字段加索引
🔍 复合索引注意字段顺序
🔍 避免在索引列上做计算
🔍 定期分析慢查询日志

EXPLAIN 是你的好朋友，执行前先看执行计划。

索引不是越多越好，合适的才是最好的。

#数据库 #性能优化 #MySQL

### 晚上 20:00
【代码审查清单】

提交 PR 前自检：

□ 代码通过 lint 检查
□ 单元测试覆盖核心逻辑
□ 没有 console.log / debugger
□ 变量命名清晰
□ 添加了必要的注释
□ 更新了相关文档

好的 Code Review 从自检开始。

#代码审查 #工程实践 #团队协作

---

## Day 5 - 2026-04-06

### 早上 8:30
【HTTP 缓存策略】

理解浏览器缓存机制：

Cache-Control:
- max-age=3600 → 1 小时内使用本地缓存
- no-cache → 每次验证后再用
- no-store → 不缓存任何内容

ETag + Last-Modified 配合使用，减少不必要传输。

合理配置缓存，用户体验和服务器压力双赢。

#HTTP #Web 性能 #前端优化

### 晚上 20:00
【学习新技术的方法】

我的技术学习路径：

1. 官方文档通读核心概念
2. 跟着教程动手做 Demo
3. 阅读优秀开源项目源码
4. 在实际项目中应用
5. 总结输出博客/笔记

输入→实践→输出，形成闭环。

学而不思则罔，思而不学则殆。

#学习方法 #技术成长 #自我提升

---

## Day 6 - 2026-04-07

### 早上 8:30
【Linux 常用命令】

服务器调试必备命令：

top / htop - 查看系统资源
tail -f logs/app.log - 实时查看日志
grep "error" - 搜索关键字
netstat -tulpn - 查看端口占用
df -h / du -sh * - 磁盘空间分析

掌握这些，排查问题效率翻倍。

#Linux #运维 #服务器

### 晚上 20:00
【TypeScript 实用类型】

几个常用的 TS 工具类型：

Partial<T> - 全部属性可选
Required<T> - 全部属性必填
Pick<T, K> - 挑选部分属性
Omit<T, K> - 排除部分属性
ReturnType<T> - 获取函数返回类型

善用工具类型，减少重复定义。

#TypeScript #类型系统 #前端开发

---

## Day 7 - 2026-04-08

### 早上 8:30
【Git 分支策略】

推荐的分支工作流：

main - 生产环境代码
develop - 开发集成分支
feature/* - 功能开发
hotfix/* - 紧急修复
release/* - 发布准备

每个功能独立分支，Code Review 后合并。

清晰的分支管理让团队协作更顺畅。

#Git #工作流 #团队开发

### 晚上 20:00
【本周技术总结】

这周分享的内容回顾：

✅ Git 高效命令
✅ Docker 核心概念
✅ API 设计原则
✅ 异步错误处理
✅ 数据库索引优化
✅ HTTP 缓存策略
✅ TypeScript 工具类型

持续学习，每天进步一点点。

下周继续分享更多实战干货！

#技术总结 #学习打卡 #程序员
