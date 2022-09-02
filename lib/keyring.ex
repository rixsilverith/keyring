defmodule Keyring do
  @moduledoc """
  Keyring main module.
  """

  require OK
  use OK.Pipe

  @master_key_hash_file "auth_token"

  @doc """
  Keyring CLI entry point.
  """
  def main(argv) do
    Application.put_env(:elixir, :ansi_enabled, true)
    argv = Keyring.CLI.parse(argv)

    case argv do
      {:init, _, _} ->
        case is_initialized?() do
          {:ok, _} -> {:error, :keyring_already_initialized} |> error_handler()
          {:error, _} -> initialize_keyring() |> error_handler()
        end

      {:insert, key_name, args} ->
        is_initialized?() ~>> authenticate() ~>> Keyring.Vault.insert_key(key_name, args) |> error_handler()

      {:reveal, key_name, args} ->
        is_initialized?() ~>> authenticate() ~>> Keyring.Vault.retrieve_key(key_name, args) |> error_handler()

      {:help, operation, _} -> Keyring.CLI.help(operation)

      _ -> IO.inspect(argv)
    end
  end

  defp error_handler(result) do
    case result do
      {:error, :incorrect_master_key} ->
        [:bright, :red, "! Error: ", :reset, "The provided master key is not correct. Please, try again."]
        |> IO.ANSI.format() |> IO.puts()

      {:error, :keyring_not_initialized} ->
        [:bright, :red, "! Error: ", :reset, "keyring has not been initialized. ",
         "Please, run ", :bright, "keyring init", :reset, " before performing any operation."]
        |> IO.ANSI.format() |> IO.puts()

      {:error, :keyring_already_initialized} ->
        [:bright, :red, "! Error: ", :reset, "keyring has already been initialized."]
        |> IO.ANSI.format() |> IO.puts()

      {:ok, _} -> nil
    end
  end

  defp is_initialized? do
    case File.exists?(@master_key_hash_file) do
      true -> {:ok, retrieve_master_key()}
      false -> {:error, :keyring_not_initialized}
    end
  end

  defp initialize_keyring do
    {:ok, io_device} = File.open(@master_key_hash_file, [:write])

    input_master_key = Keyring.Utils.puts(:hidden_input, "Enter the master key that will be used to unlock the keyring vault: ")
    {master_key_hash, kdf_salt} = Keyring.Crypt.pbkdf2_hash(input_master_key, 32, 64)

    master_hash = kdf_salt <> master_key_hash
    master_hash = :base64.encode(master_hash)
    IO.write(io_device, master_hash)
    File.close(io_device)

    IO.puts("keyring has been successfully initialized")
    System.halt(0)
  end

  defp retrieve_master_key do
    {:ok, io_device} = File.open(@master_key_hash_file, [:read])
    master_hash = IO.read(io_device, :line)
    File.close(io_device)
    master_hash
  end

  defp authenticate(master_hash) do
    master_hash = master_hash |> :base64.decode()
    <<master_kdf_salt::binary-32, master_key_hash::binary-64>> = master_hash

    input_master_key = Keyring.Utils.puts(:hidden_input, "Enter master key to unlock keyring vault: ")
    input_master_key_hash = Keyring.Crypt.pbkdf2_hash(input_master_key, master_kdf_salt, 64)

    cond do
      master_key_hash == input_master_key_hash -> {:ok, master_hash}
      true -> {:error, :incorrect_master_key}
    end
  end
end