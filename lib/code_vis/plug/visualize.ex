defmodule CodeVis.Plug.Visualize do
  @moduledoc """

  Try it!

  $ iex -S mix
  > {:ok, _} = Plug.Cowboy.http CodeVis.Plug.Visualize, []
  {:ok, #PID<...>}
  # Open http://localhost:4000/?mfa=TestProject.i_alias/0
  """

  @behaviour Plug

  import Plug.Conn

  alias CodeVis.Repo

  # Init will recompile your whole project `:eek`
  def init(options) do
    unless Version.match?(System.version(), ">= 1.10.0-rc") do
      Mix.raise("Elixir v1.10+ is required!")
    end

    Repo.start()
    Mix.Task.rerun("compile.elixir", ["--force", "--tracer", "CodeVis.FunctionTracer"])

    options
  end

  # Receives current connection and options from init
  # Expects /your_selected_path?mfa=TestProject.i_alias/0

  def call(conn, _opts) do
    case get_query_params_mfa(conn) do
      {:ok, mfa} ->
        map = CodeVis.function_tree_from(mfa)
        Display.as_file(map, mfa)
        Plug.Conn.send_file(conn, 200, "./_graphs/first_graph.png")

      {:error, reason} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, reason)
    end
  end

  @spec get_query_params_mfa(Plug.Conn.t()) :: {:ok, mfa()} | {:error, String.t()}
  defp get_query_params_mfa(conn) do
    case fetch_query_params(conn) |> Map.get(:query_params) do
      %{"mfa" => mfa_string} ->
        case Mix.Utils.parse_mfa(mfa_string) do
          {:ok, [m, f, a]} ->
            {:ok, {m, f, a}}

          _ ->
            {:error, "Unable to parse mfa_string: #{mfa_string}"}
        end

      _ ->
        {:error, "Query param missing. Expected ?mfa=Mod.fxn/arity"}
    end
  end
end
