defmodule Tijela.WalletTest do
  use Tijela.DataCase, async: true

  import Uuid, only: [uuid: 0]

  describe "Tijela.Wallet.deposit_balance/2" do
    test "adds balance to a user's account" do
      user_id = uuid()

      assert 0        = Tijela.Wallet.get_balance(user_id)
      assert {:ok, _} = Tijela.Wallet.deposit_balance(user_id, 500_00)
      assert 500_00   = Tijela.Wallet.get_balance(user_id)
    end
  end

  describe "Tijela.Wallet.transfer_balance/3" do
    test "transfers money from a user to another" do
      sender_id = uuid()
      recipient_id = uuid()

      {:ok, _} = Tijela.Wallet.deposit_balance(sender_id, 300_00)

      assert {:ok, _} = Tijela.Wallet.transfer_balance(sender_id, 250_00, to: recipient_id)
      assert 50_00    = Tijela.Wallet.get_balance(sender_id)
      assert 250_00   = Tijela.Wallet.get_balance(recipient_id)
    end

    test "fails if sender doesn't have enough balance" do
      sender_id = uuid()
      recipient_id = uuid()

      assert {:error, :insufficient_balance} =
               Tijela.Wallet.transfer_balance(sender_id, 10_00, to: recipient_id)
    end
  end

  describe "Tijela.Wallet.get_transactions_history/1" do
    test "lists the change in a wallet's balance (desc)" do
      user_a_id = uuid()
      user_b_id = uuid()

      {:ok, _} = Tijela.Wallet.deposit_balance(user_a_id, 250_00)
      {:ok, _} = Tijela.Wallet.deposit_balance(user_a_id, 250_00)
      {:ok, _} = Tijela.Wallet.transfer_balance(user_a_id, 300_00, to: user_b_id)

      assert %{
        items: [
          %{
            delta_amount: -300_00,
            balance_after: 200_00
          },
          %{
            delta_amount: 250_00,
            balance_after: 500_00
          },
          %{
            delta_amount: 250_00,
            balance_after: 250_00
          }
        ]
      } = Tijela.Wallet.get_transactions_history(user_a_id)

      assert %{
        items: [
          %{
            delta_amount: 300_00,
            balance_after: 300_00
          }
        ]
      } = Tijela.Wallet.get_transactions_history(user_b_id)
    end
  end

  describe "Tijela.Wallet.get_transactions_history/2" do
    test "gets the history of changes in wallet's balance (paginated)" do
      user_a_id = uuid()
      user_b_id = uuid()

      {:ok, _} = Tijela.Wallet.deposit_balance(user_a_id, 250_00)
      {:ok, _} = Tijela.Wallet.deposit_balance(user_a_id, 250_00)
      {:ok, _} = Tijela.Wallet.transfer_balance(user_a_id, 300_00, to: user_b_id)

      assert %{
        items: [
          %{
            delta_amount: -300_00,
            balance_after: 200_00
          },
          %{
            delta_amount: 250_00,
            balance_after: 500_00
          }
        ]
      } = Tijela.Wallet.get_transactions_history(user_a_id, limit: 2)

      assert %{
        items: [
          %{
            delta_amount: 250_00,
            balance_after: 250_00
          }
        ]
      } = Tijela.Wallet.get_transactions_history(user_a_id, offset: 2)
    end
  end

  describe "Tijela.Wallet.refund_transfer/1" do
    test "sender gets its money back when recipient user has enough balance" do
      sender_id = uuid()
      recipient_id = uuid()

      {:ok, _}           = Tijela.Wallet.deposit_balance(sender_id, 500_00)
      {:ok, transfer_ab} = Tijela.Wallet.transfer_balance(sender_id, 350_00, to: recipient_id)
      150_00             = Tijela.Wallet.get_balance(sender_id)
      350_00             = Tijela.Wallet.get_balance(recipient_id)

      assert {:ok, _} = Tijela.Wallet.refund_transfer(transfer_ab)
      assert 500_00   = Tijela.Wallet.get_balance(sender_id)
      assert 0        = Tijela.Wallet.get_balance(recipient_id)
    end

    test "fails if recipient user doesn't have enough balance" do
      user_a_id = uuid()
      user_b_id = uuid()
      user_c_id = uuid()

      {:ok, _}           = Tijela.Wallet.deposit_balance(user_a_id, 500_00)
      {:ok, transfer_ab} = Tijela.Wallet.transfer_balance(user_a_id, 350_00, to: user_b_id)
      {:ok, _}           = Tijela.Wallet.transfer_balance(user_b_id, 50_00, to: user_c_id)

      assert {:error, :insufficient_balance} = Tijela.Wallet.refund_transfer(transfer_ab)
    end
  end

  test "no double-spending here" do
    sender_id = uuid()
    recipient_id = uuid()

    {:ok, _} = Tijela.Wallet.deposit_balance(sender_id, 500_00)

    tasks =
      for _ <- 1..20 do
        Task.async(fn ->
          Process.sleep(Enum.random(0..5))
          Tijela.Wallet.transfer_balance(sender_id, 100_00, to: recipient_id)
        end)
      end

    Process.sleep(10)

    results =
      for(task <- tasks, do: Task.await(task))
      |> Enum.sort()

    assert [
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:error, :insufficient_balance},
             {:ok, _},
             {:ok, _},
             {:ok, _},
             {:ok, _},
             {:ok, _}
           ] = results

    assert Tijela.Wallet.get_balance(sender_id) == 0
    assert Tijela.Wallet.get_balance(recipient_id) == 500_00
  end
end
