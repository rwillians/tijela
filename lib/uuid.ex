defmodule Uuid do
  @moduledoc false

  @doc false
  @spec uuid() :: String.t()

  defdelegate uuid, to: Ex.Ecto.ULID, as: :generate
end
