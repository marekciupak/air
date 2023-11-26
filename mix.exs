defmodule Air.MixProject do
  use Mix.Project

  def project do
    [
      app: :air,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        air: [
          steps: [:assemble, :tar]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Air.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_uart, "~> 1.0"},
      {:circuits_i2c, "~> 2.0"},
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.0"}
    ]
  end
end
