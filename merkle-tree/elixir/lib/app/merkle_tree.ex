defmodule App.MerkleTree do

  @moduledoc """
   Merkle Tree implementation in Elixir.
   Merkle Tree or Merkle Root.
  """

  alias App.Utils
  alias App.Transaction

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
      iex> App.MerkleTree.create_root(hashes)
      "2df16be3e8f1bb5d469f0d3902d91716627872099f5a2f683e7828b26376a794"
      iex> App.MerkleTree.create_root("test/hashes.txt")
      "c1ffa0ab32c7a472ec6400f6ecce10a0a10dab1840e9518ea0b9b5597675508c"

  """

  @spec create_root((hashes_file_path :: String.t()) | (hashes :: list(String.t()))) ::  String.t()
  def create_root(hashes) do
    hashes
    |> create()
    |> Enum.at(0)
    |> Enum.at(0)
  end

   @doc """
  Generates a Merkle Tree and returns the tree.

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
      iex> App.MerkleTree.create_tree(hashes) |> Enum.at(0)
      ["2df16be3e8f1bb5d469f0d3902d91716627872099f5a2f683e7828b26376a794"]
      iex> App.MerkleTree.create_tree("test/hashes.txt") |> Enum.at(0)
      ["c1ffa0ab32c7a472ec6400f6ecce10a0a10dab1840e9518ea0b9b5597675508c"]

  """

  @spec create_tree((hashes_file_path :: String.t()) | (hashes :: list(String.t()))) ::  list(list(String.t()))
  def create_tree(hashes), do: create(hashes)

  def verify_transaction(_, nil, _), do: nil

  def verify_transaction(transaction, position, tree) do
    current_hash = Transaction.hash(transaction)

    {_, root_hash} = List.foldr(tree, {position, current_hash}, &build_root/2)

    root_hash
  end

  # Stream the file for the first operation and chunk for better
  # performamnce when the file is large
  # then pipe the result as the initial tree leafs
  defp create(hashes) when is_binary(hashes) do
     File.stream!(hashes)
    |> Stream.map(&String.trim/1)
    |> Stream.chunk_every(2)
    |> Stream.map(&Utils.hash_pair(&1))
    |> Enum.to_list()
    |> (&([&1])).()
    |> build_tree()
  end

  # Pipe the hashes as the initial tree leafs
  defp create(hashes), do: build_tree([hashes])

  defp build_root(tree_child, {position, current_hash}) when rem(position, 2) == 0 do
    next_position = div(position, 2)

    current_hash = Utils.hash_pair([current_hash, Enum.at(tree_child, position + 1)])

    {next_position, current_hash}
  end

  defp build_root(tree_child, {position, current_hash}) do
    current_hash = Utils.hash_pair([Enum.at(tree_child, position - 1), current_hash])

    next_position = div(position - 1, 2)
    {next_position, current_hash}
  end

  # Build the merkle tree by 
  defp build_tree([[]] = tree), do: tree

  defp build_tree([[_root] | _] = tree), do: tree

  # Chunk every 2 to avoid having to run a recursive call
  defp build_tree([current_nodes | _] = tree) do
    current_nodes
    |> Enum.chunk_every(2)
    |> Enum.map(&Utils.hash_pair/1)
    |> (&([&1] ++ tree)).()
    |> build_tree()
  end
end
