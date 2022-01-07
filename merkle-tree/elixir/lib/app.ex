defmodule App do
  alias App.Transaction
  alias App.Block
  alias App.MerkleTree

  def create_block(transactions) do
    block = %Block{id: UUID.uuid4()}

    Enum.map(transactions, &Transaction.init(&1, block)) |> Enum.map(&Block.add_transaction/1)

    [[merkele_root] | _] = Block.get_transaction_hashes(block) |> MerkleTree.create()

    block |> Map.put(:merkele_root, merkele_root)
  end

  def verify_block(block) do
    [[merkele_root] | _] = Block.get_transaction_hashes(block) |> MerkleTree.create()

    block.merkele_root == merkele_root
  end
end
