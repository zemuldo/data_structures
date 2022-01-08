defmodule AppTest do
  use ExUnit.Case

  alias App.{Transaction, Block}

   doctest App
   doctest App.MerkleTree

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

    tree = App.Block.get_transaction_hashes(block) |> App.create_merkle_tree()

    assert Enum.at(tree, 0) == [
             "a8c649cf6a9412d55b5c210a041e3a68da399b557193d96ec5a93b8d11fabcd8"
           ]
  end

  test "Merkle Tree Build Time" do
    root = App.create_merkle_root("test/hashes.txt")

    assert root == "c1ffa0ab32c7a472ec6400f6ecce10a0a10dab1840e9518ea0b9b5597675508c"
  end
end
