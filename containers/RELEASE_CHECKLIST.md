# 📋 Docker Hub 发布检查列表

在将镜像发布到 Docker Hub 之前，请按照此检查列表确认所有步骤已完成。

---

## 🔧 1. 准备工作

### Docker Hub 账号

- [ ] 已在 https://hub.docker.com/ 注册账号
- [ ] 记录用户名：`______________`
- [ ] 生成了 Access Token
- [ ] 保存了 Access Token（安全位置）

### 本地环境

- [ ] Docker 版本 ≥ 19.03
  ```bash
  docker --version
  ```
- [ ] Docker buildx 可用
  ```bash
  docker buildx version
  ```
- [ ] 已登录 Docker Hub
  ```bash
  docker login
  ```

---

## 📝 2. 代码修改

### 替换用户名

在以下文件中，将 `gavinxia` 替换为你的 Docker Hub 用户名：

#### containers/build.sh

- [ ] 第 19 行：`DOCKER_USERNAME=${DOCKER_USERNAME:-"YOUR_USERNAME"}`

#### containers/docker-compose.yml

- [ ] 第 9 行：`image: YOUR_USERNAME/spec-workflow-mcp:latest`

#### .github/workflows/docker-publish.yml

- [ ] 第 16 行：`DOCKER_USERNAME: YOUR_USERNAME`

#### containers/example.mcp.json

- [ ] 第 9 行：`"YOUR_USERNAME/spec-workflow-mcp:latest"`

#### containers/README.md

- [ ] 所有 `gavinxia/spec-workflow-mcp` 替换为 `YOUR_USERNAME/spec-workflow-mcp`

#### containers/QUICK_REFERENCE.md

- [ ] 所有 `gavinxia` 替换为你的用户名

### 版本号

- [ ] 确认 `package.json` 中的版本号正确
  ```bash
  cat package.json | grep version
  ```

---

## 🔑 3. GitHub 配置

### GitHub Secret

- [ ] 进入 GitHub 仓库设置
  ```
  Settings → Secrets and variables → Actions
  ```
- [ ] 添加 Secret：
  - Name: `DOCKER_HUB_TOKEN`
  - Value: 你的 Docker Hub Access Token
- [ ] 验证 Secret 已添加成功

---

## 🧪 4. 本地测试

### 构建测试

- [ ] 本地构建成功
  ```bash
  cd containers
  ./build-local.sh
  ```
- [ ] 查看生成的镜像
  ```bash
  docker images spec-workflow-mcp
  ```

### 功能测试

- [ ] 测试基本运行
  ```bash
  docker run --rm spec-workflow-mcp:latest node -e "console.log('OK')"
  ```
- [ ] 测试 Pandoc
  ```bash
  docker run --rm spec-workflow-mcp:latest pandoc --version
  ```
- [ ] 测试 Dashboard
  ```bash
  docker run -d -p 3000:3000 \
    -v $(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \
    spec-workflow-mcp:latest
  # 访问 http://localhost:3000
  docker stop $(docker ps -q --filter ancestor=spec-workflow-mcp:latest)
  ```
- [ ] 测试 MCP 模式
  ```bash
  docker run --rm -i \
    -v $(pwd)/.spec-workflow:$(pwd)/.spec-workflow:rw \
    --entrypoint=node \
    spec-workflow-mcp:latest \
    /app/dist/index.js $(pwd)
  ```

---

## 🚀 5. 发布流程

### 选择发布方式

#### 方式 A：手动发布（推荐用于首次发布）

- [ ] 确认已登录 Docker Hub
  ```bash
  docker login
  ```
- [ ] 执行构建脚本
  ```bash
  cd containers
  ./build.sh 0.0.2  # 替换为实际版本号
  ```
- [ ] 等待构建完成（可能需要几分钟）
- [ ] 验证镜像已推送
  ```bash
  docker pull YOUR_USERNAME/spec-workflow-mcp:latest
  ```

#### 方式 B：GitHub Actions 自动发布（推荐用于后续发布）

