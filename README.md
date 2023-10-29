# Tijela

## TL;DR:

Confira o arquivo [`test/tijela/wallet_test.exs`](https://github.com/rwillians/tijela/blob/simples/test/tijela/wallet_test.exs).


## Introdução

Essa base de código demonstra a implementação de 3 casos de uso utilizando a
biblioteca [Bookk](https://github.com/rwillians/bookk):
-   **Depósito**: usuário deposita saldo em sua própria conta (`Tijela.Wallet.deposit_balance/2`).

    ```elixir
    user_id = Uuid.uuidv4()

    0        = Tijela.Wallet.get_balance(user_id)
    {:ok, _} = Play.deposit_balance(user_id, 500_00)
    500_00   = Tijela.Wallet.get_balance(user_id)
    ```

    _Unidades em centavos ou menor fração da moeda utilizada._

-   **Transferência**: um usuário transfere saldo para outro usuário (`Tijela.Wallet.transfer_balance/3`);

    ```elixir
    sender_id = Uuid.uuidv4()
    recipient_id = Uuid.uuidv4()

    {:ok, _} = Play.deposit_balance(sender_id, 500_00)
    {:ok, _} = Play.transfer_balance(sender_id, 300_00, to: recipient_id)

    200_00 = Tijela.Wallet.get_balance(sender_id)
    300_00 = Tijela.Wallet.get_balance(recipient_id)
    ```

-   **Estorno**: estorna uma transferência (`Tijela.Wallet.refund_transfer/1`).

    ```elixir
    user_a_id = Uuid.uuidv4()
    user_b_id = Uuid.uuidv4()
    user_c_id = Uuid.uuidv4()

    {:ok, _}           = Play.deposit_balance(user_a_id, 500_00)
    {:ok, transfer_ab} = Play.transfer_balance(user_a_id, 300_00, to: user_b_id)
    {:ok, transfer_bc} = Play.transfer_balance(user_b_id, 50_00, to: user_c_id)

    200_00 = Tijela.Wallet.get_balance(user_a_id)
    250_00 = Tijela.Wallet.get_balance(user_b_id)
    50_00  = Tijela.Wallet.get_balance(user_c_id)

    {:error, :insufficient_balance} = Play.refund_transfer(transfer_ab)
    {:ok, _}                        = Play.refund_transfer(transfer_bc)
    {:ok, _}                        = Play.refund_transfer(transfer_ab)

    500_00 = Tijela.Wallet.get_balance(user_a_id)
    0      = Tijela.Wallet.get_balance(user_b_id)
    0      = Tijela.Wallet.get_balance(user_c_id)
    ```


## Como funciona?

Ao chamar `Tijela.Accounting.transact/1`, deve ser passada uma struct a qual implementa o protocolo `Tijela.Accounting.Transactionable`. Utilizando a função `to_interledger_entry/1` do protocolo, a struct é transformada em uma `Bookk.InterledgerEntry`, que é um conjunto de _**Journal Entry**_ o qual pode afetar multiplos ledgers em uma única transação.

A interledger é transformada em uma lista de _journal entries_ (`Bookk.JournalEntry`) que, então, são transformadas em uma lista de operações (`Bookk.Operation`), onde cada operação representa uma alteração de saldo em uma única conta.

Para cada operação são produzidas duas _queries_:
1.  **Upsert da conta**: caso a conta (`Tijela.Accounting.Account`) já exista, incrementa o saldo e atualiza o campo `updated_at`, do contrário cria a conta;
2.  **Insere uma linha de log**: insere uma `Tijela.Accounting.AccountTransaction` a qual serve como um log de uma transação contábil executada contra uma conta. Essa struct contem o valor da alteração de saldo (`delta_amount`) da conta e a quantidade de saldo que ficou na conta após a alteração (`balance_after`).

`Ecto.Multi` é utilizado para agregar todas as operações necessárias em uma única transação.


## Setup

```sh
git clone git@github.com:rwillians/tijela.git && \
  cd tijela && \
  git fetch && \
  git checkout simples
```

```sh
asdf install
```

```sh
# requer postgres rodando localmente -- veja `config/dev.exs`
mix setup
```

```sh
iex -S mix
```