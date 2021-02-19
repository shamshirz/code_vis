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

    ```
    %{
      mfa1: [mfa2, mfa3]
      mfa2: []
      mfa3: [mfa4]
      mfa4: []
    }
    ```

    ## Evolved state?

    ```
    @type vertex :: mfa()
    %{
      vertex: %Vertex{
        id: vertex,
        children: [ {vertex, edge_info :: any()} ],
        vertex_data: any() ]
      }
      …
    }
    ```
  """
  @spec build_adjacency_map(map(), mfa(), [module()]) :: adjacency_map()
  def build_adjacency_map(
        accumulator \\ %{},
        current_mfa,
        user_modules \\ CodeVis.ProjectAnalysis.user_modules()
      ) do
    # If the mfa is already in the accumulator, then we have already traversed that branch and we can return
    case Map.has_key?(accumulator, current_mfa) do
      true ->
        accumulator

      false ->
        case Repo.lookup(current_mfa) |> Enum.filter(fn {m, _f, _a} -> m in user_modules end) do
          [] ->
            # it's a leaf node
            Map.put(accumulator, current_mfa, %{children: []})

          target_mfas ->
            # It's a branch node
            updated = Map.put(accumulator, current_mfa, %{children: target_mfas})

            Enum.reduce(target_mfas, updated, fn next_mfa, acc ->
              build_adjacency_map(acc, next_mfa, user_modules)
            end)
        end
    end
  end
end
