defmodule Mix.Tasks.CodeVis.Server do
  use Mix.Task

  @shortdoc "Starts CodeVis Server only"

  @moduledoc """
  Attempts to run a single server with a single endpoint setup via cowboy
  """

  @doc false
  def run(args) do
    Mix.Tasks.Run.run(run_args() ++ args)
  end

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end
end
