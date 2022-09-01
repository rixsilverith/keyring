defmodule Keyring.MixProject do
  use Mix.Project

  def project do
    [
      app: :keyring,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: Keyring, name: "keyring"]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:yaml_elixir, "~> 2.9"},
      {:plug_crypto, "~> 1.0"},
      {:ok, "~> 2.3"},
    ]
  end
end
