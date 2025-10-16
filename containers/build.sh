#!/bin/bash
# =============================================================================
# Docker 镜像构建脚本
# =============================================================================
# 功能：构建多架构 Docker 镜像（amd64 + arm64）
# 用法：./build.sh [版本号]
# 示例：./build.sh 0.0.2
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

# Docker Hub 配置
DOCKER_USERNAME=${DOCKER_USERNAME:-"gavinxia"}  # 替换为你的 Docker Hub 用户名
IMAGE_NAME="spec-workflow-mcp"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Spec-Workflow MCP - Docker 镜像构建${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}📦 镜像名称:${NC} ${FULL_IMAGE_NAME}"
echo -e "${GREEN}🏷️  版本号:${NC} ${VERSION}"
echo -e "${GREEN}🏗️  架构:${NC} linux/amd64, linux/arm64"
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ 错误: Docker 未安装${NC}"
    exit 1
fi

# 检查 buildx 是否可用
if ! docker buildx version &> /dev/null; then
    echo -e "${RED}❌ 错误: Docker buildx 不可用${NC}"
    echo -e "${YELLOW}💡 提示: 请升级到 Docker 19.03+ 或启用 buildx${NC}"
    exit 1
fi

# 切换到项目根目录
cd "$(dirname "$0")/.."

echo -e "${BLUE}🔨 步骤 1/4: 创建 buildx 构建器...${NC}"
# 创建或使用现有的 buildx 构建器
if ! docker buildx ls | grep -q "spec-workflow-builder"; then
    docker buildx create --name spec-workflow-builder --use
else
    docker buildx use spec-workflow-builder
fi

# 启动构建器
docker buildx inspect --bootstrap

echo ""
echo -e "${BLUE}🔨 步骤 2/4: 构建多架构镜像...${NC}"
echo -e "${YELLOW}⏳ 这可能需要几分钟时间...${NC}"
echo ""

# 构建并推送镜像（支持多架构）
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --file containers/Dockerfile \
  --tag "${FULL_IMAGE_NAME}:${VERSION}" \
  --tag "${FULL_IMAGE_NAME}:latest" \
  --build-arg VERSION="${VERSION}" \
  --push \
  .

echo ""
echo -e "${BLUE}🔨 步骤 3/4: 验证镜像...${NC}"
# 拉取并验证镜像
docker pull "${FULL_IMAGE_NAME}:${VERSION}"
docker pull "${FULL_IMAGE_NAME}:latest"

echo ""
echo -e "${BLUE}🔨 步骤 4/4: 显示镜像信息...${NC}"
docker images "${FULL_IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 构建成功！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}📋 镜像标签:${NC}"
echo -e "   • ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "   • ${FULL_IMAGE_NAME}:latest"
echo ""
echo -e "${GREEN}🚀 使用方法:${NC}"
echo -e "   docker pull ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "   docker run -it --rm ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo -e "${GREEN}🔗 Docker Hub:${NC}"
echo -e "   https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}"
echo ""

