import { createReadStream, existsSync, statSync } from 'node:fs';
import { extname, join, normalize, resolve } from 'node:path';
import { defineConfig, type Plugin } from 'vite';

// While developing, /catalogue/* is the repository itself (games, lib,
// sounds, index.json), so the web version reads the same files it will read
// from GitHub once published.
const repository = resolve(import.meta.dirname, '..');
const types: Record<string, string> = {
  '.json': 'application/json', '.ablox': 'application/json', '.absc': 'text/plain; charset=utf-8',
  '.png': 'image/png', '.jpg': 'image/jpeg', '.mp3': 'audio/mpeg',
};

function catalogue(): Plugin {
  return {
    name: 'ablox-catalogue',
    configureServer(server) {
      server.middlewares.use('/catalogue', (req, res, next) => {
        const path = normalize(decodeURIComponent((req.url ?? '/').split('?')[0])).replace(/^(\.\.[/\\])+/, '');
        const file = join(repository, path);
        if (!file.startsWith(repository) || !existsSync(file) || statSync(file).isDirectory()) return next();
        res.setHeader('Content-Type', types[extname(file)] ?? 'application/octet-stream');
        createReadStream(file).pipe(res);
      });
    },
  };
}

export default defineConfig({
  base: './',
  plugins: [catalogue()],
  build: { target: 'es2022', chunkSizeWarningLimit: 1500, sourcemap: false },
  test: { environment: 'node', testTimeout: 30000 },
});
