#
#   COMPILE-TIME CONFIGURATIONS
#   ===========================
#   Config overrides for `:test` environment.
#

import Config

#
#   ECTO
#

config :tijela, Tijela.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tijela_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  force_drop: true

#
#   LOGGER
#

config :logger, level: :warning
