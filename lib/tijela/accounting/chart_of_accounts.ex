defmodule Tijela.Accounting.ChartOfAccounts do
  @moduledoc """
  This is the map of patterns for all Ledgers and Accounts in the
  system.
  """

  @behaviour Bookk.ChartOfAccounts

  alias Bookk.AccountClass, as: C
  alias Bookk.AccountHead, as: Head

  @classes %{
    current_assets: %C{id: "CA", parent_id: "A", natural_balance: :debit, name: "Current Assets"},
    owners_equity: %C{id: "OE", parent_id: nil, natural_balance: :credit, name: "Owner's Equity"},
    liabilities: %C{id: "L", parent_id: nil, natural_balance: :credit, name: "Liabilities"}
  }

  @impl Bookk.ChartOfAccounts
  def ledger(:tijela), do: "tijela"
  def ledger({:user, <<_, _::binary>> = user_id}), do: "user(#{user_id})"

  @impl Bookk.ChartOfAccounts
  def account(:cash) do
    %Head{
      name: "cash/CA",
      class: @classes.current_assets
    }
  end

  def account(:deposits) do
    %Head{
      name: "deposits/OE",
      class: @classes.owners_equity
    }
  end

  def account({:unspent_cash, {_, _} = subject}) do
    %Head{
      name: "unspent-cash:" <> ledger(subject) <> "/L",
      class: @classes.liabilities
    }
  end

  @doc """
  Given a ledger's name and a `Bookk.AccountHead` struct, it returns
  the id of the account.
  """
  @spec account_id(ledger_name :: String.t(), account_head :: Bookk.AccountHead.t()) :: String.t()

  def account_id(<<_, _::binary>> = ledger_name, %Head{} = account_head),
    do: ledger_name <> ":" <> account_head.name

  def account_id({_, _} = ledger_code, account_code)
      when is_atom(account_code)
      when is_tuple(account_code),
      do: account_id(ledger(ledger_code), account(account_code))
end
