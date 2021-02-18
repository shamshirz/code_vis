defmodule CodeVis do
  @moduledoc """
  Entry point for operating on traced function data
  """

  @type adjacency_map :: %{mfa() => %{children: [mfa()]}}

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
end
