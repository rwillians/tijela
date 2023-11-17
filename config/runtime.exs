#
#   RUNTIME CONFIGURATIONS
#   ======================
#   Applies to all environments.
#

import Config

#
#   ECTO
#

case config_env() do
  :dev ->
    database_url =
      System.get_env("DEV_DATABASE_URL") ||
        System.get_env("DATABASE_URL") ||
        "postgres://postgres:postgres@localhost:5432/tijela_dev"

    config :tijela, Tijela.Repo,
      url: database_url,
      stacktrace: true,
      show_sensitive_data_on_connection_error: true,
      pool_size: 10,
      force_drop: true

  :test ->
    database_url =
      System.get_env("TEST_DATABASE_URL") ||
        "postgres://postgres:postgres@localhost:5432/tijela_test"

    config :tijela, Tijela.Repo,
      url: database_url,
      pool: Ecto.Adapters.SQL.Sandbox,
      pool_size: 10,
      force_drop: true

  _ ->
    database_url =
      System.get_env("DATABASE_URL") ||
        raise """
        environment variable DATABASE_URL is missing.
        For example: ecto://USER:PASS@HOST/DATABASE
        """

    maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []
    pool_size = String.to_integer(System.get_env("POOL_SIZE") || "10")

    config :tijela, Tijela.Repo,
      url: database_url,
      pool_size: pool_size,
      socket_options: maybe_ipv6,
      ssl: true
end
