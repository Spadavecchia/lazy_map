defmodule LazyMap.MixProject do
  use Mix.Project

  def project do
    [
      app: :lazy_map,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0"},
      {:httpoison, "~> 1.0", only: :test},
      {:plug_cowboy, "~> 2.0", only: :test},
      {:poison, "~> 3.1", only: :test}
    ]
  end
end
