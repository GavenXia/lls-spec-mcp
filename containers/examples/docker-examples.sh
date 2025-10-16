#!/bin/bash
# =============================================================================
# Spec-Workflow MCP Docker 使用示例
# =============================================================================
# 本文件包含各种 Docker 使用场景的示例命令
# 可以直接复制粘贴运行
# =============================================================================

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Spec-Workflow MCP Docker 使用示例${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# =============================================================================
# 示例 1: 拉取镜像
# =============================================================================
example_pull() {
    echo -e "${GREEN}━━━ 示例 1: 拉取镜像 ━━━${NC}"
    echo ""
    echo "# 拉取最新版本"
    echo "docker pull gavinxia/spec-workflow-mcp:latest"
    echo ""
    echo "# 拉取特定版本"
    echo "docker pull gavinxia/spec-workflow-mcp:0.0.2"
    echo ""
}

# =============================================================================
# 示例 2: 运行 Dashboard
# =============================================================================
example_dashboard() {
    echo -e "${GREEN}━━━ 示例 2: 运行 Dashboard ━━━${NC}"
    echo ""
    echo "# 基础运行（后台模式）"
    echo "docker run -d \\"
    echo "  --name spec-workflow-dashboard \\"
    echo "  -p 3000:3000 \\"
    echo "  -v \$(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \\"
    echo "  gavinxia/spec-workflow-mcp:latest"
    echo ""
    echo "# 访问 Dashboard"
    echo "open http://localhost:3000"
    echo ""
    echo "# 查看日志"
    echo "docker logs -f spec-workflow-dashboard"
    echo ""
    echo "# 停止"
    echo "docker stop spec-workflow-dashboard"
    echo ""
    echo "# 删除容器"
    echo "docker rm spec-workflow-dashboard"
    echo ""
}

# =============================================================================
# 示例 3: 作为 MCP 服务器运行（Claude Desktop）
# =============================================================================
example_mcp_server() {
    echo -e "${GREEN}━━━ 示例 3: MCP 服务器模式 ━━━${NC}"
    echo ""
    echo "# 交互式运行"
    echo "docker run --rm -i \\"
    echo "  -v \$(pwd)/.spec-workflow:\$(pwd)/.spec-workflow:rw \\"
    echo "  --entrypoint=node \\"
    echo "  gavinxia/spec-workflow-mcp:latest \\"
    echo "  /app/dist/index.js \$(pwd)"
    echo ""
    echo "# Claude Desktop 配置（.mcp.json）"
    cat << 'EOF'
{
  "mcpServers": {
    "spec-workflow": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-v", "${workspaceFolder}/.spec-workflow:${workspaceFolder}/.spec-workflow:rw",
        "--entrypoint=node",
        "gavinxia/spec-workflow-mcp:latest",
        "/app/dist/index.js",
        "${workspaceFolder}"
      ]
    }
  }
}
EOF
    echo ""
}

# =============================================================================
# 示例 4: Docker Compose 运行
# =============================================================================
example_docker_compose() {
    echo -e "${GREEN}━━━ 示例 4: Docker Compose ━━━${NC}"
    echo ""
    echo "# 创建 .env 文件"
    echo "cat > .env << EOF"
    echo "DASHBOARD_PORT=3000"
    echo "SPEC_WORKFLOW_PATH=\$(pwd)"
    echo "EOF"
    echo ""
    echo "# 启动服务（后台）"
    echo "docker-compose -f containers/docker-compose.yml up -d"
    echo ""
    echo "# 查看日志"
    echo "docker-compose -f containers/docker-compose.yml logs -f"
    echo ""
    echo "# 停止服务"
    echo "docker-compose -f containers/docker-compose.yml down"
    echo ""
}

# =============================================================================
# 示例 5: 自定义端口
# =============================================================================
example_custom_port() {
    echo -e "${GREEN}━━━ 示例 5: 自定义端口 ━━━${NC}"
    echo ""
    echo "# 使用 8080 端口"
    echo "docker run -d \\"
    echo "  --name spec-workflow-mcp \\"
    echo "  -p 8080:3000 \\"
    echo "  -e DASHBOARD_PORT=3000 \\"
    echo "  -v \$(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \\"
    echo "  gavinxia/spec-workflow-mcp:latest"
    echo ""
    echo "# 访问"
    echo "open http://localhost:8080"
    echo ""
}

