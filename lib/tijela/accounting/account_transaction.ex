defmodule Tijela.Accounting.AccountTransaction do
  @moduledoc """
  Records a history of changes to an account's balance, cause by
  accounting transactions.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__, as: AccountTransaction

  @typedoc false
  @type t :: %Tijela.Accounting.AccountTransaction{
          account_id: String.t(),
          transaction_id: Ecto.UUID.t(),
          delta_amount: integer,
          balance_after: integer,
          created_at: DateTime.t()
        }

  @primary_key false
  schema "accounts_transactions" do
    field :account_id, :string, primary_key: true
    field :transaction_id, Ecto.UUID, primary_key: true
    field :delta_amount, :integer
    field :balance_after, :integer
    field :created_at, :utc_datetime_usec
  end

  @doc false
  @spec changeset(t, map) :: Ecto.Changeset.t()

  @all_fields [:account_id, :transaction_id, :delta_amount, :balance_after, :created_at]

  def changeset(%AccountTransaction{} = value \\ %AccountTransaction{}, %{} = fields) do
    value
    |> cast(fields, @all_fields)
    |> validate_required(@all_fields)
  end
end
