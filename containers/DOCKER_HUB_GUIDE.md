# Docker Hub 发布指南

本指南介绍如何将 Spec-Workflow MCP 镜像发布到 Docker Hub，以及如何使用已发布的镜像。

## 📋 目录

- [准备工作](#准备工作)
- [手动构建和发布](#手动构建和发布)
- [自动化 CI/CD](#自动化-cicd)
- [使用 Docker 镜像](#使用-docker-镜像)
- [常见问题](#常见问题)

---

## 🚀 准备工作

### 1. 创建 Docker Hub 账号

1. 访问 [Docker Hub](https://hub.docker.com/)
2. 注册账号
3. 记住你的用户名（将用作镜像命名空间）

### 2. 安装 Docker

确保已安装 Docker 并启用 buildx：

```bash
# 检查 Docker 版本
docker --version

# 检查 buildx 是否可用
docker buildx version

# 如果 buildx 不可用，启用实验性功能
export DOCKER_CLI_EXPERIMENTAL=enabled
```

**要求：**

- Docker 19.03+ （支持 buildx 和多架构构建）
- Docker Buildx （用于多架构镜像）

### 3. 登录 Docker Hub

```bash
# 方式 1：交互式登录
docker login

# 方式 2：使用命令行参数
docker login -u YOUR_USERNAME -p YOUR_PASSWORD

# 方式 3：使用 Access Token（推荐）
# 在 Docker Hub 设置中生成 Access Token
docker login -u YOUR_USERNAME -p YOUR_ACCESS_TOKEN
```

---

## 🔨 手动构建和发布

### 方法 1：使用构建脚本（推荐）

我们提供了自动化构建脚本，支持多架构构建。

#### 步骤：

```bash
# 1. 进入 containers 目录
cd containers

# 2. 给脚本添加执行权限
chmod +x build.sh build-local.sh

# 3. 本地测试构建（不推送）
./build-local.sh

# 4. 构建并推送到 Docker Hub
./build.sh [版本号]

# 示例：
./build.sh 0.0.2
```

**注意：** 请先在 `build.sh` 中修改 `DOCKER_USERNAME` 为你的 Docker Hub 用户名。

#### 构建脚本特性：

- ✅ 自动读取 `package.json` 版本号
- ✅ 多架构支持（amd64 + arm64）
- ✅ 自动添加 `latest` 标签
- ✅ 完整的构建验证
- ✅ 友好的进度提示

### 方法 2：手动 Docker 命令

如果你想完全手动控制：

```bash
# 1. 切换到项目根目录
cd /path/to/lls-spec-mcp

# 2. 创建 buildx 构建器
docker buildx create --name spec-workflow-builder --use
docker buildx inspect --bootstrap

# 3. 构建并推送多架构镜像
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --file containers/Dockerfile \
  --tag YOUR_USERNAME/spec-workflow-mcp:0.0.2 \
  --tag YOUR_USERNAME/spec-workflow-mcp:latest \
  --push \
  .

# 4. 验证镜像
docker pull YOUR_USERNAME/spec-workflow-mcp:0.0.2
```

---

## 🤖 自动化 CI/CD

### GitHub Actions 自动发布

项目已配置 GitHub Actions，可以自动构建和发布镜像。

#### 配置步骤：

**1. 在 GitHub 仓库设置中添加 Secret**

导航到：`Settings` → `Secrets and variables` → `Actions` → `New repository secret`

添加以下 Secret：

- **Name:** `DOCKER_HUB_TOKEN`
- **Value:** 你的 Docker Hub Access Token

**生成 Docker Hub Access Token:**

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → `Account Settings`
3. 选择 `Security` → `New Access Token`
4. 输入描述，生成 Token
5. 复制 Token（只显示一次）

**2. 更新工作流配置**

编辑 `.github/workflows/docker-publish.yml`：

```yaml
env:
  DOCKER_USERNAME: YOUR_USERNAME # 修改为你的用户名
  IMAGE_NAME: spec-workflow-mcp
```

**3. 触发构建**

自动触发条件：

- 推送标签（如 `v0.0.2`）
- 推送到 `main` 分支
- 手动触发

```bash
# 方法 1：推送标签（推荐）
git tag v0.0.2
git push origin v0.0.2

# 方法 2：推送到 main 分支
git push origin main

# 方法 3：手动触发
# 在 GitHub 网页上：Actions → Docker Image CI/CD → Run workflow
```

#### CI/CD 功能特性：

- ✅ 自动多架构构建
- ✅ 版本标签管理
- ✅ 镜像漏洞扫描
- ✅ 生成 SBOM（软件物料清单）
- ✅ 自动更新 Docker Hub 描述
- ✅ 构建缓存加速

---

## 📦 使用 Docker 镜像

### 方法 1：Docker Compose（推荐）

适合运行 Dashboard：

```bash
# 1. 创建配置文件
cat > .env << EOF
DASHBOARD_PORT=3000
SPEC_WORKFLOW_PATH=$(pwd)
EOF

# 2. 启动服务
docker-compose -f containers/docker-compose.yml up -d

# 3. 访问 Dashboard
open http://localhost:3000

# 4. 停止服务
docker-compose -f containers/docker-compose.yml down
```

### 方法 2：Docker Run

#### 2.1 运行 Dashboard

```bash
docker run -d \
  --name spec-workflow-mcp \
  -p 3000:3000 \
  -v $(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \
  gavinxia/spec-workflow-mcp:latest
```

访问：http://localhost:3000

#### 2.2 作为 MCP 服务器

配置 Claude Desktop 或其他 MCP 客户端：

**`.mcp.json` 配置：**

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

**注意：** 路径映射必须一致！

### 方法 3：Kubernetes

**Deployment 示例：**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spec-workflow-mcp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: spec-workflow-mcp
  template:
    metadata:
      labels:
        app: spec-workflow-mcp
    spec:
      containers:
        - name: spec-workflow-mcp
          image: gavinxia/spec-workflow-mcp:latest
          ports:
            - containerPort: 3000
          env:
            - name: DASHBOARD_PORT
              value: "3000"
          volumeMounts:
            - name: spec-workflow-data
              mountPath: /workspace/.spec-workflow
          resources:
            limits:
              memory: "2Gi"
              cpu: "2"
            requests:
              memory: "512Mi"
              cpu: "500m"
      volumes:
        - name: spec-workflow-data
          persistentVolumeClaim:
            claimName: spec-workflow-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: spec-workflow-mcp
spec:
  selector:
    app: spec-workflow-mcp
  ports:
    - port: 3000
      targetPort: 3000
  type: LoadBalancer
```

---

## 🏷️ 版本标签策略

我们使用以下标签策略：

| 标签     | 说明                  | 示例                                | 更新频率 |
| -------- | --------------------- | ----------------------------------- | -------- |
| `latest` | 最新稳定版本          | `gavinxia/spec-workflow-mcp:latest` | 每次发布 |
| `x.y.z`  | 特定版本              | `gavinxia/spec-workflow-mcp:0.0.2`  | 不变     |
| `edge`   | 开发版本（main 分支） | `gavinxia/spec-workflow-mcp:edge`   | 每次提交 |

**推荐使用：**

- **生产环境：** 使用特定版本号（如 `0.0.2`）
- **开发环境：** 使用 `latest` 或 `edge`

---

## 🔍 镜像验证

### 检查镜像信息

```bash
# 1. 查看镜像详情
docker images gavinxia/spec-workflow-mcp

# 2. 检查镜像架构
docker manifest inspect gavinxia/spec-workflow-mcp:latest

# 3. 查看镜像层
docker history gavinxia/spec-workflow-mcp:latest

# 4. 检查镜像标签
docker inspect gavinxia/spec-workflow-mcp:latest | jq '.[0].Config.Labels'
```

### 测试镜像

```bash
# 1. 运行健康检查
docker run --rm gavinxia/spec-workflow-mcp:latest node -e "console.log('OK')"

# 2. 检查 Pandoc
docker run --rm gavinxia/spec-workflow-mcp:latest pandoc --version

# 3. 测试 MCP 服务器
docker run --rm -i gavinxia/spec-workflow-mcp:latest \
  node /app/dist/index.js --help
```

---

## 📊 镜像大小优化

当前镜像大小：**约 200-300MB**

优化策略：

- ✅ 多阶段构建
- ✅ Alpine Linux 基础镜像
- ✅ 仅包含生产依赖
- ✅ 优化的 .dockerignore
- ✅ 层缓存优化

---

## 🐛 常见问题

### 1. 构建失败：buildx 不可用

**问题：** `docker buildx` 命令不存在

**解决：**

```bash
# 检查 Docker 版本
docker --version  # 需要 19.03+

# 启用实验性功能
export DOCKER_CLI_EXPERIMENTAL=enabled

# 或者升级 Docker
# macOS: brew upgrade docker
# Windows: 下载最新安装包
# Linux: 参考官方文档
```

### 2. 推送失败：权限拒绝

**问题：** `denied: requested access to the resource is denied`

**解决：**

```bash
# 1. 确认已登录
docker login

# 2. 确认镜像名称格式正确
# 格式：USERNAME/IMAGE_NAME:TAG
docker tag spec-workflow-mcp YOUR_USERNAME/spec-workflow-mcp:latest

# 3. 推送
docker push YOUR_USERNAME/spec-workflow-mcp:latest
```

### 3. 多架构构建慢

**问题：** ARM64 构建非常慢

**原因：** 在 x86 机器上模拟 ARM64

**解决：**

```bash
# 方法 1：使用 GitHub Actions（推荐）
# GitHub 提供原生 ARM64 runner

# 方法 2：仅构建当前架构
docker build -t YOUR_USERNAME/spec-workflow-mcp:latest .

# 方法 3：使用远程构建器
docker buildx create --name mybuilder --platform linux/amd64,linux/arm64
```

### 4. 镜像拉取慢

**问题：** 国内拉取 Docker Hub 镜像很慢

**解决：**

```bash
# 使用 Docker Hub 镜像加速器
# 编辑 /etc/docker/daemon.json

{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com"
  ]
}

# 重启 Docker
sudo systemctl restart docker
```

### 5. 路径映射问题

**问题：** MCP 服务器找不到文件

**解决：**

确保容器内路径与宿主机路径**完全一致**：

```json
{
  "args": [
    "-v",
    "/absolute/path/to/project/.spec-workflow:/absolute/path/to/project/.spec-workflow:rw"
  ]
}
```

---

## 📚 相关资源

- [Docker Hub 官方文档](https://docs.docker.com/docker-hub/)
- [Docker Buildx 文档](https://docs.docker.com/buildx/working-with-buildx/)
- [GitHub Actions Docker](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
- [项目主页](https://github.com/GavenXia/lls-spec-mcp)

---

## 🎉 总结

**快速开始：**

1. **发布镜像：**

   ```bash
   cd containers
   ./build.sh 0.0.2
   ```

2. **使用镜像：**

   ```bash
   docker pull gavinxia/spec-workflow-mcp:latest
   docker run -p 3000:3000 gavinxia/spec-workflow-mcp:latest
   ```

3. **自动化 CI/CD：**
   - 配置 GitHub Secret
   - 推送标签触发构建

**需要帮助？**

- 查看 [GitHub Issues](https://github.com/GavenXia/lls-spec-mcp/issues)
- 提交 Bug 报告
- 参与讨论

---

**最后更新：** 2025-01-16  
**版本：** 0.0.2
