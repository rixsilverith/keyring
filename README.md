[![License](https://img.shields.io/github/license/rixsilverith/keyring?color=g)](https://mit-license.org/)

# keyring: Minimal CLI utility for local key/password storage and management

A minimal keyring command-line interface (CLI) utility for local key storage and management. *keyring* aims to
be as simple and minimalist as possible while keeping keys and passwords secure. Its features include:

- **AES symmetric encryption.** *keyring* uses AES-GCM-256 (AES using Galois/Counter mode with a 256-bit public key)
to encrypt and decrypt the stored secrets.
- **PBKDF2.** *keyring* uses the PBKDF2-HMAC-SHA256 algorithm to derive the AES encryption/decryption public key
for each secret from a previously established master secret.
- **Simple storage format.** Each secret in the keyring vault is stored in its own separate file in YAML format under the
`keyring/vault` folder, which can be easily backed up or version controlled using Git.
- **Clipboard management.** When revealing a secret from the vault it can optionally be copied to the clipboard,
which is cleared after a given timeout.
- **Random string generator.** *keyring* has an integrated random string generator, useful for generating strong
random passwords.

> **Note** *keyring* is currently a proof of concept under development and therefore it **should not**
be used to store critical keys and passwords. Use at your own risk. You've been warned.

---

## Usage

```bash
keyring <operation> [<options>...]
```
where `operation` either `init`, `insert` or `reveal`. Each of them is detailed below.

> **Note** One can get specific help for each operation as `keyring help <operation>`. Running
> `keyring help` gives a general help message for *keyring*.

### Initializing the keyring vault

A *keyring* vault must be initialized before storing any secrets in it. The vault is just a folder where the
files containing the encrypted secrets are kept. Initialization is performed as `keyring init`. This will
ask for a master secret to be entered, which is needed to afterwards unlock the vault each time an operation
is performed on the keyring (for instance, revealing a stored secret).

### Inserting a secret into the vault

`keyring insert <secret_name> [-i|--input]` is used to insert a secret into the vault, which will be identified as `secret_name`. By default, a random string is generated and saved as the secret. However,
this behaviour can be overriden by specifying the `-i` option. This way, the secret will be entered
as `stdin`.

As secrets are stored as YAML files, additional metadata can be attached to them (for instance, emails,
usernames, etc.).

### Revealing a secret from the vault

A secret can be revealed with `keyring reveal <secret_name> [-c|--clipboard [-s|--seconds <secs>]]`,
where `secret_name` is the secret identification. If the `-c` option is given, the secret will be copied
to the clipboard, which is cleared after `secs` (default: 30) seconds if the `-s` option is provided,
instead of being printed to `stdout`. Note that the`-s` option has no effect if `-c` is omitted.

---

## Installation

As of now, *keyring* only supports local installation. After cloning the repo, run `mix deps.get` followed by
`mix escript.build` to install the required dependencies and compile *keyring*, respectively. Then the
*keyring* CLI can be used globally by adding the cloned repo folder to the Path accordingly to your
operating system.

### Requirements

*keyring* depends on the [Plug.Crypto](https://github.com/elixir-plug/plug_crypto) and
[OK](https://github.com/CrowdHailer/OK) libraries for the PBKDF2 crytographic function implementation and better
error handling, respectively.

Also, an Elixir version compiled with, at least, Erlang/OTP 24 is needed.

---

## License

*keyring* is licensed under the MIT License. See [LICENSE](LICENSE) for more information. A copy of
the license can be found along with the code.
