defmodule CodeVis.Plug.Visualize do
  @moduledoc """

  Try it!

  ```bash
    $ iex -S mix
    > {:ok, _} = Plug.Cowboy.http CodeVis.Plug.Visualize, []
    {:ok, #PID<...>}
    # Open http://localhost:4000/?mfa=TestProject.i_alias/0
  ```
  """

  @behaviour Plug

  import Plug.Conn

  require EEx
  require Logger

  alias CodeVis.Repo

  index_template = Path.join(__DIR__, "index.html.eex")
  EEx.function_from_file(:defp, :index, index_template, [:assigns])

  graph_template = Path.join(__DIR__, "graph.html.eex")
  EEx.function_from_file(:defp, :graph, graph_template, [:assigns])

  @spec render_index(Plug.Conn.t()) :: Plug.Conn.t()
  defp render_index(conn) do
    assigns = %{functions: Repo.get_fuctions_by_module()}

    assigns
    |> index()
    |> rendered(conn)
  end

  @spec render_graph(Plug.Conn.t(), mfa()) :: Plug.Conn.t()
  defp render_graph(conn, mfa) do
    map = CodeVis.function_tree_from(mfa)
    dot_string = Display.as_string(map, mfa)
    assigns = %{dot_string: dot_string, mfa: mfa}

    assigns
    |> graph()
    |> rendered(conn)
  end

  @spec rendered(String.t(), Plug.Conn.t()) :: Plug.Conn.t()
  defp rendered(html, conn) do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  # Init will recompile your whole project `:eek`
  def init(options) do
    unless Version.match?(System.version(), ">= 1.10.0-rc") do
      Mix.raise("Elixir v1.10+ is required!")
    end

    Repo.start()
    Logger.info("CodeVis trace initiated…")

    Mix.Task.rerun("compile.elixir", ["--force", "--tracer", "CodeVis.FunctionTracer"])

    Logger.info("CodeVis trace complete 🎉")
    Logger.info("CodeVis is live with options: #{inspect(options)}")

    options
  end

  def call(conn, _opts) do
    case get_query_params_mfa(conn) do
      {:ok, mfa} ->
        render_graph(conn, mfa)

      {:error, :redirect} ->
        render_index(conn)

      {:error, reason} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, reason)
    end
  end

  @spec get_query_params_mfa(Plug.Conn.t()) ::
          {:ok, mfa()} | {:error, :redirect | String.t()}
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
        {:error, :redirect}
    end
  end
end
