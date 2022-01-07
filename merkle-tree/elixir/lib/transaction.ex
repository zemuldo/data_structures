defmodule App.Transaction do
  alias App.Utils

  defstruct [:id, :amount, :balance, :transacted_at, :hash, :block_id]

  def init(id, amount, balance, transacted_at, block) do
    %__MODULE__{id: id, amount: amount, balance: balance, transacted_at: transacted_at}
    |> put_hash()
    |> put_block_address(block)
  end

  def hash(t) do
    t
    |> Map.take([:id, :amount, :balance, :transacted_at])
    |> Jason.encode!()
    |> Utils.sha256()
  end

  def put_hash(t) do
    t |> Map.put(:hash, hash(t))
  end

  def put_block_address(t, block) do
    t |> Map.put(:block_id, block.id)
  end
end
