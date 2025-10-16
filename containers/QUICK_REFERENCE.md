# 🚀 快速参考指南

## 📦 镜像信息

```bash
# Docker Hub 镜像
gavinxia/spec-workflow-mcp:latest
gavinxia/spec-workflow-mcp:0.0.2
gavinxia/spec-workflow-mcp:edge
```

## 🔨 构建命令

```bash
# 本地测试构建
cd containers && ./build-local.sh

# 构建并推送到 Docker Hub
cd containers && ./build.sh 0.0.2
```

## 🏃 运行命令

### Dashboard 模式

```bash
docker run -d -p 3000:3000 \
  -v $(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \
  gavinxia/spec-workflow-mcp:latest
```

### MCP 服务器模式

```bash
docker run --rm -i \
  -v $(pwd)/.spec-workflow:$(pwd)/.spec-workflow:rw \
  --entrypoint=node \
  gavinxia/spec-workflow-mcp:latest \
  /app/dist/index.js $(pwd)
```

### Docker Compose

```bash
SPEC_WORKFLOW_PATH=$(pwd) docker-compose -f containers/docker-compose.yml up -d
```

## ⚙️ 配置文件

### .mcp.json (Claude Desktop)

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

## 🔑 GitHub Actions 配置

### 添加 Secret

1. GitHub 仓库 → Settings → Secrets → New secret
2. Name: `DOCKER_HUB_TOKEN`
3. Value: 你的 Docker Hub Access Token

### 触发构建

```bash
# 方式 1: 推送标签
git tag v0.0.2
git push origin v0.0.2

# 方式 2: 推送到 main
git push origin main

# 方式 3: 手动触发（GitHub 网页）
Actions → Docker Image CI/CD → Run workflow
```

## 📝 需要修改的文件

在发布前，请将以下文件中的 `gavinxia` 替换为你的 Docker Hub 用户名：

- [ ] `containers/build.sh` (DOCKER_USERNAME)
- [ ] `containers/docker-compose.yml` (image)
- [ ] `.github/workflows/docker-publish.yml` (DOCKER_USERNAME)
- [ ] `containers/example.mcp.json` (image)
- [ ] `containers/README.md` (所有示例)

## 🔍 验证命令

```bash
# 检查镜像
docker images gavinxia/spec-workflow-mcp

# 测试运行
docker run --rm gavinxia/spec-workflow-mcp:latest node -e "console.log('OK')"

# 检查 Pandoc
docker run --rm gavinxia/spec-workflow-mcp:latest pandoc --version

# 查看日志
docker logs -f spec-workflow-mcp
```

## 📚 完整文档

- **详细指南：** [DOCKER_HUB_GUIDE.md](./DOCKER_HUB_GUIDE.md)
- **配置总结：** [DOCKER_SETUP_SUMMARY.md](./DOCKER_SETUP_SUMMARY.md)
- **使用示例：** [examples/docker-examples.sh](./examples/docker-examples.sh)
- **主文档：** [README.md](./README.md)

## 🆘 故障排查

### 问题：buildx 不可用

```bash
docker buildx version  # 检查版本
export DOCKER_CLI_EXPERIMENTAL=enabled  # 启用
```

### 问题：推送权限拒绝

```bash
docker login  # 重新登录
```

### 问题：路径映射错误

确保容器内路径与宿主机路径完全一致！

## 🔗 链接

- **GitHub:** https://github.com/GavenXia/lls-spec-mcp
- **Docker Hub:** https://hub.docker.com/r/gavinxia/spec-workflow-mcp
- **Issues:** https://github.com/GavenXia/lls-spec-mcp/issues
