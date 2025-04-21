const esbuild = require("esbuild")
const postcss = require("esbuild-postcss")
const { globSync } = require("glob")
const tailwindConfig = require("./tailwind.config")
const fs = require("fs")

const args = process.argv.slice(2)
const watch = args.includes("--watch")
const deploy = args.includes("--deploy")

const loader = {
  ".png": "file",
  ".woff2": "file",
  ".ttf": "file"
}

const cssWatchPaths = tailwindConfig.content.flatMap((pattern) => {
  return globSync(pattern, { ignore: "node_modules/**" })
})

const watchPlugin = {
  name: "customWatch",
  setup: (build) => {
    build.onResolve({ filter: /\/css\/app\.css/ }, (args) => {
      return { watchFiles: cssWatchPaths }
    })
  }
}

let opts = {
  entryPoints: ["entry/app.tsx"],
  bundle: true,
  metafile: true,
  outdir: "../priv/static/assets",
  plugins: [postcss(), watchPlugin],
  loader,
  external: ["/fonts/*", "/images/*"],
  assetNames: "[ext]/[name]-[hash]",
  publicPath: "/assets/",
  logLevel: "info"
}

if (watch) {
  opts = {
    ...opts,
    watch,
    sourcemap: "inline"
  }
}

if (deploy) {
  opts = {
    ...opts,
    minify: true
  }
}

const promise = esbuild.build(opts)

if (watch) {
  promise.then((_result) => {
    process.stdin.on("close", () => {
      process.exit(0)
    })

    process.stdin.resume()
  })
} else {
  promise.then((result) => {
    fs.writeFileSync("meta.json", JSON.stringify(result.metafile))
  })
}
