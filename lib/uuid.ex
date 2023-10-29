defmodule Uuid do
  @moduledoc false

  @doc false
  @spec uuidv4() :: String.t()

  defdelegate uuidv4, to: Ecto.UUID, as: :generate
end
