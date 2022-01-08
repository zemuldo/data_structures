defmodule App.Utils do

  @moduledoc """
  Utilities module for hashing.
  """

  @doc """
  Generate sha256 of a binary.

   ## Examples

      iex> App.Utils.sha256("a")
      "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
  """
  @spec sha256(binary()) ::  String.t()
  def sha256(data) do
    :crypto.hash_init(:sha256)
    |> :crypto.hash_update(data)
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  @doc """
  Generate sha256 hash of a a pair of hashes or returns left item if right is nil.

  ## Examples

      iex> App.Utils.hash_pair(["a"])
      "a"
      iex> App.Utils.hash_pair(["a", nil])
      "a"
      iex> App.Utils.hash_pair(["a", "b"])
      "fb8e20fc2e4c3f248c60c39bd652f3c1347298bb977b8b4d5903b85055620603"
  """
  @spec hash_pair(list(binary())) ::  String.t()
  def hash_pair([left]) do
    left
  end

  def hash_pair([left, nil]) do
    left
  end

  def hash_pair([left, right]) do
    sha256(left <> right)
  end
end
