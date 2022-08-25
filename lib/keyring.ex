defmodule Keyring do
  @moduledoc """
  Keyring main module.
  """

  alias Keyring.Crypt
  alias Keyring.CLI

  @master_key_hash_file "auth_token"

  @doc """
  Keyring CLI entry point.
  """
  def main(argv) do

    argv |> CLI.parse() |> IO.inspect()

    case is_initialized?() do
      #false -> request_keyring_initialization()
      false -> initialize_keyring()
      _ -> retrieve_master_key() |> authenticate()
    end

    """
    argv = CLI.parse(argv)
    case argv do
      {[:init], args} ->

      {[:insert], args} ->

      {[:reveal], args} ->
    end
    """

    #test

    """
    master = "HeyImA.HardcodedMasterKey345873485@~@/"
    plaintext_pass = IO.gets("Key to encrypt: ")
    {encrypted_key, kdf_salt} = Crypt.encrypt_key(master, plaintext_pass)
    IO.write("Encrypted key: ")
    IO.inspect(encrypted_key)
    decrypted_key = Crypt.decrypt_key(master, {encrypted_key, kdf_salt})
    IO.puts("decrypted key is:")
    IO.inspect(decrypted_key)
    """
  end

  defp is_initialized?, do: File.exists?(@master_key_hash_file)

  defp request_keyring_initialization do
    IO.puts("keyring has not been initialized. Please, run `keyring init` before performing any other operation.")
    System.halt(1)
  end

  defp initialize_keyring do
    if is_initialized? do
      IO.puts("keyring has already been initialized.")
      System.halt(0)
    end

    {:ok, io_device} = File.open(@master_key_hash_file, [:write])

    input_master_key = IO.gets("Enter the master key that will be used to unlock the keyring vault: ")
    {master_key_hash, kdf_salt} = Crypt.pbkdf2_hash(input_master_key, 32, 64)

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
    master_hash = :base64.decode(master_hash)
    <<master_kdf_salt::binary-32, master_key_hash::binary-64>> = master_hash

    input_master_key = IO.gets("Enter master key to unlock keyring vault: ")
    input_master_key_hash = Crypt.pbkdf2_hash(input_master_key, master_kdf_salt, 64)
    #input_master_key_hash = Plug.Crypto.KeyGenerator.generate(input_master_key, master_kdf_salt, length: 64)

    master_key_hash = :base64.encode(master_key_hash)
    input_master_key_hash = :base64.encode(input_master_key_hash)

    cond do
      master_key_hash == input_master_key_hash ->
        IO.puts("Authenticated successfully")
        :ok
      true ->
        IO.puts("Incorrect master key")
        :error
    end
  end
end