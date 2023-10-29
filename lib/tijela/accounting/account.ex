defmodule Tijela.Accounting.Account do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__, as: Account

  @typedoc false
  @type t :: %Tijela.Accounting.Account{
          id: String.t(),
          ledger_id: String.t(),
          balance: integer,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key false
  schema "accounts" do
    field :id, :string, primary_key: true
    field :ledger_id, :string
    field :balance, :integer
    field :created_at, :utc_datetime_usec
    field :updated_at, :utc_datetime_usec
  end

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()

  @all_fields [:id, :ledger_id, :balance, :created_at, :updated_at]

  def changeset(%Account{} = value \\ %Account{}, %{} = fields) do
    value
    |> cast(fields, @all_fields)
    |> validate_required(@all_fields)
  end
end
