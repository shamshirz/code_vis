defmodule CodeVis.MixProject do
  use Mix.Project

  def project do
    [
      app: :code_vis,
      version: "1.2.0",
      elixir: "~> 1.11",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      xref: [exclude: IEx]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CodeVis.Application, []}
    ]
  end

  defp elixirc_paths(env) when env in [:pre_commit, :test], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:graphvix, "~> 1.0.0"},
      {:nimble_csv, "~> 1.1"},
      {:plug_cowboy, "~> 2.0"},
      {:stream_data, "~> 0.1", only: [:dev, :test]}
    ]
  end

  defp aliases() do
    [
      try: [
        "cmd 'cd test_project && mix visualize TestProject.i_alias/0 && open _graphs/first_graph.png'"
      ],
      # Prevents plug from initializing and recompiling
      test: "test --no-start"
    ]
  end
end
