defmodule CodeVis.ProjectAnalysis do
  import Mix.Compilers.Elixir, only: [read_manifest: 1, source: 1]

  @manifest "compile.elixir"

  @doc """
  Read the user project compilation manifest
      `/_build/dev/lib/PROJECT/.mix/compile.elixir`

  Extract a list of all the modules available
  This is copied from

  * [Mix.Xref.calls/1](https://github.com/elixir-lang/elixir/blob/v1.11.3/lib/mix/lib/mix/tasks/xref.ex#L235)

  """
  @spec user_modules :: [module()]
  def user_modules() do
    for source(modules: modules) <- read_manifest(manifest()) |> elem(1),
        module <- modules,
        do: module
  end

  # Only the current project, won't work with umbrellas
  @spec manifest :: String.t()
  defp manifest() do
    Path.join(Mix.Project.manifest_path(), @manifest)
  end
end
