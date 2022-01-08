defmodule App.TransactionsStore do

  @moduledoc """
  Genserver for interacting with ets store.
  """

  use GenServer

  alias App.Transaction

  import Ex2ms

  @table_name :equilibrium

  @impl true
  def init(_) do
    :ets.new(@table_name, [:set, :named_table, read_concurrency: true])

    {:ok, []}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def handle_call({:add_transaction, t}, _from, state) do
    true =
      :ets.insert(@table_name, {t.id, t.amount, t.balance, t.transacted_at, t.hash, t.block_id})

    {:reply, :ok, state}
  end

  @doc """
  Count transactions for a block
  """
  def count_per_block(id) do
    f =
      fun do
        {_, _, _, _, _, block_id} when block_id == ^id -> true
      end

    :ets.select_count(@table_name, f)
  end

  @doc """
  Add a new transaction.
  """
  def insert(t) do
    GenServer.call(App.TransactionsStore, {:add_transaction, t})
  end

  @doc """
  Get transaction by id
  """
  def get(id) do
    case :ets.match(@table_name, {id, :"$1", :"$2", :"$3", :"$4", :"$5"}) do
      [t] ->
        [:amount, :balance, :transacted_at, :hash, :block_id]
        |> zip_transaction(t, %{id: id})

      _ ->
        nil
    end
  end

  @doc """
  Get all transactions that belong to a block
  """
  def get_by_block_id(id) do
    keys = [:id, :amount, :balance, :transacted_at, :hash]

    :ets.match(@table_name, {:"$1", :"$2", :"$3", :"$4", :"$5", id})
    |> Enum.map(&zip_transaction(keys, &1, %{block_id: id}))
  end

  @doc """
  Get hashes of all transactions that belong to a block
  """
  def get_hashes_by_block_id(id) do
    :ets.match(@table_name, {:_, :_, :_, :_, :"$5", id})
  end

  defp zip_transaction(keys, t, meta) do
    keys
    |> Enum.zip(t)
    |> Enum.into(%{})
    |> Map.merge(meta)
    |> to_transaction_struct()
  end

  defp to_transaction_struct(t) do
    struct!(%Transaction{}, t)
  end
end
