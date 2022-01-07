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
    assert :ok == App.Block.add_transaction(t)

    assert 1 == App.Block.count_transactions(block)

    [transaction] = App.Block.get_transactions(block)

    assert transaction.id == t.id
    assert transaction.amount == t.amount
  end

  test "Get Block Transaction Hashes", %{block: block, t: t} do
    :ok = App.Block.add_transaction(t)

    [hash] = App.Block.get_transaction_hashes(block)

    assert hash == t.hash
  end

  test "Create Merkle Tree" do
    block = %Block{id: UUID.uuid4()}

    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    1..10
    |> Enum.to_list()
    |> Enum.map(fn n ->
      App.Block.add_transaction(
        Transaction.init(n * 4, n * 200, n * 1000, Timex.shift(datetime, hours: n), block)
      )
    end)

    assert 10 == App.Block.count_transactions(block)

    tree = App.Block.get_transaction_hashes(block) |> App.MerkleTree.create()

    assert Enum.at(tree, 0) == [
             "a8c649cf6a9412d55b5c210a041e3a68da399b557193d96ec5a93b8d11fabcd8"
           ]
  end

  test "Very Transaction" do
    block = %Block{id: UUID.uuid4()}

    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    1..100
    |> Enum.to_list()
    |> Enum.map(fn n ->
      App.Block.add_transaction(
        Transaction.init(n * 4, n * 200, n * 1000, Timex.shift(datetime, hours: n), block)
      )
    end)

    tree = App.Block.get_transaction_hashes(block) |> App.MerkleTree.create()
    n = 9

    root =
      Block.verify_transaction(
        Transaction.init(n * 4, n * 200, n * 1000, Timex.shift(datetime, hours: n), block),
        block,
        tree
      )

    assert root == tree |> Enum.at(0) |> Enum.at(0)

    n = 99

    root =
      Block.verify_transaction(
        Transaction.init(n * 4, n * 200, n * 1000, Timex.shift(datetime, hours: n), block),
        block,
        tree
      )

    assert root == tree |> Enum.at(0) |> Enum.at(0)

    # Change the balance of a transaction
    root =
      Block.verify_transaction(
        Transaction.init(n * 4, n * 200, n * 2000, Timex.shift(datetime, hours: n), block),
        block,
        tree
      )

      assert root != tree |> Enum.at(0) |> Enum.at(0)
  end
end
