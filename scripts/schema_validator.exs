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

  # Lots of these
  # def trace({:alias_reference, meta, module}, env) do
  #   IO.inspect(env)
  #   IO.inspect(meta)
  #   IO.inspect(module)
  #   IO.warn("^ these are from the :alias_reference")
  # end

  # skip
  def trace({:remote_function, _meta, module, _name, _arity}, _env)
      when module in [
             :elixir_def,
             :elixir_module,
             :elixir_utils,
             Kernel.LexicalTracker,
             Module
           ],
      do: :ok

  # def trace({:remote_function, meta, module, name, arity}, env) do
  #   IO.inspect(module, label: "module")
  #   IO.inspect(name, label: "name")
  #   IO.inspect(arity, label: "arity")

  #   :ok
  # end

  def trace({:remote_function, _meta, module, name, arity}, env) do
    # IO.inspect(env.module)
    # env.line
    with {caller_name, caller_arity} <- env.function do
      IO.puts("#{fxn(env.module, caller_name, caller_arity)} -> #{fxn(module, name, arity)}")
    end

    :ok
  end

  def trace(_, _), do: :ok

  @spec fxn(atom(), String.t(), integer()) :: String.t()
  defp fxn(module, name, arity) do
    "#{inspect(module)}.#{name}/#{arity}"
  end
end

defmodule MyTracer do
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

SchemaValidator.run()
