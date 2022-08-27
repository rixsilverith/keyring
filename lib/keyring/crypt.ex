defmodule Keyring.Crypt do
  @moduledoc """
  Cryptography module for Keyring.
  """

  alias Plug.Crypto.KeyGenerator, as: Pbkdf2

  @kdf_salt_bytes 16
  @aes_iv_bytes 16
  @aes_key_length_bytes 32
  @aes_auth_data "AES256GCM"

  # just a placeholder for random password generation
  def generate_random_string(length) do
    symbols = '0123456789abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@/.'
    symbol_count = Enum.count(symbols)
    s = for _ <- 1..length, into: "", do: <<Enum.at(symbols, :crypto.rand_uniform(0, symbol_count))>>
    s
  end

  def pbkdf2_hash(cleartext, salt, hash_len) when is_binary(salt) do
    Pbkdf2.generate(cleartext, salt, length: hash_len)
  end

  def pbkdf2_hash(cleartext, salt_len, hash_len) when is_number(salt_len) do
    kdf_salt = :crypto.strong_rand_bytes(salt_len)
    hash = Pbkdf2.generate(cleartext, kdf_salt, length: hash_len)
    {hash, kdf_salt}
  end

  @spec encrypt_key(binary(), String.t()) :: binary()
  def encrypt_key(master_key, cleartext) do
    kdf_salt = :crypto.strong_rand_bytes(@kdf_salt_bytes)
    aes_key = Pbkdf2.generate(master_key, kdf_salt, length: @aes_key_length_bytes)
    kdf_salt <> aes_256_gcm_encrypt(cleartext, aes_key)
    |> :base64.encode()
  end

  @spec decrypt_key(binary(), binary()) :: String.t()
  def decrypt_key(master_key, ciphertext) do
    ciphertext = ciphertext |> :base64.decode()
    <<kdf_salt::binary-16, ciphertext::binary>> = ciphertext

    aes_key = Pbkdf2.generate(master_key, kdf_salt, length: @aes_key_length_bytes)
    aes_256_gcm_decrypt(ciphertext, aes_key)
  end

  @spec aes_256_gcm_encrypt(String.t(), binary()) :: binary()
  defp aes_256_gcm_encrypt(cleartext, aes_key) do
    iv = :crypto.strong_rand_bytes(@aes_iv_bytes)

    {ciphertext, icv} =
      :crypto.crypto_one_time_aead(:aes_256_gcm, aes_key, iv, cleartext, @aes_auth_data, true)
    iv <> icv <> ciphertext
    |> :base64.encode()
  end

  @spec aes_256_gcm_decrypt(binary(), binary()) :: String.t()
  defp aes_256_gcm_decrypt(ciphertext, aes_key) do
    ciphertext = :base64.decode(ciphertext)
    <<iv::binary-16, icv::binary-16, ciphertext::binary>> = ciphertext

    :crypto.crypto_one_time_aead(:aes_256_gcm, aes_key, iv, ciphertext, @aes_auth_data, icv, false)
  end
end