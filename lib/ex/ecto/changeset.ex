defmodule Ex.Ecto.Changeset do
  @moduledoc false

  import Ecto.Changeset, only: [traverse_errors: 2]
  import Keyword, only: [get: 3]
  import Regex, only: [replace: 3]
  import String, only: [to_existing_atom: 1]

  alias Ecto.Changeset

  @doc false
  def to_errors_by_field(%Changeset{} = changeset) do
    traverse_errors(changeset, fn {message, opts} ->
      replace(~r"%{(\w+)}", message, fn _substring, key ->
        key = to_existing_atom(key)

        opts
        |> get(key, key)
        |> to_string()
      end)
    end)
  end
end
