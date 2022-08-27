defmodule Keyring.Utils do
  @moduledoc """
  *keyring* utils.
  """

  def puts(type, str) do
    case type do
      :error ->
        [:bright, :red, "! Error: ", :reset, str] |> IO.ANSI.format() |> IO.puts()

      :input ->
        [:bright, "[*] ", :reset, str] |> IO.ANSI.format() |> IO.gets()

      :hidden_input ->
        [:bright, "[*] ", :reset, str] |> IO.ANSI.format() |> List.to_string() |> get_hidden_input()
    end
  end

  # Password prompt that hides input by every 1ms clearing
  # the line with stderr. See:
  # https://github.com/hexpm/hex/blob/1523f44e8966d77a2c71738629912ad59627b870/lib/mix/hex/utils.ex#L32-L58
  def get_hidden_input(prompt) do
    pid = spawn_link(fn -> loop(prompt) end)
    ref = make_ref()
    value = IO.gets(prompt <> " ")

    send(pid, {:done, self(), ref})
    receive do: ({:done, ^pid, ^ref} -> :ok)

    value
  end

  defp loop(prompt) do
    receive do
      {:done, parent, ref} ->
        send(parent, {:done, self(), ref})
        IO.write(:standard_error, "\e[2K\r")
    after
      1 ->
        IO.write(:standard_error, "\e[2K\r#{prompt}")
        loop(prompt)
    end
  end

  def clipboard_copy(value) do
    clipboard_copy(:os.type(), value)
    {:ok, value}
  end

  def clipboard_clean() do
    clipboard_copy("")
  end

  defp clipboard_copy({:unix, :darwin}, value) do
    execute_command({"pbcopy", []}, value)
  end

  defp clipboard_copy({:unix, _}, value) do
    execute_command({"xclip", ["-sel", "clip"]}, value)
  end

  defp execute_command({bin, args}, value) when is_binary(bin) and is_list(args) do
    case System.find_executable(bin) do
      nil -> {:error, "Cannot find #{bin}"}
      path ->
        port = Port.open({:spawn_executable, path}, [:binary, args: args])
        send(port, {self(), {:command, value}})
        send(port, {self(), :close})
        :ok
    end
  end
end