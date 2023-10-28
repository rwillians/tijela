defmodule Tijela.Repo do
  use Ecto.Repo,
    otp_app: :tijela,
    adapter: Ecto.Adapters.Postgres
end
