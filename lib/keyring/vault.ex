defmodule Keyring.Vault do
  @moduledoc """
  Keyring vault.
  """

  def insert_key(master_hash, key_name, opts) do
    IO.puts("Inserting key <#{key_name}> into the vault")
    IO.inspect(opts)
    {:ok, :key_insertion_success}
  end

  def retrieve_key(master_hash, key_name, opts) do
    IO.puts("Retrieving key <#{key_name}> from the vault")

    if Keyword.get(opts, :clipboard) do
      ["Copied ", :bright, key_name, :reset, " key to the clipboard!"]
      |> IO.ANSI.format() |> IO.puts()
    end

    IO.inspect(opts)
    {:ok, :retrieved_key_successfully}
  end
end