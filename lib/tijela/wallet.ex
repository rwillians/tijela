defmodule Tijela.Wallet do
  @moduledoc false

  alias Tijela.Accounting
  alias Tijela.Accounting.ChartOfAccounts
  alias Tijela.Wallet.Deposit
  alias Tijela.Wallet.Transfer

  @repo Tijela.Repo

  @doc false
  @spec deposit_balance(user_id :: String.t(), amount :: pos_integer) ::
          {:ok, tx :: Tijela.Accounting.Transactionable.t()}
          | {:error, term}

  #                            ↓ em centavos ou menor unidade da moeda utilizada
  def deposit_balance(user_id, amount) do
    Accounting.transact(%Deposit{
      user_id: user_id,
      amount: amount
    })
  end

  @doc false
  @spec get_balance(repo :: module, user_id :: String.t()) :: integer

  def get_balance(repo \\ @repo, <<_, _::binary>> = user_id) do
    ChartOfAccounts.account_id({:user, user_id}, :cash)
    |> Accounting.get_account_balance(repo)
  end

  @doc false
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

  @doc false
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
