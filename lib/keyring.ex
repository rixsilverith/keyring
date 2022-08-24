defmodule Keyring do
  @moduledoc """
  Keyring entry point module.
  """
  
  alias Keyring.Crypt

  def main(argv) do
    cli_config = Optimus.new!(name: "keyring",
      description: "Just a simple keyring",
      version: "0.1.0",
      allow_unknown_args: false,
      parse_double_dash: true,
      subcommands: [
        insert: [
          name: "insert",
          about: "Insert a new key in the keyring."
        ],
        show: [
          name: "show",
          about: "Show a decrypted key for a service",
          args: [
            name: [
              value_name: "key_name",
              help: "Key identifier",
              required: true
            ]
          ]
        ]
      ])

    #args = Optimus.parse!(cli_config, argv)
    #case args do
    #  %{args: %{}} -> Optimus.parse!(cli_config, ["--help"])
    #  {[:insert], args} -> Vault.insert_key()
    #  other -> IO.inspect(other)ex_crypto
    #end
  
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
end