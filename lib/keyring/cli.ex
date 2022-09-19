defmodule Keyring.CLI do
  @moduledoc """
  Keyring CLI parser.
  """

  @keyring_operations [:init, :insert, :reveal]

  def parse([operation | args]) do
    operation = operation |> String.to_existing_atom()
    case operation do
      :init -> parse_init_operation(args)
      :insert -> parse_insert_operation(args)
      :reveal -> parse_reveal_operation(args)
      :help -> parse_help(args)
    end
  end

  defp parse_init_operation(opts) do
    strict_opts = []
    aliases = []

    {opts, _, _} = OptionParser.parse(opts, aliases: aliases, strict: strict_opts)
    {:init, "", opts}
  end

  defp parse_insert_operation(opts) do
    strict_opts = [input: :boolean]
    aliases = [i: :input]

    [key_name | opts] = opts
    {opts, _, _} = OptionParser.parse(opts, aliases: aliases, strict: strict_opts)
    {:insert, key_name, opts}
  end

  defp parse_reveal_operation(opts) do
    strict_opts = [clipboard: :boolean, seconds: :integer]
    aliases = [c: :clipboard, s: :seconds]

    [key_name | opts] = opts
    {opts, _, _} = OptionParser.parse(opts, aliases: aliases, strict: strict_opts)
    {:reveal, key_name, opts}
  end

  defp parse_help([operation_name | _]) do
    {:help, String.to_existing_atom(operation_name), []}
  end

  defp parse_help(_opts), do: {:help, :keyring, []}

  defp help_header do
    """
    keyring: Minimal CLI utility for local key/password storage and management
    A detailed information page is available at https://github.com/rixsilverith/keyring
    Commit SHA1 hash: #{Keyring.Utils.get_commit_hash()}
    """
  end

  def help(:keyring) do
    """
    #{help_header()}
    Usage: keyring <operation> [<options>...]
    where <operation> is one of the following:

    init                                 Initialize the keyring vault.
    insert <key_name> [-i]               Insert a key into the keyring vault.
    reveal <key_name> [-c [-s <secs>]]   Reveal the key <key_name>.
    help [operation]                     Show this help message.

    For more information about a specific operation run: keyring help <operation>
    """
    |> IO.puts()
  end

  def help(:insert) do
    """
    #{help_header()}
    Usage: keyring insert <key_name> [-i|--input]

    Insert a secret <key_name> into the keyring vault. By default, a random secret is
    generated. However, this behaviour can be overriden by providing the -i option.
    """
    |> IO.puts()
  end

  def help(:reveal) do
    """
    #{help_header()}
    Usage: keyring reveal <key_name> [-c|--clipboard [-s|--timeout <secs>]]

    Reveal the secret <key_name> from the keyring vault. Optionally, the secret
    can be copied to the system clipboard instead of being printed to the termimal
    by specifying the -c option. In that case, the clipboard is automatically cleared
    after a timeout (in seconds) provided with the -s option. If no timout is given,
    the clipboard will be cleared after 30 seconds.

    Note that the -s option does nothing if the -c option is not provided.
    """
    |> IO.puts()
  end
end