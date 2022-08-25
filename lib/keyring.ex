defmodule Keyring do
  @moduledoc """
  Keyring entry point module.
  """

  alias Keyring.Crypt
  alias Keyring.CLI

  def main(argv) do

    argv |> CLI.parse() |> IO.inspect()

    # test master key
    if not File.exists?("master.key") do
      plain = IO.gets("Enter master key: ")
      master_kdf_salt = :crypto.strong_rand_bytes(32)
      hash = master_kdf_salt <> Plug.Crypto.KeyGenerator.generate(plain, master_kdf_salt, length: 64)
      hash = hash |> :base64.encode()
      |> IO.inspect()

      {:ok, io_device} = File.open("master.key", [:write])
      IO.write(io_device, hash)
      File.close(io_device)
    else
      IO.puts("Found master key! keyring is initialized")
      {:ok, io_device} = File.open("master.key", [:read])
      master_hash = IO.read(io_device, :line)
      File.close(io_device)
      IO.puts(master_hash)

      authenticate(master_hash)
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

    master = "HeyImA.HardcodedMasterKey345873485@~@/"
    plaintext_pass = IO.gets("Key to encrypt: ")
    {encrypted_key, kdf_salt} = Crypt.encrypt_key(master, plaintext_pass)
    IO.write("Encrypted key: ")
    IO.inspect(encrypted_key)
    decrypted_key = Crypt.decrypt_key(master, {encrypted_key, kdf_salt})
    IO.puts("decrypted key is:")
    IO.inspect(decrypted_key)


  end

  defp authenticate(master_hash) do
    master_hash = :base64.decode(master_hash)
    <<master_kdf_salt::binary-32, master_key_hash::binary-64>> = master_hash

    input_master_key = IO.gets("Enter master key to unlock keyring vault: ")
    input_master_key_hash = Plug.Crypto.KeyGenerator.generate(input_master_key, master_kdf_salt, length: 64)

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