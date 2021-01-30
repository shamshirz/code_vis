defmodule Display.GraphIt do
  @moduledoc """
  Wrapper around graphing dependency
  Convert `CodeVis` representation of data into a visual graph

  Internal to this module, this uses `%Graphvix.Graph{}` to transform the data and then display it
  """

  alias Graphvix.Graph

  @doc """
  Given a function, find all outgoing calls.
  For each call, recursively do the same process
  At each `node` we want to create a vertex and assign an edge to the parent
  How to represent that with data?
  At each `node` we want to return either
  * a leaf (node info, no children)
  * a branch (node info, recurse children)

  %NodeInfo{[:module, :fxn, :arity, :parent}
  %EdgeInfo{line# in caller}


  First pass - make everything in the printed version as node, no edges
  """
  @spec new(map(), mfa()) :: Graphvix.Graph.t()
  def new(map, mfaroot), do: add_node(map, mfaroot, nil, Graph.new())

  @spec to_file(Graphvix.Graph.t(), String.t()) :: :ok
  def to_file(graph, file_name \\ "_graphs/first_graph"), do: Graph.compile(graph, file_name)

  @spec add_node(map(), mfa(), edge_id :: any(), Graphvix.Graph.t()) :: Graphvix.Graph.t()
  defp add_node(map, mfa, parent_vertex_id, graph) do
    {updated_graph, current_vertex_id} = add_node_and_edge_to_parent(graph, mfa, parent_vertex_id)

    case Map.fetch!(map, mfa) do
      [] ->
        # Leaf, do nothing
        updated_graph

      target_mfas ->
        # Branch, gather children
        target_mfas
        |> Enum.flat_map(fn target -> traverse_local_functions(map, target, mfa) end)
        |> Enum.reduce(updated_graph, fn target_mfa, acc ->
          add_node(map, target_mfa, current_vertex_id, acc)
        end)
    end
  end

  # if the target is in the same module, traverse it's calls
  # recursively traverse local functions, returning only remote calls
  @spec traverse_local_functions(map, mfa(), mfa()) :: [mfa()]
  defp traverse_local_functions(
         map,
         {same_module, _, _} = target_mfa,
         {same_module, _, _} = current_mfa
       ) do
    map
    |> Map.fetch!(target_mfa)
    |> Enum.flat_map(fn target -> traverse_local_functions(map, target, current_mfa) end)
  end

  defp traverse_local_functions(_map, target_mfa, _current_mfa), do: [target_mfa]

  @spec add_node_and_edge_to_parent(Graphvix.Graph.t(), mfa(), nil | any()) ::
          {Graphvix.Graph.t(), vertex_id :: any()}
  defp add_node_and_edge_to_parent(graph, mfa, nil) do
    Graph.add_vertex(graph, Display.format_mfa(mfa))
  end

  defp add_node_and_edge_to_parent(graph, mfa, parent_vertex_id) do
    {updated_graph, current_vertex_id} = Graph.add_vertex(graph, Display.format_mfa(mfa))

    {updated_graph_2, _edge_id} =
      Graph.add_edge(
        updated_graph,
        parent_vertex_id,
        current_vertex_id,
        label: "fxn_name",
        color: "green"
      )

    {updated_graph_2, current_vertex_id}
  end
end
