# Docker Hub 发布配置总结

## 📦 已完成的工作

本次更新为 Spec-Workflow MCP 添加了完整的 Docker 支持和 Docker Hub 发布流程。

### 1. 优化的 Dockerfile

**文件：** `containers/Dockerfile`

**改进：**

- ✅ 多阶段构建优化镜像大小
- ✅ 多架构支持（amd64 + arm64）
- ✅ 添加 OCI 标准元数据标签
- ✅ 使用非 root 用户运行（安全性）
- ✅ 添加健康检查
- ✅ 使用 tini 作为 init 系统
- ✅ 优化构建缓存和层顺序

**镜像大小：** 约 200-300MB

### 2. 构建脚本

#### 2.1 生产构建脚本

**文件：** `containers/build.sh`

**功能：**

- 多架构构建（linux/amd64, linux/arm64）
- 自动从 package.json 读取版本号
- 自动添加 latest 标签
- 构建验证
- 友好的进度提示
- 直接推送到 Docker Hub

**使用：**

```bash
cd containers
./build.sh         # 使用 package.json 版本
./build.sh 0.0.2   # 指定版本
```

#### 2.2 本地测试脚本

**文件：** `containers/build-local.sh`

**功能：**

- 仅本地构建，不推送
- 单架构（当前平台）
- 快速测试验证
- 提供测试命令示例

**使用：**

```bash
cd containers
./build-local.sh
```

### 3. 自动化 CI/CD

**文件：** `.github/workflows/docker-publish.yml`

**功能：**

- 自动多架构构建
- 版本标签管理（latest, edge, x.y.z）
- 镜像漏洞扫描
- 生成 SBOM（软件物料清单）
- 自动更新 Docker Hub 描述
- 构建缓存加速

**触发条件：**

- 推送标签（v*.*.\*）
- 推送到 main 分支
- 手动触发

### 4. Docker Compose 配置

**文件：** `containers/docker-compose.yml`

**改进：**

- 使用 Docker Hub 镜像
- 完整的资源限制配置
- 健康检查配置
- 网络隔离
- 环境变量管理

**使用：**

```bash
SPEC_WORKFLOW_PATH=$(pwd) docker-compose up -d
```

### 5. 优化的 .dockerignore

**文件：** `.dockerignore`

**功能：**

- 排除不必要的文件
- 减小构建上下文
- 加快构建速度
- 优化镜像大小

### 6. 文档

#### 6.1 完整的发布指南

**文件：** `containers/DOCKER_HUB_GUIDE.md`

**内容：**

- Docker Hub 准备工作
- 手动构建和发布流程
- 自动化 CI/CD 配置
- 使用方法和示例
- 版本标签策略
- 故障排查

#### 6.2 使用示例

**文件：** `containers/examples/docker-examples.sh`

**包含 10+ 种使用场景：**

1. 拉取镜像
2. 运行 Dashboard
3. MCP 服务器模式
4. Docker Compose
5. 自定义端口
6. 资源限制
7. 多项目支持
8. 健康检查和日志
9. 容器调试
10. 备份和恢复

#### 6.3 更新的 README

**文件：** `containers/README.md`

**改进：**

- 添加 Docker Hub badges
- 清晰的快速开始指南
- 链接到完整文档

### 7. MCP 客户端配置示例

**文件：** `containers/example.mcp.json`

**改进：**

- 使用 Docker Hub 镜像名
- 使用 workspaceFolder 变量
- 路径映射一致性

---

## 🚀 发布到 Docker Hub 的步骤

### 准备工作

1. **创建 Docker Hub 账号**

   - 访问 https://hub.docker.com/
   - 注册账号
   - 记录用户名

2. **生成 Access Token**

   - Docker Hub → Account Settings → Security
   - 生成新的 Access Token
   - 保存 Token（只显示一次）

3. **配置 GitHub Secret**
   - GitHub 仓库 → Settings → Secrets
   - 添加 `DOCKER_HUB_TOKEN`
   - 值为刚才的 Access Token

### 方式 1：手动发布（推荐用于测试）

```bash
# 1. 登录 Docker Hub
docker login -u YOUR_USERNAME

# 2. 修改构建脚本中的用户名
# 编辑 containers/build.sh
# DOCKER_USERNAME="YOUR_USERNAME"

# 3. 构建并推送
cd containers
./build.sh 0.0.2
```

### 方式 2：GitHub Actions 自动发布（推荐用于生产）

