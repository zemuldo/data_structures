defmodule App.MerkleTree do
  alias App.Utils
  alias App.Transaction

  def create(hashes), do: create_root([hashes])

  def verify_transaction(_, nil, _), do: nil

  def verify_transaction(transaction, position, tree) do
    current_hash = Transaction.hash(transaction)

    {_, root_hash} = List.foldr(tree, {position, current_hash}, &build_root/2)

    root_hash
  end

  defp build_root(tree_child, {position, current_hash}) when rem(position, 2) == 0 do
    next_position = (position / 2) |> floor()

    case tree_child |> Enum.at(position + 1) do
      nil ->
        {next_position, current_hash}

      pair_hash ->
        current_hash = Utils.sha256(current_hash <> pair_hash)
        {next_position, current_hash}
    end
  end

  defp build_root(tree_child, {position, current_hash}) do
    pair_hash = tree_child |> Enum.at(position - 1)
    current_hash = Utils.sha256(pair_hash <> current_hash)

    next_position = ((position - 1) / 2) |> floor()
    {next_position, current_hash}
  end

  defp create_root([[]] = tree), do: tree

  defp create_root([[_root] | _] = tree), do: tree

  defp create_root([current_nodes | _] = tree) do
    next_level_nodes = tree |> Enum.at(0) |> Enum.count() |> get_next_level_nodes()

    {_, next_level_nodes} =
      0..next_level_nodes
      |> Enum.to_list()
      |> Enum.reduce({0, []}, &create_or_append_node_hash(&1, &2, current_nodes))

    create_root([next_level_nodes] ++ tree)
  end

  defp create_or_append_node_hash(_, {position, next_level_nodes}, current_nodes) do
    current_hash = Enum.at(current_nodes, position)
    pair_hash = Enum.at(current_nodes, position + 1)

    create_node(current_hash, pair_hash, next_level_nodes, position)
  end

  defp create_node(nil, _, next_level_nodes, position) do
    {position, next_level_nodes}
  end

  defp create_node(current_hash, nil, next_level_nodes, position) do
    {position + 2, next_level_nodes ++ [current_hash]}
  end

  defp create_node(current_hash, pair_hash, next_level_nodes, position) do
    hash = Utils.sha256(current_hash <> pair_hash)
    {position + 2, next_level_nodes ++ [hash]}
  end

  defp get_next_level_nodes(current_level_nodes) do
    case rem(current_level_nodes, 2) do
      0 -> (current_level_nodes / 2) |> floor()
      _ -> ((current_level_nodes + 1) / 2) |> floor()
    end
  end
end
