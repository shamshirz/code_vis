defmodule Mix.Tasks.CodeVis.ToCsv do
  @shortdoc "Collects fxn data and outputs to CSV"

  @moduledoc """
  Compiles the project with tracer enabled and dumps :ets table to csv then exits
  """

  use Mix.Task
  alias CodeVis.Repo

  alias NimbleCSV.Spreadsheet

  @typedoc """
  [
    caller_id :: String.t(),
    caller_module :: String.t(),
    caller_fxn :: String.t(),
    caller_arity :: String.t(),
    target_id :: String.t(),
    target_module :: String.t(),
    target_fxn :: String.t(),
    target_arity :: String.t()
  ]

  """
  @type csv_row :: [String.t()]

  @doc false
  @impl true
  def run(_args) do
    unless Version.match?(System.version(), ">= 1.10.0-rc") do
      Mix.raise("Elixir v1.10+ is required!")
    end

    Repo.start()
    Mix.Task.rerun("compile.elixir", ["--force", "--tracer", "CodeVis.FunctionTracer"])

    IO.puts("Trace complete. Generating CSV…")

    caller_target_list = Repo.all()
    write_csv(caller_target_list)
  end

  @spec write_csv([{caller :: mfa(), target :: mfa()}]) :: :ok
  defp write_csv(data) do
    formatted = Enum.map(data, &format_data/1)

    header = [
      "Caller ID",
      "Caller Module",
      "Caller Function",
      "Caller Arity",
      "Target ID",
      "Target Module",
      "Target Function",
      "Target Arity"
    ]

    File.write!("function_data.csv", Spreadsheet.dump_to_iodata([header | formatted]))
  end

  @spec format_data({caller :: mfa(), target :: mfa()}) :: csv_row()
  defp format_data({caller_mfa, target_mfa}) do
    [
      Display.format_mfa(caller_mfa),
      Tuple.to_list(caller_mfa),
      Display.format_mfa(target_mfa),
      Tuple.to_list(target_mfa)
    ]
    |> List.flatten()
  end
end
