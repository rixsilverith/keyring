[![License](https://img.shields.io/github/license/rixsilverith/keyring?color=g)](https://mit-license.org/)

# keyring: Minimal CLI utility for local key/password storage and management

A minimal keyring command-line interface (CLI) utility for local key storage and management. *keyring* aims to
be as simple and minimalist as possible while keeping keys and passwords secure. To achieve this, *keyring*
uses **AES-GCM-256**, a military-grade encryption algorithm, together with **PBKDF2-HMAC-SHA256**. The PBKDF2 algorithm
is used to derive the public key used by AES-GCM-256 for encryption/decryption from a given master password,
strengthening secrets security.

> **Note** *keyring* is currently a proof of concept under development and therefore it **should not**
be used to store critical keys and passwords. Use at your own risk. You've been warned.

---

## Usage

*keyring* can be used as
```bash
keyring <operation> <options>
```

For instance, `keyring reveal <key_name>` can be used for showing in plaintext a key with the
corresponding name.

---

## Installation

As of now, *keyring* only supports local installation. After cloning the repo, run `mix deps.get` followed by
`mix escript.build` to install the required dependencies and compile *keyring*, respectively. Then the
*keyring* CLI can be used globally by adding the cloned repo folder to the Path accordingly to your
operating system.

### Requirements

*keyring* depends on the [Plug.Crypto](https://github.com/elixir-plug/plug_crypto) and
[Optimus](https://github.com/funbox/optimus) libraries for crytography and CLI arguments parsing,
respectively.

Also, an Elixir version compiled with, at least, Erlang/OTP 24 is needed.

---

## License

*keyring* is licensed under the MIT License. See [LICENSE](LICENSE) for more information. A copy of the license can be found along with the code.
