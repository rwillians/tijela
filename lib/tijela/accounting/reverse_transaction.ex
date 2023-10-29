defmodule Tijela.Accounting.ReverseTransaction do
  @moduledoc false

  @typedoc false
  @type t :: %Tijela.Accounting.ReverseTransaction{
          id: String.t(),
          transaction: Tijela.Accounting.Transactionable.t()
        }

  defstruct [:id, :transaction]
end

defimpl Tijela.Accounting.Transactionable,
        for: Tijela.Accounting.ReverseTransaction do
  @impl Tijela.Accounting.Transactionable
  def to_interledger_entry(%{transaction: tx}) do
    Tijela.Accounting.Transactionable.to_interledger_entry(tx)
    |> Bookk.InterledgerEntry.reverse()
  end
end