# =============================================================================
# 示例 6: 资源限制
# =============================================================================
example_resource_limits() {
    echo -e "${GREEN}━━━ 示例 6: 资源限制 ━━━${NC}"
    echo ""
    echo "# 限制 CPU 和内存"
    echo "docker run -d \\"
    echo "  --name spec-workflow-mcp \\"
    echo "  --cpus=\"1.5\" \\"
    echo "  --memory=\"1g\" \\"
    echo "  -p 3000:3000 \\"
    echo "  -v \$(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \\"
    echo "  gavinxia/spec-workflow-mcp:latest"
    echo ""
}

# =============================================================================
# 示例 7: 多项目支持
# =============================================================================
example_multiple_projects() {
    echo -e "${GREEN}━━━ 示例 7: 多项目支持 ━━━${NC}"
    echo ""
    echo "# 项目 1 - 端口 3001"
    echo "docker run -d \\"
    echo "  --name spec-workflow-project1 \\"
    echo "  -p 3001:3000 \\"
    echo "  -v /path/to/project1/.spec-workflow:/workspace/.spec-workflow:rw \\"
    echo "  gavinxia/spec-workflow-mcp:latest"
    echo ""
    echo "# 项目 2 - 端口 3002"
    echo "docker run -d \\"
    echo "  --name spec-workflow-project2 \\"
    echo "  -p 3002:3000 \\"
    echo "  -v /path/to/project2/.spec-workflow:/workspace/.spec-workflow:rw \\"
    echo "  gavinxia/spec-workflow-mcp:latest"
    echo ""
}

# =============================================================================
# 示例 8: 健康检查和日志
# =============================================================================
example_health_and_logs() {
    echo -e "${GREEN}━━━ 示例 8: 健康检查和日志 ━━━${NC}"
    echo ""
    echo "# 检查容器状态"
    echo "docker ps"
    echo ""
    echo "# 检查健康状态"
    echo "docker inspect --format='{{.State.Health.Status}}' spec-workflow-mcp"
    echo ""
    echo "# 实时查看日志"
    echo "docker logs -f spec-workflow-mcp"
    echo ""
    echo "# 查看最近 100 行日志"
    echo "docker logs --tail 100 spec-workflow-mcp"
    echo ""
}

# =============================================================================
# 示例 9: 进入容器调试
# =============================================================================
example_debug() {
    echo -e "${GREEN}━━━ 示例 9: 进入容器调试 ━━━${NC}"
    echo ""
    echo "# 进入运行中的容器"
    echo "docker exec -it spec-workflow-mcp sh"
    echo ""
    echo "# 查看 Pandoc 版本"
    echo "docker exec spec-workflow-mcp pandoc --version"
    echo ""
    echo "# 查看 Node.js 版本"
    echo "docker exec spec-workflow-mcp node --version"
    echo ""
    echo "# 查看文件系统"
    echo "docker exec spec-workflow-mcp ls -la /workspace"
    echo ""
}

# =============================================================================
# 示例 10: 备份和恢复
# =============================================================================
example_backup_restore() {
    echo -e "${GREEN}━━━ 示例 10: 备份和恢复 ━━━${NC}"
    echo ""
    echo "# 备份 spec-workflow 数据"
    echo "tar -czf spec-workflow-backup.tar.gz .spec-workflow/"
    echo ""
    echo "# 恢复数据"
    echo "tar -xzf spec-workflow-backup.tar.gz"
    echo ""
}

# =============================================================================
# 主菜单
# =============================================================================
show_menu() {
    echo ""
    echo -e "${YELLOW}选择示例（输入数字）：${NC}"
    echo "  1) 拉取镜像"
    echo "  2) 运行 Dashboard"
    echo "  3) MCP 服务器模式"
    echo "  4) Docker Compose"
    echo "  5) 自定义端口"
    echo "  6) 资源限制"
    echo "  7) 多项目支持"
    echo "  8) 健康检查和日志"
    echo "  9) 容器调试"
    echo " 10) 备份和恢复"
    echo "  0) 显示所有示例"
    echo "  q) 退出"
    echo ""
    read -p "请选择: " choice
    
    case $choice in
        1) example_pull ;;
        2) example_dashboard ;;
        3) example_mcp_server ;;
        4) example_docker_compose ;;
        5) example_custom_port ;;
        6) example_resource_limits ;;
        7) example_multiple_projects ;;
        8) example_health_and_logs ;;
        9) example_debug ;;
        10) example_backup_restore ;;
        0) 
            example_pull
            example_dashboard
            example_mcp_server
            example_docker_compose
            example_custom_port
            example_resource_limits
            example_multiple_projects
            example_health_and_logs
            example_debug
            example_backup_restore
            ;;
        q|Q) exit 0 ;;
        *) echo "无效选择" ;;
    esac
    
    show_menu
}

# 如果直接运行脚本，显示菜单
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    show_menu
fi

