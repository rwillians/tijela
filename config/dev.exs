#
#   COMPILE-TIME CONFIGURATIONS
#   ===========================
#   Config overrides for `:dev` environment.
#

import Config

#
#   ECTO
#

config :tijela, Tijela.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "tijela_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  force_drop: true

#
#   LOGGER
#

config :logger, level: :info
