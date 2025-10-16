# Spec-Workflow MCP Server - Docker 容器

[![Docker Hub](https://img.shields.io/docker/v/gavinxia/spec-workflow-mcp?label=Docker%20Hub&logo=docker)](https://hub.docker.com/r/gavinxia/spec-workflow-mcp)
[![Docker Pulls](https://img.shields.io/docker/pulls/gavinxia/spec-workflow-mcp)](https://hub.docker.com/r/gavinxia/spec-workflow-mcp)
[![Image Size](https://img.shields.io/docker/image-size/gavinxia/spec-workflow-mcp/latest)](https://hub.docker.com/r/gavinxia/spec-workflow-mcp)

本目录包含 Spec-Workflow MCP Server 的 Docker 配置文件，支持容器化部署。提供隔离的运行环境，方便部署和使用。

## ✨ 特性

- 🐳 **多架构支持**：支持 AMD64 和 ARM64（Apple Silicon）
- 📦 **开箱即用**：预装 Pandoc，支持文档转换
- 🔒 **安全运行**：非 root 用户运行
- 🚀 **轻量优化**：多阶段构建，镜像大小约 200-300MB
- 🏥 **健康检查**：内置健康检查机制
- 🔄 **自动化 CI/CD**：GitHub Actions 自动构建

## 📋 前置要求

- Docker 19.03+ （支持 buildx 和多架构）
- Docker Compose 3.8+（可选）

## 🚀 快速开始

### 方式 1：从 Docker Hub 拉取（推荐）

```bash
# 拉取最新版本
docker pull gavinxia/spec-workflow-mcp:latest

# 运行 Dashboard
docker run -d \
  --name spec-workflow-mcp \
  -p 3000:3000 \
  -v $(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \
  gavinxia/spec-workflow-mcp:latest

# 访问 Dashboard
open http://localhost:3000
```

### 方式 2：本地构建

```bash
# 从 containers 目录构建
cd containers

# 本地测试构建
./build-local.sh

# 构建并推送到 Docker Hub
./build.sh 0.0.2
```

## 📖 使用文档

### 完整文档

- [Docker Hub 发布指南](./DOCKER_HUB_GUIDE.md) - 如何构建和发布镜像
- [使用示例](./examples/docker-examples.sh) - 各种使用场景示例

## 🔧 配置 MCP 客户端

### Claude Desktop 配置

创建或更新项目根目录的 `.mcp.json` 文件：

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
        "./.spec-workflow:/home/username/project/.spec-workflow:rw",
        "--entrypoint=node",
        "spec-workflow-mcp:latest",
        "/app/dist/index.js",
        "./"
      ]
    }
  }
}
```

## Important Configuration Notes

### Path Mapping Requirements

The container requires the `.spec-workflow` directory to be mounted at the **exact same path** inside the container as it exists on your host system. This is critical for the MCP server to function correctly.

**Example:** If your project is at `/home/steev/tabletopsentinel.com`, your configuration would be:

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
        "./.spec-workflow:/home/steev/tabletopsentinel.com/.spec-workflow:rw",
        "--entrypoint=node",
        "spec-workflow-mcp:latest",
        "/app/dist/index.js",
        "./"
      ]
    }
  }
}
```

### Key Configuration Points

- **Path Consistency**: The container path must match your host path exactly
- **Volume Mount**: Only the `.spec-workflow` directory needs to be mounted
- **Auto-creation**: The `.spec-workflow` directory will be created if it doesn't exist
- **SELinux Note**: If you're using SELinux, you may need to add `:z` to the volume mount (e.g., `:rw,z`)

## Dashboard Deployment

The dashboard can be run separately from the MCP server using Docker Compose. This is useful if you're not using the VSCode extension.

### Important Environment Variables

- `SPEC_WORKFLOW_PATH`: Must match the project path used in the MCP server configuration
- `DASHBOARD_PORT`: The port to expose the dashboard on (default: 3000)

### Using Docker Compose

Start the dashboard with default settings:

```bash
# Replace with your actual project path
SPEC_WORKFLOW_PATH=/home/username/project docker-compose up -d
```

Start the dashboard on a custom port:

```bash
DASHBOARD_PORT=3456 SPEC_WORKFLOW_PATH=/home/username/project docker-compose up -d
```

Access the dashboard at:

- Default: `http://localhost:3000`
- Custom port: `http://localhost:YOUR_PORT`

### Stopping the Dashboard

```bash
docker-compose down
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure the `.spec-workflow` directory has proper permissions
2. **Port Already in Use**: Choose a different port using the `DASHBOARD_PORT` variable
3. **Path Not Found**: Verify that your `SPEC_WORKFLOW_PATH` matches your actual project location
4. **SELinux Issues**: On SELinux-enabled systems, add `:z` to volume mounts

### Logs and Debugging

View container logs:

```bash
docker-compose logs -f
```

Check container status:

```bash
docker ps
```
