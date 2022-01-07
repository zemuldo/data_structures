defmodule App.Block do
  alias App.MerkleTree
  alias App.Transaction
  alias App.TransactionsServer

  defstruct id: nil, merkel_root: nil

  def add_transaction(%Transaction{} = t) do
    TransactionsServer.insert(t)
  end

  def add_transaction(_) do
    :error
  end

  def verify_transaction(t, block, tree) do
    hash = Transaction.hash(t)

    index =
      block
      |> get_transaction_hashes()
      |> Enum.find_index(fn current_hash -> current_hash == hash end)

    MerkleTree.verify_transaction(t, index, tree)
  end

  def count_transactions(block) do
    TransactionsServer.count_per_block(block)
  end

  def get_transactions(block) do
    block
    |> TransactionsServer.get_by_block_id()
    |> Enum.map(fn [id, amount, balance, transacted_at, hash] ->
      %Transaction{
        id: id,
        amount: amount,
        balance: balance,
        transacted_at: transacted_at,
        hash: hash,
        block_id: block.id
      }
    end)
  end

  def get_transaction_hashes(block) do
    block
    |> TransactionsServer.get_hashes_by_block_id()
    |> Enum.map(fn [hash] -> hash end)
  end

  def create_merkle_tree(block) do
    get_transaction_hashes(block)
  end
end
