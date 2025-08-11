# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Copy prisma schema so prisma generate works on npm ci / postinstall
COPY prisma ./prisma

# Install dependencies (runs postinstall -> prisma generate)
RUN npm ci

# Copy rest of the app source code
COPY . .

# Build Next.js app
RUN npm run build

# Stage 2: Production image
FROM node:18-alpine
WORKDIR /app

# Copy package files and node_modules from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules

# Copy build output and public assets
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/prisma ./prisma

EXPOSE 3000

CMD ["npm", "start"]
