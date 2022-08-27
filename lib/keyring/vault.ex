defmodule Keyring.Vault do
  @moduledoc """
  Keyring vault.
  """

  def insert_key(master_hash, key_name, opts) do
    if exists_key(key_name) do
      error_msg = ["Key ", :bright, key_name, :reset, " already exists in the vault"]
      |> IO.ANSI.format() |> List.to_string()
      Keyring.Utils.puts(:error, error_msg)
      System.halt(0)
    end

    random_string = Keyring.Crypt.generate_random_string(32)
    encrypted_key = Keyring.Crypt.encrypt_key(master_hash, random_string)

    {:ok, io_device} = File.open("vault/#{key_name}.key", [:write])
    IO.write(io_device, encrypted_key)
    File.close(io_device)

    ["Key ", :bright, key_name, :reset, " inserted into the keyring vault"]
    |> IO.ANSI.format() |> IO.puts()

    {:ok, :key_insertion_success}
  end

  def retrieve_key(master_hash, key_name, opts) do
    if not exists_key(key_name) do
      error_msg = ["Key ", :bright, key_name, :reset, " does not exist in the vault"]
      |> IO.ANSI.format() |> List.to_string()
      Keyring.Utils.puts(:error, error_msg)
      System.halt(0)
    end

    {:ok, io_device} = File.open("vault/#{key_name}.key", [:read])
    encrypted_key = IO.read(io_device, :line)
    plain_key = Keyring.Crypt.decrypt_key(master_hash, encrypted_key)

    if Keyword.get(opts, :clipboard) do
      clipboard_secs = Keyword.get(opts, :seconds)
      clipboard_secs = case clipboard_secs do
        nil -> 30
        _ -> clipboard_secs
      end

      ["Copied ", :bright, key_name, :reset, " key to the clipboard! Clipboard will be cleared in ",
       :bright, "#{clipboard_secs}", :reset, " seconds"]
      |> IO.ANSI.format() |> IO.puts()
      plain_key |> Keyring.Utils.clipboard_copy()

      {:ok, file} = File.open("clean_clipboard.sh", [:write])
      IO.write(file, "sleep #{clipboard_secs}; xclip -sel clip < /dev/null")
      File.close(file)

      # FIXME: For some reason, clean_clipboard.sh is not removed after cleaning the clipboard
      # For now, this is just a minor inconvenience
      Port.open({:spawn, "sh clean_clipboard.sh; rm clean_clipboard.sh"}, [:binary])
      |> Port.close()
    else
      ["Retrieved key ", :bright, key_name, :reset, " from keyring vault:"]
      |> IO.ANSI.format() |> IO.puts()
      IO.puts(plain_key)
    end

    {:ok, :retrieved_key_successfully}
  end

  defp exists_key(key_name) do
    File.exists?("vault/#{key_name}.key")
  end
end