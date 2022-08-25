defmodule Keyring.CLI do
  @moduledoc """
  Keyring CLI parser.
  """

  @keyring_operations [:init, :insert, :reveal]

  def parse([operation | args]) do
    aliases = [c: :clipboard]
    strict_opt = [clipboard: :boolean]

    {options, _, _} = OptionParser.parse(args, aliases: aliases, strict: strict_opt)
    {operation, options}
  end
end