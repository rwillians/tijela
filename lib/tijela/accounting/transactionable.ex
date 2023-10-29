defprotocol Tijela.Accounting.Transactionable do
  @moduledoc false

  @typedoc false
  @type t :: %{
          required(:__struct__) => atom,
          required(:id) => String.t(),
          optional(atom) => any
        }

  @doc false
  @spec to_interledger_entry(t) :: Bookk.InterledgerEntry.t()

  def to_interledger_entry(tx)
end
