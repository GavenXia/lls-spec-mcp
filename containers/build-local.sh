#!/bin/bash
# =============================================================================
# 本地 Docker 镜像构建脚本（不推送）
# =============================================================================
# 功能：仅在本地构建镜像，用于测试
# 用法：./build-local.sh [版本号]
# 示例：./build-local.sh 0.0.2
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 从 package.json 读取版本号
PACKAGE_VERSION=$(node -p "require('../package.json').version")
VERSION=${1:-$PACKAGE_VERSION}

# Docker 镜像名称
IMAGE_NAME="spec-workflow-mcp"
FULL_IMAGE_NAME="${IMAGE_NAME}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  本地构建 Docker 镜像${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}📦 镜像名称:${NC} ${FULL_IMAGE_NAME}"
echo -e "${GREEN}🏷️  版本号:${NC} ${VERSION}"
echo -e "${GREEN}🏗️  架构:${NC} 当前平台"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ 错误: Docker 未安装${NC}"
    exit 1
fi

# 切换到项目根目录
cd "$(dirname "$0")/.."

echo -e "${BLUE}🔨 构建镜像...${NC}"
echo -e "${YELLOW}⏳ 这可能需要几分钟时间...${NC}"
echo ""

# 本地构建（单架构）
docker build \
  --file containers/Dockerfile \
  --tag "${FULL_IMAGE_NAME}:${VERSION}" \
  --tag "${FULL_IMAGE_NAME}:latest" \
  --build-arg VERSION="${VERSION}" \
  .

echo ""
echo -e "${BLUE}📊 镜像信息:${NC}"
docker images "${FULL_IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 本地构建成功！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}🧪 测试命令:${NC}"
echo ""
echo -e "  ${YELLOW}# 1. 测试运行（交互模式）${NC}"
echo -e "  docker run -it --rm ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo -e "  ${YELLOW}# 2. 测试 Dashboard${NC}"
echo -e "  docker run -p 3000:3000 ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "  浏览器访问: http://localhost:3000"
echo ""
echo -e "  ${YELLOW}# 3. 挂载工作目录测试${NC}"
echo -e "  docker run -v \$(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \\"
echo -e "    ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo -e "  ${YELLOW}# 4. MCP 模式测试${NC}"
echo -e "  docker run --rm -i \\"
echo -e "    -v \$(pwd)/.spec-workflow:/workspace/.spec-workflow:rw \\"
echo -e "    --entrypoint=node ${FULL_IMAGE_NAME}:${VERSION} \\"
echo -e "    /app/dist/index.js /workspace"
echo ""
echo -e "${GREEN}🔍 镜像检查:${NC}"
echo -e "  docker inspect ${FULL_IMAGE_NAME}:${VERSION}"
echo ""

