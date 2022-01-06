defmodule AppTest do
  use ExUnit.Case

  alias App.{Transaction, Block}

  setup_all %{} do
    block = %Block{id: UUID.uuid4()}

    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    t = Transaction.init(1, 200, 1000, datetime, block)

    {:ok, %{block: block, t: t}}
  end

  test "Add Transaction", %{block: block, t: t} do
    assert :ok == App.Block.add_transaction(t, block)

    assert 1 == App.Block.count_transactions(block)

    [transaction] = App.Block.get_transactions(block)

    assert transaction.id == t.id
    assert transaction.amount == t.amount
  end

  test "Get Block Transaction Hashes", %{block: block, t: t} do
    :ok = App.Block.add_transaction(t, block)

    [hash] = App.Block.get_transaction_hashes(block)

    assert hash == t.hash
  end
end
