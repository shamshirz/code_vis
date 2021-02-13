defmodule CodeVis do
  @moduledoc """
  Entry point for operating on traced function data
  """

  @type adjacency_map :: %{mfa() => %{children: [mfa()]}}
  # This should just be module Keyed - turn into a struct too
  @type module_stats :: %{mfa() => %{incoming: nil, outgoing: integer(), color: nil | String.t()}}

  alias CodeVis.Repo

  @doc """
  Given a starting MFA, read from `CodeVis.Repo` tracing function calls
  Functions included in the result must live in the included modules

  Produces an Adjacency Map
  Keys: MFA for every function that is compiled starting from the root_mfa
  Values: MFA for each function called directly by the key MFA

    %{
      mfa1: [mfa2, mfa3]
      mfa2: []
      mfa3: [mfa4]
      mfa4: []
    }
  """
  @spec function_tree_from(map(), mfa(), [module()]) :: adjacency_map()
  def function_tree_from(
        accumulator \\ %{},
        current_mfa,
        user_modules \\ CodeVis.ProjectAnalysis.user_modules()
      ) do
    case Repo.lookup(current_mfa) |> Enum.filter(fn {m, _f, _a} -> m in user_modules end) do
      [] ->
        # base case
        Map.put(accumulator, current_mfa, %{children: []})

      target_mfas ->
        updated = Map.put(accumulator, current_mfa, %{children: target_mfas})

        Enum.reduce(target_mfas, updated, fn next_mfa, acc ->
          function_tree_from(acc, next_mfa, user_modules)
        end)
    end
  end

  @spec module_stats(adjacency_map()) :: module_stats()
  def module_stats(adjacency_map) do
    Enum.reduce(adjacency_map, %{}, fn {{module, _fxn, _arity}, %{children: list_of_mfas}},
                                       accumulator ->
      outgoing_edge_count = length(list_of_mfas)
      new = %{incoming: nil, outgoing: outgoing_edge_count, color: nil}

      Map.update(accumulator, module, new, fn existing_value ->
        %{existing_value | outgoing: existing_value.outgoing + outgoing_edge_count}
      end)
    end)
  end

  @orangest "#d94701"
  @oranger "#fd8d3c"
  @orange "#fdbe85"

  @spec assign_module_colors(module_stats()) :: module_stats()
  def assign_module_colors(module_stats) do
    top3 =
      module_stats
      |> Map.to_list()
      |> Enum.sort(fn {_mfa1, mod1}, {_mfa2, mod2} -> mod1.outgoing >= mod2.outgoing end)
      |> Enum.take(3)
      |> case do
        [{mfa1, _one}, {mfa2, _two}, {mfa3, _three}] ->
          %{}
          |> Map.put(mfa1, @orangest)
          |> Map.put(mfa2, @oranger)
          |> Map.put(mfa3, @orange)

        [{mfa1, _one}, {mfa2, _two}] ->
          %{}
          |> Map.put(mfa1, @orangest)
          |> Map.put(mfa2, @oranger)

        [{mfa1, _one}] ->
          %{}
          |> Map.put(mfa1, @orangest)

        _empty_list ->
          %{}
      end

    top3
    |> Enum.reduce(module_stats, fn {mfa, color}, accumulator ->
      Map.update!(accumulator, mfa, fn existing -> %{existing | color: color} end)
    end)
  end
end
