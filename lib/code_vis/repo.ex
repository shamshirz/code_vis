defmodule CodeVis.Repo do
  @moduledoc """
  Wrapper for storing and retrieving MFAs and their calls
  Should this be a genserver?
  """

  @table_name :functions

  @doc """
  Starts `:functions` table
  """
  @spec start :: any()
  def start() do
    :ets.new(@table_name, [:named_table, :public, :duplicate_bag])
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
  def insert(kv_tuple) do
    :ets.insert(@table_name, kv_tuple)
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
  defp all(), do: :ets.tab2list(@table_name)
end