```bash
# 1. 确保已配置 GitHub Secret

# 2. 更新工作流配置
# 编辑 .github/workflows/docker-publish.yml
# env:
#   DOCKER_USERNAME: YOUR_USERNAME

# 3. 推送标签触发构建
git tag v0.0.2
git push origin v0.0.2

# 或推送到 main 分支
git push origin main
```

### 验证发布

```bash
# 1. 拉取镜像
docker pull YOUR_USERNAME/spec-workflow-mcp:latest

# 2. 运行测试
docker run -it --rm YOUR_USERNAME/spec-workflow-mcp:latest node -e "console.log('OK')"

# 3. 查看 Docker Hub
# 访问 https://hub.docker.com/r/YOUR_USERNAME/spec-workflow-mcp
```

---

## 📊 镜像信息

### 标签策略

| 标签     | 说明         | 更新频率 | 推荐用途         |
| -------- | ------------ | -------- | ---------------- |
| `latest` | 最新稳定版本 | 每次发布 | 生产环境         |
| `x.y.z`  | 特定版本     | 不变     | 生产环境（推荐） |
| `edge`   | 开发版本     | 每次提交 | 测试环境         |

### 架构支持

- ✅ linux/amd64（Intel/AMD x86_64）
- ✅ linux/arm64（Apple Silicon, ARM 服务器）

### 预装软件

- Node.js 24 (Alpine)
- Pandoc（文档转换）
- npm 生产依赖

---

## 🎯 使用场景

### 场景 1：个人开发者

```bash
# 快速启动 Dashboard
docker run -d -p 3000:3000 \
  -v $(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \
  gavinxia/spec-workflow-mcp:latest
```

### 场景 2：团队协作

```yaml
# docker-compose.yml
version: "3.8"
services:
  spec-workflow:
    image: gavinxia/spec-workflow-mcp:0.0.2
    ports:
      - "3000:3000"
    volumes:
      - ./project/.spec-workflow:/workspace/.spec-workflow:rw
```

### 场景 3：CI/CD 集成

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      spec-workflow:
        image: gavinxia/spec-workflow-mcp:latest
```

### 场景 4：Claude Desktop 用户

```json
{
  "mcpServers": {
    "spec-workflow": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-v",
        "${workspaceFolder}/.spec-workflow:${workspaceFolder}/.spec-workflow:rw",
        "--entrypoint=node",
        "gavinxia/spec-workflow-mcp:latest",
        "/app/dist/index.js",
        "${workspaceFolder}"
      ]
    }
  }
}
```

---

## 🔍 质量保证

### 安全性

- ✅ 非 root 用户运行
- ✅ 最小化镜像内容
- ✅ 定期漏洞扫描
- ✅ SBOM 生成

### 性能

- ✅ 多阶段构建优化
- ✅ 层缓存优化
- ✅ 健康检查机制
- ✅ 资源限制支持

### 可维护性

- ✅ 清晰的文档
- ✅ 版本管理
- ✅ 自动化测试
- ✅ CI/CD 流程

---

## 📚 相关链接

- **GitHub 仓库：** https://github.com/GavenXia/lls-spec-mcp
- **Docker Hub：** https://hub.docker.com/r/gavinxia/spec-workflow-mcp
- **完整文档：** [DOCKER_HUB_GUIDE.md](./DOCKER_HUB_GUIDE.md)
- **使用示例：** [examples/docker-examples.sh](./examples/docker-examples.sh)

---

## ✅ 检查清单

发布前请确认：

- [ ] 修改了 `build.sh` 中的 `DOCKER_USERNAME`
- [ ] 修改了 `docker-compose.yml` 中的镜像名
- [ ] 修改了 `.github/workflows/docker-publish.yml` 中的用户名
- [ ] 在 GitHub 添加了 `DOCKER_HUB_TOKEN` secret
- [ ] 更新了 `example.mcp.json` 中的镜像名
- [ ] 更新了 README 中的镜像名
- [ ] 本地测试构建成功
- [ ] 本地测试运行正常

---

## 🎉 总结

通过本次配置，Spec-Workflow MCP 现在具备：

1. **专业的 Docker 镜像**：多架构、优化、安全
2. **完整的发布流程**：手动 + 自动化
3. **详细的文档**：从构建到使用
4. **丰富的示例**：覆盖各种使用场景
5. **质量保证**：测试、扫描、监控

用户可以：

- 直接从 Docker Hub 拉取使用
- 轻松在任何支持 Docker 的环境运行
- 快速集成到 CI/CD 流程
- 在 Claude Desktop 等 MCP 客户端中使用

**下一步：**

1. 推送代码到 GitHub
2. 配置 Secret
3. 推送标签触发构建
4. 验证 Docker Hub 发布成功

祝发布顺利！🚀
