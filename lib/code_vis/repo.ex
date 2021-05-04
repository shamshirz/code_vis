defmodule CodeVis.Repo do
  @moduledoc """
  Wrapper for storing and retrieving MFAs and their calls
  Should this be a genserver?
  """

  @table_name :functions

  @doc """
  Starts `:functions` table or uses existing.
  Global table - TODO - allow multiple?
  """
  @spec start :: any()
  def start() do
    case :ets.whereis(@table_name) do
      :undefined ->
        :ets.new(@table_name, [:named_table, :public, :duplicate_bag])

      _ref ->
        :ok
    end
  end

  @doc """
  Looks up the list of functions called by the passed in MFA
  """
  @spec lookup(mfa()) :: [mfa()]
  def lookup(mfa) do
    @table_name
    |> :ets.lookup(mfa)
    |> Enum.map(&elem(&1, 1))
  end

  @spec get_fuctions_by_module :: %{module() => [mfa()]}
  def get_fuctions_by_module() do
    all()
    |> Enum.map(&elem(&1, 0))
    |> Enum.dedup()
    |> Enum.group_by(fn {module, _f, _a} -> module end)
  end

  @spec insert({caller :: mfa(), target :: mfa()}) :: true
  def insert({one, two} = kv_tuple) when is_tuple(one) and is_tuple(two) do
    :ets.insert(@table_name, kv_tuple)
  end

  def insert(input) do
    raise ArgumentError,
      message: "I expect to only insert {mfa(), mfa()} tuples, not: #{inspect(input)}."
  end

  @spec first :: :error | any()
  def first do
    case :ets.first(@table_name) do
      :"$end_of_table" ->
        :error

      key ->
        key
    end
  end

  @spec all :: [{caller :: mfa(), target :: mfa()}]
  def all(), do: :ets.tab2list(@table_name)
end
