defmodule CodeVis.MixProject do
  use Mix.Project

  def project do
    [
      app: :code_vis,
      version: "0.1.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:graphvix, "~> 1.0.0"},
      {:plug_cowboy, "~> 2.0"},
      {:stream_data, "~> 0.1", only: [:dev, :test]}
    ]
  end

  defp aliases() do
    [
      try: [
        "cmd 'cd test_project && mix visualize TestProject.i_alias/0 && open _graphs/first_graph.png'"
      ]
    ]
  end
end
