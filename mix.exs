defmodule CardealApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :cardeal_api,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      xref: [exclude: [:crypto]],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {CardealApi.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.6.0"},
      {:jason, "~> 1.4.0"},
      {:timex, "~> 3.7.9"},
      {:uuid, "~> 1.1"},
      {:json, "~> 1.4"},
      {:mock, "~> 0.3.7"}
    ]
  end
end
