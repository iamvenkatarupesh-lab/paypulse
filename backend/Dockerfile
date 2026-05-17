# syntax=docker/dockerfile:1.7

# ============================================================
# Stage 1: deps — install ALL dependencies (incl. devDeps) for building
# ============================================================
FROM node:22-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# ============================================================
# Stage 2: builder — compile TypeScript to JavaScript
# ============================================================
FROM node:22-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY package.json package-lock.json tsconfig.json ./
COPY src ./src
RUN npm run build

# ============================================================
# Stage 3: runtime — minimal production image
# ============================================================
FROM node:22-alpine AS runtime

# Run with production optimisations (e.g. Express disables verbose errors)
ENV NODE_ENV=production
ENV PORT=3001

WORKDIR /app

# Install ONLY production dependencies (no tsc, no @types, etc.)
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy compiled JS from the builder stage
COPY --from=builder /app/dist ./dist

# Create a non-root user and own the app directory
RUN addgroup -S app && adduser -S app -G app && chown -R app:app /app
USER app

# Document the port the container listens on
EXPOSE 3001

# Docker / Kubernetes will use this to track container health
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3001/health || exit 1

# Use exec form (not shell) so SIGTERM reaches Node directly for graceful shutdown
CMD ["node", "dist/index.js"]
