defmodule App.MerkleTreeTest do
  use ExUnit.Case

  alias App.{Transaction, Block}

   doctest App
   doctest App.MerkleTree

  test "Create Merkle Tree - Hashes" do
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

    tree = App.Block.get_transaction_hashes(block) |> App.MerkleTree.create_tree()

    assert Enum.at(tree, 0) == [
             "a8c649cf6a9412d55b5c210a041e3a68da399b557193d96ec5a93b8d11fabcd8"
           ]
  end

  test "Create Merkle Tree - Hash File" do
    root = App.MerkleTree.create_root("test/hashes.txt")

    assert root == "c1ffa0ab32c7a472ec6400f6ecce10a0a10dab1840e9518ea0b9b5597675508c"
  end
end
