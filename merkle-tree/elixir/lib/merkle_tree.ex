defmodule App.MerkleTree do
  
  alias App.Utils
  alias App.Transaction

  def create(hashes) when is_binary(hashes) do
    {:ok, contents} = File.read(hashes)

    hashes = contents |> String.split("\n", trim: true)

    create(hashes)
  end

  def create(hashes), do: build_tree([hashes])

  def verify_transaction(_, nil, _), do: nil

  def verify_transaction(transaction, position, tree) do
    current_hash = Transaction.hash(transaction)

    {_, root_hash} = List.foldr(tree, {position, current_hash}, &build_root/2)

    root_hash
  end

  defp build_root(tree_child, {position, current_hash}) when rem(position, 2) == 0 do
    next_position = div(position, 2)

    current_hash = Utils.hash_pair([current_hash, Enum.at(tree_child, position + 1)])

    {next_position, current_hash}
  end

  defp build_root(tree_child, {position, current_hash}) do
    current_hash = Utils.hash_pair([Enum.at(tree_child, position - 1), current_hash])

    next_position = div((position - 1), 2)
    {next_position, current_hash}
  end

  defp build_tree([[]] = tree), do: tree

  defp build_tree([[_root] | _] = tree), do: tree

  defp build_tree([current_nodes | _] = tree) do
    current_nodes
    |> Enum.chunk_every(2)
    |> Enum.map(&Utils.hash_pair/1)
    |> (&([&1] ++ tree)).()
    |> build_tree()
  end
end
