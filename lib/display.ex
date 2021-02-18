defmodule Display do
  alias Display.GraphIt

  @spec as_file(map(), mfa()) :: :ok
  def as_file(map, root_mfa) do
    map
    |> GraphIt.new(root_mfa)
    |> GraphIt.to_file()
  end

  @spec as_string(map(), mfa()) :: String.t()
  def as_string(map, root_mfa) do
    map
    |> GraphIt.new(root_mfa)
    |> GraphIt.to_string()
  end

  @spec format_mfa(mfa()) :: String.t()
  def format_mfa({module, function_name, arity}) do
    "#{inspect(module)}.#{function_name}/#{arity}"
  end
end
