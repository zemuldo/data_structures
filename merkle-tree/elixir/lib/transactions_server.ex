defmodule App.TransactionsServer do
  use GenServer

  alias App.Block

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

  def count() do
    f =
      fun do
        {_, _, _, _, _, _} -> true
      end

    :ets.select_count(@table_name, f)
  end

  def count_per_block(%Block{id: id}) do
    f =
      fun do
        {_, _, _, _, _, block_id} when block_id == ^id -> true
      end

    :ets.select_count(@table_name, f)
  end

  def insert(t) do
    GenServer.call(App.TransactionsServer, {:add_transaction, t})
  end

  def get_by_block_id(%Block{id: id}) do
    :ets.match(@table_name, {:"$1", :"$2", :"$3", :"$4", :"$5", id})
  end

  def get_hashes_by_block_id(%Block{id: id}) do
    :ets.match(@table_name, {:_, :_, :_, :_, :"$5", id})
  end
end
