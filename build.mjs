import { cp, mkdir, rm, writeFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const root = dirname(fileURLToPath(import.meta.url));
const dist = join(root, "dist");
const client = join(dist, "client");
const files = ["index.html", "brand.css", "style.css", "script.js", "favicon.svg"];

await rm(dist, { recursive: true, force: true });
await mkdir(join(dist, "server"), { recursive: true });
await mkdir(client, { recursive: true });

for (const file of files) {
  await cp(join(root, file), join(client, file));
}

await cp(join(root, "assets"), join(client, "assets"), { recursive: true });

await writeFile(
  join(dist, "server", "index.js"),
  `export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    const assetUrl = new URL(
      url.pathname === "/" ? "/index.html" : url.pathname,
      request.url,
    );
    const response = await env.ASSETS.fetch(new Request(assetUrl, request));
    if (response.status !== 404) return response;

    if (!url.pathname.includes(".")) {
      return env.ASSETS.fetch(new Request(new URL("/index.html", request.url)));
    }

    return response;
  },
};\n`,
);

console.log("AX site build created in dist/");
