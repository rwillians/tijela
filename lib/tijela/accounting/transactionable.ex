defprotocol Tijela.Accounting.Transactionable do
  @moduledoc """
  This protocol must be implemented by all structs that represents an
  accounting transaction (e.g.: `Tijela.Wallet.Deposit`).
  """

  @typedoc false
  @type t :: %{
          required(:__struct__) => atom,
          required(:id) => String.t(),
          optional(atom) => any
        }

  @doc """
  A function that takes the struct representing an accounting
  transaction and returns a `Bookk.InterledgerEntry` struct
  represending the journal entry or journal entries that will be
  recorded in the accounting system.
  """
  @spec to_interledger_entry(t) :: Bookk.InterledgerEntry.t()

  def to_interledger_entry(tx)
end
