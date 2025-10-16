# =============================================================================
# Spec-Workflow MCP Server Docker Image
# =============================================================================
# Multi-stage build for optimized production image with Pandoc support
# Supports: amd64, arm64
# =============================================================================

# -----------------------------------------------------------------------------
# Build Stage: Compile TypeScript and build dashboard
# -----------------------------------------------------------------------------
FROM node:24-alpine AS builder

# Install build dependencies
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install ALL dependencies (including devDependencies for build)
RUN npm ci

# Copy source code
COPY . .

# Build the application (TypeScript + Dashboard)
RUN npm run build

# Verify build output
RUN ls -la /app/dist && \
    test -f /app/dist/index.js && \
    echo "✅ Build successful"

# -----------------------------------------------------------------------------
# Runtime Stage: Minimal production image
# -----------------------------------------------------------------------------
FROM node:24-alpine

# Metadata labels (OCI standard)
LABEL org.opencontainers.image.title="Spec-Workflow MCP Server"
LABEL org.opencontainers.image.description="MCP server for spec-driven development workflow with real-time web dashboard"
LABEL org.opencontainers.image.version="0.0.2"
LABEL org.opencontainers.image.vendor="GavenXia"
LABEL org.opencontainers.image.source="https://github.com/GavenXia/lls-spec-mcp"
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.authors="gavinxia"
LABEL maintainer="gavinxia"

WORKDIR /app

# Install runtime dependencies:
# - pandoc: Document conversion (Word ↔ Markdown)
# - tini: Init system for proper signal handling
RUN apk add --no-cache \
    pandoc \
    tini && \
    pandoc --version && \
    echo "✅ Pandoc installed successfully"

# Copy package files and install ONLY production dependencies
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force

# Copy built application
COPY --from=builder /app/dist ./dist

# Copy necessary runtime resources
COPY --from=builder /app/README.md ./
COPY --from=builder /app/LICENSE ./

# Create workspace directory
RUN mkdir -p /workspace

# Security: Run as non-root user
# Change ownership to node user (uid=1000, gid=1000)
RUN chown -R node:node /app /workspace

# Switch to non-root user
USER node

# Set working directory for MCP operations
WORKDIR /workspace

# Expose dashboard port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "process.exit(0)" || exit 1

# Use tini as init system for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Default command: Run MCP server with dashboard
CMD ["node", "/app/dist/index.js", "/workspace", "--dashboard", "--port", "3000"]

# Environment variables (can be overridden)
ENV NODE_ENV=production \
    DASHBOARD_PORT=3000 \
    SPEC_WORKFLOW_PATH=/workspace
