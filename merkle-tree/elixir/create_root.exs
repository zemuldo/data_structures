alias App.MerkleTree

with [path] when is_binary(path) <- System.argv() do
  root = path |> MerkleTree.create_root()

  IO.puts(root)
else
  _ -> IO.puts(:error)
end
