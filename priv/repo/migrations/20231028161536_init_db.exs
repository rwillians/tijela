defmodule Tijela.Repo.Migrations.InitDb do
  use Ecto.Migration

  def change do
    #
    #   ACCOUNTS TABLE
    #

    create table(:accounts, primary_key: false) do
      add :id, :string, size: 255, primary_key: true
      add :ledger_id, :string, size: 48, null: false
      add :balance, :integer, null: false
      add :created_at, :utc_datetime_usec, null: false
      add :updated_at, :utc_datetime_usec, null: false
    end

    create index(:accounts, [:ledger_id])

    #
    #   ACCOUNTS TRANSACTIONS TABLE
    #

    create table(:accounts_transactions, primary_key: false) do
      add :account_id, :string, size: 255, primary_key: true
      add :transaction_id, :uuid, primary_key: true
      add :delta_amount, :integer, null: false
      add :balance_after, :integer, null: false
      add :created_at, :utc_datetime_usec, null: false
    end
  end
end
