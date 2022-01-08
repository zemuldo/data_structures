defmodule App do

  @moduledoc """
  This is a module that provides simple blockchain example
  with Merkle trees.

  Using the following technology mocks:
    - Using :ets module for transaction store.
    - Using sha256 for hashing.

  Providing the following functionalities.
    - create a block.
    - add transactions to a block.
    - Create Block Tree.
    - verify block.
    - Create Block Root Hash.

   This is a raw implementation focusing on performamnce, understanding merkle trees and not security.
   Consider checking out my article on this at https://zemuldo.com/blog
  """

  alias App.Transaction
  alias App.Block
  alias App.MerkleTree

  def create_block(transactions) do
    block = %Block{id: UUID.uuid4()}

    Enum.map(transactions, &Transaction.init(&1, block)) |> Enum.map(&Block.add_transaction/1)

    [[merkele_root] | _] = Block.get_transaction_hashes(block) |> MerkleTree.create_tree()

    block |> Map.put(:merkele_root, merkele_root)
  end

  def verify_block(block) do
    [[merkele_root] | _] = Block.get_transaction_hashes(block) |> MerkleTree.create_tree()

    block.merkele_root == merkele_root
  end

  @doc """
  Generates a Merkle Tree and returns the root hash.

  Takes a .txt filepath for a file that contains hash strings in each line or a list of hashes.
  Returns root hash :: `String.t()`.

  ## Examples

      iex> hashes = [
      iex>             "8ca4e01e7e6604235b87793dbc0600a30690607b32b9803dbf1fd7c14c87ffa9",
      iex>             "4669795e97cc87cdfed515147b29ceb131c31604233f51c5ccb325e06fdd23d8",
      iex>             "72ed2d7304873d39f05784cd11e4a910a44e964ccc58c5550aca50cd14bcb085",
      iex>             "ddd9c1f94df79edf8c253e1266f5d456ca8123641b9e57186a80231c9867c711",
      iex>             "594c61e01fb1df9dab41d1455522d9b0fc2ca3eceddc7df6a7e9052b70b6a60e"
      iex>           ]
      ["8ca4e01e7e6604235b87793dbc0600a30690607b32b9803dbf1fd7c14c87ffa9",
      "4669795e97cc87cdfed515147b29ceb131c31604233f51c5ccb325e06fdd23d8",
      "72ed2d7304873d39f05784cd11e4a910a44e964ccc58c5550aca50cd14bcb085",
      "ddd9c1f94df79edf8c253e1266f5d456ca8123641b9e57186a80231c9867c711",
      "594c61e01fb1df9dab41d1455522d9b0fc2ca3eceddc7df6a7e9052b70b6a60e"]
      iex> App.create_merkle_root(hashes)
      "2df16be3e8f1bb5d469f0d3902d91716627872099f5a2f683e7828b26376a794"
      iex> App.create_merkle_root("test/hashes.txt")
      "c1ffa0ab32c7a472ec6400f6ecce10a0a10dab1840e9518ea0b9b5597675508c"

  """
  @spec create_merkle_root((hashes_file_path :: String.t()) | (hashes :: list(String.t()))) ::  String.t()
  defdelegate create_merkle_root(hashes), to: MerkleTree, as: :create_root

  @doc """
  Generates a Merkle Tree and returns the root hash.

  Takes a .txt filepath for a file that contains hash strings in each line or a list of hashes.
  Returns root hash :: `String.t()`.

  ## Examples

      iex> hashes = [
      iex>             "8ca4e01e7e6604235b87793dbc0600a30690607b32b9803dbf1fd7c14c87ffa9",
      iex>             "4669795e97cc87cdfed515147b29ceb131c31604233f51c5ccb325e06fdd23d8",
      iex>             "72ed2d7304873d39f05784cd11e4a910a44e964ccc58c5550aca50cd14bcb085",
      iex>             "ddd9c1f94df79edf8c253e1266f5d456ca8123641b9e57186a80231c9867c711",
      iex>             "594c61e01fb1df9dab41d1455522d9b0fc2ca3eceddc7df6a7e9052b70b6a60e"
      iex>           ]
      ["8ca4e01e7e6604235b87793dbc0600a30690607b32b9803dbf1fd7c14c87ffa9",
      "4669795e97cc87cdfed515147b29ceb131c31604233f51c5ccb325e06fdd23d8",
      "72ed2d7304873d39f05784cd11e4a910a44e964ccc58c5550aca50cd14bcb085",
      "ddd9c1f94df79edf8c253e1266f5d456ca8123641b9e57186a80231c9867c711",
      "594c61e01fb1df9dab41d1455522d9b0fc2ca3eceddc7df6a7e9052b70b6a60e"]
      iex> App.create_merkle_tree(hashes) |> Enum.at(0)
      ["2df16be3e8f1bb5d469f0d3902d91716627872099f5a2f683e7828b26376a794"]
      iex> App.create_merkle_tree("test/hashes.txt") |> Enum.at(0)
      ["c1ffa0ab32c7a472ec6400f6ecce10a0a10dab1840e9518ea0b9b5597675508c"]

  """
  @spec create_merkle_tree((hashes_file_path :: String.t()) | (hashes :: list(String.t()))) ::  list(list(String.t()))
  defdelegate create_merkle_tree(hashes), to: MerkleTree, as: :create_tree
end
