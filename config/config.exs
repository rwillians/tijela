#
#   COMPILE-TIME CONFIGURATIONS
#   ===========================
#   Base configs
#

import Config

#
#   ECTO
#

config :tijela,
  ecto_repos: [Tijela.Repo],
  generators: [timestamp_type: :utc_datetime_usec]

#
#   LOGGER
#

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

#
#   CONFIG OVERRIDES PER ENVIRONMENT
#

case config_env() do
  :dev  -> import_config("dev.exs")
  :test -> import_config("test.exs")
  _     -> import_config("remote.exs")
end
