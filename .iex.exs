defmodule Aaron do
  def function_a() do
    2
  end

  def function_b(num), do: function_a + num
end

defmodule SchemaValidator do
  def run() do
    :ets.new(:schemas, [:named_table, :public])
    Mix.Task.clear()
    Mix.Task.run("compile", ["--force", "--tracer", __MODULE__])
  end

  @spec trace(tuple, Macro.Env.t()) :: :ok
  def trace({:remote_macro, _meta, MyApp.Schema, :__using__, 1}, env) do
    :ets.insert(:schemas, {env.module, true})
    :ok
  end

  def trace({:remote_macro, meta, Ecto.Schema, :__using__, 1}, env) do
    case :ets.lookup(:schemas, env.module) do
      [] ->
        IO.warn(
          "#{env.file}:#{meta[:line]} - #{inspect(env.module)} should use `MyApp.Schema`",
          []
        )

      _ ->
        :ok
    end
  end

  def trace(_, _), do: :ok
end

# SchemaValidator.run()
