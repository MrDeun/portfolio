# ─────────────────────────────────────────────
# Stage 1: Build
# ─────────────────────────────────────────────
FROM denoland/deno:latest AS builder

WORKDIR /app

# Copy dependency manifest and lock file
COPY package.json deno.lock ./

# Install into a local node_modules folder so Vite/esbuild
# can resolve paths (tsconfig extends, postcss, etc.) the Node way
RUN deno install --allow-scripts=npm:sharp,npm:esbuild

# Copy the rest of the project
COPY . .

# Build — NODE_MODULES_DIR ensures Deno uses the local node_modules
ENV DENO_NODE_MODULES_DIR=auto
RUN deno run --allow-all --node-modules-dir=auto npm:astro build

# ─────────────────────────────────────────────
# Stage 2: Runtime
# ─────────────────────────────────────────────
FROM denoland/deno:latest

WORKDIR /app

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

EXPOSE 4321

CMD ["run", "--allow-all", "--node-modules-dir=auto", "npm:astro", "preview", "--host", "0.0.0.0"]