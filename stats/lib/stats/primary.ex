defmodule Stats.Primary do
  alias NimbleCSV.Spreadsheet
  #  Could not get streaming to work
  # Have to process the (BOM = Byte Order Marker) in the stream some how and I couldn't get it to work

  # NimbleCSV.define(MyParser, separator: "\t", escape: "\"")

  # def try do
  #   "function_data.csv"
  #   |> File.stream!([:utf16, :trim_bom])
  #   |> Spreadsheet.parse_stream()
  #   |> Stream.map(&line_to_map/1)
  #   |> Stream.take(2)

  #   # File.stream!(path, [:utf16], :line)
  # end

  # [
  #   caller_mfa :: String.t(),
  #   caller_module :: String.t(),
  #   caller_fxn :: String.t(),
  #   caller_arity :: String.t(),
  #   target_mfa :: String.t(),
  #   target_module :: String.t(),
  #   target_fxn :: String.t(),
  #   target_arity :: String.t()
  # ]

  # def try2 do
  #   "function_data.csv"
  #   |> File.stream!([:trim_bom])
  #   |> MyParser.parse_stream()
  #   |> Stream.map(&line_to_map/1)
  #   |> Stream.take(2)
  # end

  def try3 do
    {:ok, csv_data} = File.read("function_data.csv")

    csv_data
    |> Spreadsheet.parse_string()
    |> Enum.map(&line_to_map/1)
    |> Enum.take(2)
  end

  defp line_to_map([
         caller_mfa,
         caller_module,
         caller_fxn,
         caller_arity,
         target_mfa,
         target_module,
         target_fxn,
         target_arity
       ]) do
    %{
      caller_mfa: :binary.copy(caller_mfa),
      caller_module: :binary.copy(caller_module),
      caller_fxn: :binary.copy(caller_fxn),
      caller_arity: :binary.copy(caller_arity),
      target_mfa: :binary.copy(target_mfa),
      target_module: :binary.copy(target_module),
      target_fxn: :binary.copy(target_fxn),
      target_arity: :binary.copy(target_arity)
    }
  end
end
