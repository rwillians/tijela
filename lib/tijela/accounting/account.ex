defmodule Tijela.Accounting.Account do
  @moduledoc """
  Provides accounts for the accounting system.

  There's no table for Ledgers, only accounts. To get all accounts
  from a ledger, simply query for all accounts with the `ledger_id`
  (where `ledger_id` is a deterministic value that you can get by
  calling `Tijela.Accounting.ChartOfAccounts.ledger/1`).
  """

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

  def changeset(%Account{} = value \\ %Account{}, %{} = fields) do
    value
    |> cast(fields, [:id, :ledger_id, :balance, :created_at, :updated_at])
    |> validate_required([:id, :ledger_id, :balance, :created_at, :updated_at])
  end
end
