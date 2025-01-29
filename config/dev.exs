import Config

# DO NOT make it `:debug` or all Ecto logs will be shown for indexer
config :logger, :console, level: :info

config :logger_json, :backend, level: :none

config :logger, :ecto,
       level: :debug,
       path: Path.absname("logs/dev/ecto.log")

config :logger, :error, path: Path.absname("logs/dev/error.log")

config :logger, :account,
  level: :debug,
  path: Path.absname("logs/dev/account.log"),
  metadata_filter: [fetcher: :account]

# Phoenix Endpoint Configuration for Hot Code Reloading
config :block_scout_web, BlockScoutWeb.Endpoint,
       http: [ip: {0, 0, 0, 0}, port: 4000],
       code_reloader: true,
       debug_errors: true,
       check_origin: false,
       watchers: [
         # Recompile assets with Webpack when files change
         node: [
           "node_modules/webpack/bin/webpack.js",
           "--mode",
           "development",
           "--watch",
           "--watch-options-stdin",
           cd: Path.expand("../apps/block_scout_web/assets", __DIR__)
         ]
       ],
       https: false
