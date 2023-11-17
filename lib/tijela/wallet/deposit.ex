defmodule Tijela.Wallet.Deposit do
  @moduledoc """
  Represents balanced deposited by a user into their own wallet.
  """

  @typedoc false
  @type t :: %Tijela.Wallet.Deposit{
          id: String.t(),
          user_id: String.t(),
          amount: pos_integer
        }

  defstruct [:id, :user_id, :amount]
end

defimpl Tijela.Accounting.Transactionable, for: Tijela.Wallet.Deposit do
  use Bookk.Notation

  @impl Tijela.Accounting.Transactionable
  def to_interledger_entry(tx) do
    journalize! using: Tijela.Accounting.ChartOfAccounts do
      on ledger({:user, tx.user_id}) do
        debit account(:cash), tx.amount
        credit account(:deposits), tx.amount
      end

      on ledger(:tijela) do
        debit account(:cash), tx.amount
        credit account({:unspent_cash, {:user, tx.user_id}}), tx.amount
      end
    end
  end
end
