defmodule Tijela.Accounting do
  @moduledoc """
  This module provides the "lower level" APIs used by `Tijela.Wallet`.
  """

  import Bookk.InterledgerEntry, only: [to_journal_entries: 1]
  import Bookk.JournalEntry, only: [to_operations: 1]
  import Bookk.Operation, only: [to_delta_amount: 1]
  import Ecto.Query
  import Ex.Ecto.Changeset, only: [to_errors_by_field: 1]
  import Ex.Ecto.Pagination, only: [paginate: 3]
  import Tijela.Accounting.ChartOfAccounts, only: [account_id: 2]
  import Tijela.Accounting.Transactionable, only: [to_interledger_entry: 1]
  import Uuid, only: [uuid: 0]

  alias Bookk.Operation, as: Op
  alias Tijela.Accounting.Account
  alias Tijela.Accounting.AccountTransaction
  alias Tijela.Accounting.ReverseTransaction

  @repo Tijela.Repo

  @doc """
  Get the balance of a given account.
  If the account doesn't exist, `0` (zero) will be returned.
  """
  @spec get_account_balance(account_id :: String.t(), repo :: module) :: integer

  def get_account_balance(<<_, _::binary>> = account_id, repo \\ @repo) do
    maybe_balance =
      from(a in Account, where: a.id == ^account_id, select: a.balance)
      |> repo.one()

    case maybe_balance do
      nil -> 0
      balance when is_integer(balance) -> balance
    end
  end

  @doc """
  Get's the history of balance changes for a given account.
  Sorted by most recent (`created_at`) first.

  ## Known issue

  Paginating DESC using `limit` and `offset` is prone to return
  duplicated results as new transactions are commited to the database.
  A solution would be using a cursor-based pagination.
  """
  @spec get_account_transactions(account_id :: String.t(), Ex.Ecto.Pagination.pagination_control()) ::
          Ex.Ecto.Pagination.Page.t(Tijela.Accounting.AccountTransaction.t())

  def get_account_transactions(<<_, _::binary>> = account_id, pagination_control \\ [])
      when is_list(pagination_control) do
    query =
      from record in AccountTransaction,
        where: record.account_id == ^account_id,
        #                  UUID v7 is time-based, therefore it's safe
        #                ↓ to sort by it.
        order_by: [desc: record.transaction_id]

    paginate(@repo, query, pagination_control)
  end

  @doc """
  Takes a transactionable struct then commits a transaction that
  reverses it.
  """
  @spec revert(tx, repo :: module) :: {:ok, tx} | {:error, term}
        when tx: Tijela.Accounting.Transactionable.t()

  def revert(repo \\ @repo, %_{} = tx),
    do: transact(repo, %ReverseTransaction{id: uuid(), transaction: tx})

  @doc """
  Persists the effects of a transactionable struct into the database.
  """
  @spec transact(tx, repo :: module) :: {:ok, tx} | {:error, term}
        when tx: Tijela.Accounting.Transactionable.t()

  def transact(repo \\ @repo, tx)
  def transact(repo, %_{id: nil} = tx), do: transact(repo, %{tx | id: uuid()})

  def transact(repo, %_{id: _} = tx) do
    interledger_entry = to_interledger_entry(tx)
    now = DateTime.utc_now()

    multis =
      for {ledger_name, journal_entry} <- to_journal_entries(interledger_entry),
          op <- to_operations(journal_entry),
          do: op_to_multi(op, ledger_name, tx.id, now)

    multi =
      multis
      |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append(&2, &1))

    case repo.transaction(multi) do
      {:ok, _result} -> {:ok, tx}
      {:error, _, changeset, _} -> {:error, to_errors_by_field(changeset)}
    end
  end

  #
  #   PRIVATE
  #

  defp op_to_multi(%Op{} = op, ledger_name, tx_id, now) do
    multi_a_name = uuid()
    multi_b_name = uuid()

    account_id = account_id(ledger_name, op.account_head)
    delta_amount = to_delta_amount(op)

    account_changeset =
      Account.changeset(%{
        id: account_id,
        ledger_id: ledger_name,
        balance: delta_amount,
        created_at: now,
        updated_at: now
      })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(multi_a_name, account_changeset,
      conflict_target: :id,
      on_conflict: [
        inc: [balance: delta_amount],
        set: [updated_at: now]
      ],
      returning: [:balance]
    )
    |> Ecto.Multi.insert(multi_b_name, fn %{^multi_a_name => updated_account} ->
      AccountTransaction.changeset(%{
        account_id: account_id,
        transaction_id: tx_id,
        delta_amount: delta_amount,
        balance_after: updated_account.balance,
        created_at: now
      })
    end)
  end
end