- [ ] 确认 GitHub Secret 已配置
- [ ] 确认工作流文件已更新用户名
- [ ] 提交所有更改
  ```bash
  git add .
  git commit -m "feat: 添加 Docker Hub 支持"
  git push origin main
  ```
- [ ] 推送标签触发构建
  ```bash
  git tag v0.0.2
  git push origin v0.0.2
  ```
- [ ] 在 GitHub Actions 中监控构建进度
  ```
  GitHub → Actions → Docker Image CI/CD
  ```

---

## ✅ 6. 验证发布

### Docker Hub 验证

- [ ] 访问 Docker Hub 个人页面
  ```
  https://hub.docker.com/r/YOUR_USERNAME/spec-workflow-mcp
  ```
- [ ] 确认镜像已发布
- [ ] 检查标签是否正确（latest, x.y.z）
- [ ] 查看镜像大小是否合理（<500MB）

### 拉取测试

- [ ] 从 Docker Hub 拉取镜像
  ```bash
  docker pull YOUR_USERNAME/spec-workflow-mcp:latest
  ```
- [ ] 运行拉取的镜像
  ```bash
  docker run --rm YOUR_USERNAME/spec-workflow-mcp:latest node -e "console.log('OK')"
  ```

### 多架构验证

- [ ] 检查多架构支持
  ```bash
  docker manifest inspect YOUR_USERNAME/spec-workflow-mcp:latest
  ```
- [ ] 确认包含 amd64 和 arm64

---

## 📚 7. 文档更新

### 更新项目文档

- [ ] 更新主 README.md（如果需要）
- [ ] 添加 Docker 使用说明链接
- [ ] 更新版本号相关文档

### 创建发布说明

- [ ] 在 GitHub 创建 Release
  ```
  Releases → Draft a new release
  ```
- [ ] 填写版本号和更新日志
- [ ] 添加 Docker 使用说明

---

## 📢 8. 宣传推广（可选）

- [ ] 在项目 README 添加 Docker Hub badge
  ```markdown
  [![Docker Hub](https://img.shields.io/docker/v/YOUR_USERNAME/spec-workflow-mcp)](https://hub.docker.com/r/YOUR_USERNAME/spec-workflow-mcp)
  ```
- [ ] 更新 package.json 的 keywords
- [ ] 在社区分享（Twitter, Reddit, etc.）

---

## 🐛 9. 故障排查

如果遇到问题，请检查：

### 构建失败

- [ ] 检查 Docker 版本和 buildx
- [ ] 查看错误日志
- [ ] 确认网络连接正常

### 推送失败

- [ ] 确认已登录 Docker Hub
- [ ] 检查 Access Token 权限
- [ ] 验证镜像名称格式正确

### GitHub Actions 失败

- [ ] 检查 Secret 是否正确配置
- [ ] 查看 Actions 日志
- [ ] 确认工作流文件语法正确

---

## 📊 10. 监控和维护

### 定期检查

- [ ] 设置 Docker Hub webhook（可选）
- [ ] 监控镜像下载量
- [ ] 关注用户反馈和 Issues

### 安全更新

- [ ] 定期更新基础镜像
- [ ] 关注安全漏洞
- [ ] 及时发布修复版本

---

## 🎉 完成！

恭喜！你已经成功将 Spec-Workflow MCP 发布到 Docker Hub！

### 下一步

1. **测试使用**

   ```bash
   docker run -d -p 3000:3000 YOUR_USERNAME/spec-workflow-mcp:latest
   ```

2. **分享给用户**

   ```markdown
   使用 Docker 运行：
   docker pull YOUR_USERNAME/spec-workflow-mcp:latest
   ```

3. **持续改进**
   - 收集用户反馈
   - 优化镜像大小
   - 添加新特性

---

## 📞 需要帮助？

- **查看文档：** [DOCKER_HUB_GUIDE.md](./DOCKER_HUB_GUIDE.md)
- **示例脚本：** [examples/docker-examples.sh](./examples/docker-examples.sh)
- **快速参考：** [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
- **提交 Issue：** https://github.com/GavenXia/lls-spec-mcp/issues

---

**检查列表版本：** 1.0  
**最后更新：** 2025-01-16
