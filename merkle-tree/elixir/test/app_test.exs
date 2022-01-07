defmodule AppTest do
  use ExUnit.Case

  alias App.{Transaction, Block}

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

  test "Create Merkle Tree" do
    block = %Block{id: UUID.uuid4()}

    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    1..10
    |> Enum.to_list()
    |> Enum.map(fn n ->
      App.Block.add_transaction(
        Transaction.init(
          %{
            id: n * 4,
            amount: n * 200,
            balance: n * 1000,
            transacted_at: Timex.shift(datetime, hours: n)
          },
          block
        )
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

    tree = App.Block.get_transaction_hashes(block) |> App.MerkleTree.create()
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

  test "Create, Verify Block - Valid" do
    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    transactions =
      1..100
      |> Enum.to_list()
      |> Enum.map(
        &%{
          id: &1 * 4,
          amount: &1 * 200,
          balance: &1 * 1000,
          transacted_at: Timex.shift(datetime, hours: &1)
        }
      )

    block = App.create_block(transactions)

    assert App.verify_block(block)
  end

  test "Create, Verify Block - Invalid" do
    {:ok, datetime, 0} = DateTime.from_iso8601("2022-01-06T00:00:00Z")

    transactions =
      1..100
      |> Enum.to_list()
      |> Enum.map(
        &%{
          id: &1 * 4,
          amount: &1 * 200,
          balance: &1 * 1000,
          transacted_at: Timex.shift(datetime, hours: &1)
        }
      )

    block = App.create_block(transactions)

    n = 99
     Transaction.init(
      %{
        id: n * 4,
        amount: n * 200,
        balance: n * 4000,
        transacted_at: Timex.shift(datetime, hours: n)
      },
      block
    )
    |> App.Block.add_transaction()

    refute App.verify_block(block)
  end

  test "Merkle Tree Build Time" do

    tree = App.MerkleTree.create("test/hashes.txt")

    assert tree |> Enum.at(0) |> Enum.at(0) == "c1ffa0ab32c7a472ec6400f6ecce10a0a10dab1840e9518ea0b9b5597675508c"
  end
end
