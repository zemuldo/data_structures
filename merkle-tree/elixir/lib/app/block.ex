defmodule App.Block do
  alias App.MerkleTree
  alias App.Transaction
  alias App.TransactionsStore

  defstruct id: nil, merkele_root: nil

  def add_transaction(%Transaction{} = t) do
    :ok = TransactionsStore.insert(t)

    {:ok, t}
  end

  def add_transaction(_) do
    :error
  end

  def verify_transaction(id, block, tree) do
    t = TransactionsStore.get(id)
    hash = Transaction.hash(t)

    index =
      block
      |> get_transaction_hashes()
      |> Enum.find_index(fn current_hash -> current_hash == hash end)

    MerkleTree.verify_transaction(t, index, tree)
  end

  def count_transactions(block) do
    TransactionsStore.count_per_block(block.id)
  end

  def get_transactions(block) do
    block.id
    |> TransactionsStore.get_by_block_id()
  end

  def get_transaction_hashes(block) do
    block.id
    |> TransactionsStore.get_hashes_by_block_id()
    |> Enum.map(fn [hash] -> hash end)
  end

  def create_merkle_tree(block) do
    get_transaction_hashes(block)
  end
end
