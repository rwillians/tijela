#
#   RUNTIME CONFIGURATIONS
#   ======================
#

import Config

#
#   ECTO
#

if config_env() not in [:dev, :test] do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []
  pool_size = String.to_integer(System.get_env("POOL_SIZE") || "10")

  config :tijela, Tijela.Repo,
    ssl: true,
    url: database_url,
    pool_size: pool_size,
    socket_options: maybe_ipv6
end
