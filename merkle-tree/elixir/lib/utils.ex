defmodule App.Utils do
  def sha256(data) do
    :crypto.hash_init(:sha256)
    |> :crypto.hash_update(data)
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end
end
