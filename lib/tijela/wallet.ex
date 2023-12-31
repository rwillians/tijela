defmodule Tijela.Wallet do
  @moduledoc """
  The Wallet feature is how users interact with their money.
  """

  alias Tijela.Accounting
  alias Tijela.Accounting.ChartOfAccounts
  alias Tijela.Wallet.Deposit
  alias Tijela.Wallet.Transfer

  @repo Tijela.Repo

  @doc """
  Creates and commits a transaction for a user depositing money into
  their wallet.
  """
  @spec deposit_balance(user_id :: String.t(), amount :: pos_integer) ::
          {:ok, tx :: Tijela.Accounting.Transactionable.t()}
          | {:error, term}

  def deposit_balance(<<_, _::binary>> = user_id, amount) do
    #           in cents or the smallest fraction ↑
    #           of the currency being used
    Accounting.transact(%Deposit{
      user_id: user_id,
      amount: amount
    })
  end

  @doc """
  Get's the displayable balance of a user's wallet.

  By displayable balance I mean the cash balance from the user's
  ledger.
  """
  @spec get_balance(repo :: module, user_id :: String.t()) :: integer

  def get_balance(repo \\ @repo, <<_, _::binary>> = user_id) do
    ChartOfAccounts.account_id({:user, user_id}, :cash)
    |> Accounting.get_account_balance(repo)
  end

  @doc """
  Get's the history of balance changes for a given user's wallet.
  Sorted by most recent transactions first.

  We don't need to expose all accounts to the user, that's why we're
  only taking the history for the user's cash account.

  ## Known Issue

  The results doesn't specify what was each transaction (e.g.: deposit
  and to whom it was made). A solution would be persisting the
  transaction struct so that we have that info at disposal.
  """
  @spec get_transactions_history(user_id :: String.t(), Ex.Ecto.Pagination.pagination_control()) ::
          Ex.Ecto.Pagination.Page.t(Tijela.Accounting.AccountTransaction.t())

  def get_transactions_history(<<_, _::binary>> = user_id, pagination_control \\ []) do
    ChartOfAccounts.account_id({:user, user_id}, :cash)
    |> Accounting.get_account_transactions(pagination_control)
  end

  @doc """
  Refunds a transfer that was previously made.
  """
  @spec refund_transfer(Tijela.Wallet.Transfer.t()) ::
          {:ok, tx :: Tijela.Accounting.ReverseTransaction.t()}
          | {:error, :insufficient_balance}
          | {:error, term}

  def refund_transfer(%Transfer{} = tx) do
    @repo.transaction(fn repo ->
      case get_balance(repo, tx.recipient_id) < tx.amount do
        true -> {:error, :insufficient_balance}
        false -> Accounting.revert(repo, tx)
      end
    end)
    |> to_normalized_result()
  end

  @doc """
  Transfers balance from a user's wallet to another as long a the user
  sending the money has enough balance.
  """
  @spec transfer_balance(sender_id :: String.t(), amount :: pos_integer,
          to: recipient_id :: String.t()
        ) ::
          {:ok, tx :: Tijela.Accounting.Transactionable.t()}
          | {:error, :insufficient_balance}
          | {:error, term}

  def transfer_balance(sender_id, amount, to: recipient_id) do
    @repo.transaction(fn repo ->
      case get_balance(repo, sender_id) < amount do
        true ->
          {:error, :insufficient_balance}

        false ->
          Accounting.transact(repo, %Transfer{
            sender_id: sender_id,
            recipient_id: recipient_id,
            amount: amount
          })
      end
    end)
    |> to_normalized_result()
  end

  #
  #   PRIVATE
  #

  defp to_normalized_result({:ok, {:ok, _} = result}), do: result
  defp to_normalized_result({:ok, {:error, _} = result}), do: result
  defp to_normalized_result({:error, _} = result), do: result
end
