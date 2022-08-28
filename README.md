[![License](https://img.shields.io/github/license/rixsilverith/keyring?color=g)](https://mit-license.org/)

# keyring: Minimal CLI utility for local key/password storage and management

A minimal keyring command-line interface (CLI) utility for local key storage and management. *keyring* aims to
be as simple and minimalist as possible while keeping keys and passwords secure. Its features include:

- **AES symmetric encryption.** *keyring* uses AES-GCM-256 (AES using Galois/Counter mode with a 256-bit public key)
to encrypt and decrypt the stored secrets.
- **PBKDF2.** *keyring* uses the PBKDF2-HMAC-SHA256 algorithm to derive the AES encryption/decryption public key
for each secret from a previously established master secret.
- **Simple storage format.** Each secret in the keyring vault is stored in its own separate file under the
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
where `operation` is one of the following:

**Operation** | **Description**
--- | ---
`init` | Initialize the keyring vault by providing a master secret used to encrypt and decrypt the stored secrets.
`insert <key_name>` | Insert a secret with name `key_name` into the vault. The secret is generated automatically.
`reveal <key_name> [-c\|--clipboard] [-s\|--seconds <secs>]` | Reveal the secret with `key_name`. If the `-c` option is given, the secret is copied to the clipboard, which is cleared after `secs` (default: 30) seconds if the `-s` option is provided.
`help` | Show help message.

Note that the master secret must be provided to perform each operation.

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
