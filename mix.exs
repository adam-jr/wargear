defmodule Wargear.MixProject do
  use Mix.Project

  def project do
    [
      app: :wargear,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Wargear, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.5.0"},
      {:absinthe_plug, "~> 1.5.0"},
      {:floki, "~> 0.26.0"},
      {:httpoison, "~> 1.6"},
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.1"}
    ]
  end
end
