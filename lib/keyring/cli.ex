defmodule Keyring.CLI do
  @moduledoc """
  Keyring CLI parser.
  """

  #@keyring_operations [:init, :insert, :reveal]

  def parse([operation | args]) do
    operation = operation |> String.to_existing_atom()
    case operation do
      :init -> parse_init_operation(args)
      :insert -> parse_insert_operation(args)
      :reveal -> parse_reveal_operation(args)
    end
  end

  defp parse_init_operation(opts) do
    strict_opts = [help: :boolean]
    aliases = [h: :help]

    {opts, _, _} = OptionParser.parse(opts, aliases: aliases, strict: strict_opts)
    {:init, "", opts}
  end

  defp parse_insert_operation(opts) do
    strict_opts = [help: :boolean]
    aliases = [h: :help]

    [key_name | opts] = opts
    {opts, _, _} = OptionParser.parse(opts, aliases: aliases, strict: strict_opts)
    {:insert, key_name, opts}
  end

  defp parse_reveal_operation(opts) do
    strict_opts = [help: :boolean, clipboard: :boolean, seconds: :integer]
    aliases = [h: :help, c: :clipboard, s: :seconds]

    [key_name | opts] = opts
    {opts, _, _} = OptionParser.parse(opts, aliases: aliases, strict: strict_opts)
    {:reveal, key_name, opts}
  end

  def help do
    help = """
    keyring: Minimal CLI utility for local key/password storage and management
    A detailed information page is available at https://github.com/rixsilverith/keyring

    Usage: keyring <operation> [<options>...]
    where <operation> is one of the following:

    init                                 Initialize the keyring vault.
    insert <key_name>                    Insert a key into the keyring vault.
    reveal <key_name> [-c|--clipboard]   Reveal the key <key_name>.
    help                                 Show this help message.

    For more information about a specific operation run: keyring <operation> -h
    """
    |> IO.puts()
  end
end