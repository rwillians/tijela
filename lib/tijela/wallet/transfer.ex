defmodule Tijela.Wallet.Transfer do
  @moduledoc """
  Represents a transfer of funds from one user's wallet to another.
  """

  @typedoc false
  @type t :: %Tijela.Wallet.Transfer{
          id: String.t(),
          sender_id: String.t(),
          recipient_id: String.t(),
          amount: pos_integer
          #       ↑ in cents or smallest unit supported by the
          #         currency being used
        }

  defstruct [:id, :sender_id, :recipient_id, :amount]
end

defimpl Tijela.Accounting.Transactionable, for: Tijela.Wallet.Transfer do
  use Bookk.Notation

  @impl Tijela.Accounting.Transactionable
  def to_interledger_entry(tx) do
    journalize! using: Tijela.Accounting.ChartOfAccounts do
      on ledger({:user, tx.sender_id}) do
        debit account(:deposits), tx.amount
        credit account(:cash), tx.amount
      end

      on ledger({:user, tx.recipient_id}) do
        debit account(:cash), tx.amount
        credit account(:deposits), tx.amount
      end

      on ledger(:tijela) do
        debit account({:unspent_cash, {:user, tx.sender_id}}), tx.amount
        credit account({:unspent_cash, {:user, tx.recipient_id}}), tx.amount
      end
    end
  end
end
