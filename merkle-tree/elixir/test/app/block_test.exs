defmodule App.BlockTest do
  use ExUnit.Case

  alias App.{Transaction, Block}

  doctest App
  doctest App.MerkleTree

  setup_all %{} do
    block = %Block{id: UUID.uuid4()}

    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    t = Transaction.init(%{id: 1, amount: 200, balance: 1000, transacted_at: datetime}, block)

    {:ok, %{block: block, t: t}}
  end

  test "Add Transaction", %{block: block, t: t} do
    assert {:ok, t} == App.Block.add_transaction(t)

    assert 1 == App.Block.count_transactions(block)

    [transaction] = App.Block.get_transactions(block)

    assert transaction.id == t.id
    assert transaction.amount == t.amount
  end

  test "Get Block Transaction Hashes", %{block: block, t: t} do
    {:ok, _} = App.Block.add_transaction(t)

    [hash] = App.Block.get_transaction_hashes(block)

    assert hash == t.hash
  end

  test "Very Transaction" do
    block = %Block{id: UUID.uuid4()}

    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    1..100
    |> Enum.to_list()
    |> Enum.map(fn n ->
      Transaction.init(
        %{
          id: n * 4,
          amount: n * 200,
          balance: n * 1000,
          transacted_at: Timex.shift(datetime, hours: n)
        },
        block
      )
      |> App.Block.add_transaction()
    end)

    tree = App.Block.get_transaction_hashes(block) |> App.MerkleTree.create_tree()
    n = 9

    root = Block.verify_transaction(n * 4, block, tree)

    assert root == tree |> Enum.at(0) |> Enum.at(0)

    n = 50

    root = Block.verify_transaction(n * 4, block, tree)

    assert root == tree |> Enum.at(0) |> Enum.at(0)

    n = 99

    Transaction.init(
      %{
        id: n * 4,
        amount: n * 200,
        balance: n * 2000,
        transacted_at: Timex.shift(datetime, hours: n)
      },
      block
    )
    |> App.Block.add_transaction()

    root = Block.verify_transaction(n * 4, block, tree)

    assert root != tree |> Enum.at(0) |> Enum.at(0)
  end
end
