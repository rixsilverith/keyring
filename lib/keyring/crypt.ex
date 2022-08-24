defmodule Keyring.Crypt do
    @moduledoc """
    Cryptography module for Keyring
    """

    alias Plug.Crypto.KeyGenerator, as: Pbkdf2

    @aes_auth_data "AES256GCM"

    def encrypt_key(master_key, cleartext) do
        #kdf_salt = Pbkdf2.Base.gen_salt(salt_len: 16) 
        kdf_salt = :crypto.strong_rand_bytes(16)
        #aes_key = Pbkdf2.Base.hash_password(master_key, kdf_salt, digest: :sha256)
        aes_key = Pbkdf2.generate(master_key, kdf_salt, length: 32)
        |> :base64.encode()
        {aes_256_gcm_encrypt(cleartext, aes_key), kdf_salt}
    end

    def decrypt_key(master_key, {ciphertext, kdf_salt}) do
        #aes_key = Pbkdf2.Base.hash_password(master_key, kdf_salt, digest: :sha256)
        aes_key = Pbkdf2.generate(master_key, kdf_salt, length: 32)
        |> :base64.encode()
        aes_256_gcm_decrypt(ciphertext, aes_key)
    end

    defp aes_256_gcm_encrypt(cleartext, aes_key) do
        aes_key = :base64.decode(aes_key)
        iv = :crypto.strong_rand_bytes(16)

        {ciphertext, icv} =
            :crypto.crypto_one_time_aead(:aes_256_gcm, aes_key, iv, cleartext, @aes_auth_data, true)
        iv <> icv <> ciphertext
        |> :base64.encode()


        #payload = {@aes_auth_data, to_string(cleartext), 16}
        #{ciphertext, icv} = :crypto.block_encrypt(:aes_gcm, aes_key, payload)
        #iv <> icv <> ciphertext
        #|> :base64.encode()
    end

    defp aes_256_gcm_decrypt(ciphertext, aes_key) do
        aes_key = :base64.decode(aes_key)
        ciphertext = :base64.decode(ciphertext)
        <<iv::binary-16, icv::binary-16, ciphertext::binary>> = ciphertext

        :crypto.crypto_one_time_aead(:aes_256_gcm, aes_key, iv, ciphertext, @aes_auth_data, icv, false)


        #payload = {@aes_auth_data, ciphertext, icv}
        #:crypto.block_decrypt(:aes_gcm, aes_key, iv, payload)
    end
end