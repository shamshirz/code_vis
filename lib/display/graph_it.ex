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

  %NodeInfo{:module, :fxn, :arity, :parent}
  %EdgeInfo{line# in caller}
  """
  @spec new(CodeVis.adjacency_map(), mfa()) :: Graphvix.Graph.t()
  def new(map, mfaroot) do
    {_updated_map, graph} = add_node(map, mfaroot, nil, Graph.new())
    graph
  end

  @spec to_file(Graphvix.Graph.t(), String.t()) :: :ok
  def to_file(graph, file_name \\ "_graphs/first_graph"), do: Graph.compile(graph, file_name)

  @spec to_string(Graphvix.Graph.t()) :: String.t()
  def to_string(graph), do: Graph.to_dot(graph)

  @spec add_node(
          CodeVis.adjacency_map(),
          mfa(),
          edge_id :: any(),
          Graphvix.Graph.t()
        ) :: {map(), Graphvix.Graph.t()}
  defp add_node(map, mfa, parent_vertex_id, graph) do
    # If the mfa already has a node in the graph, draw edge and we are done
    # if not, allow a new one to be created and proceed
    case Map.fetch!(map, mfa) do
      %{vertex_id: vertex_id} ->
        {updated_graph, _current_vertex_id} =
          add_node_and_edge_to_parent(graph, vertex_id, parent_vertex_id)

        {map, updated_graph}

      mfa_info ->
        # This is a new node
        {updated_graph, current_vertex_id} =
          add_node_and_edge_to_parent(graph, mfa, parent_vertex_id)

        updated_mfa_info = Map.put(mfa_info, :vertex_id, current_vertex_id)
        updated_map = Map.put(map, mfa, updated_mfa_info)

        case updated_mfa_info do
          %{children: []} ->
            # Leaf, do nothing
            {updated_map, updated_graph}

          %{children: target_mfas} ->
            # Branch, gather children
            target_mfas
            |> Enum.reduce({updated_map, updated_graph}, fn target_mfa, {acc_map, acc_graph} ->
              add_node(acc_map, target_mfa, current_vertex_id, acc_graph)
            end)
        end
    end
  end

  # Get or Create the new node in the graph
  # If there is a parent node (all except for root), draw an edge
  @spec add_node_and_edge_to_parent(
          Graphvix.Graph.t(),
          mfa() | (vertex_id :: any()),
          nil | any()
        ) ::
          {Graphvix.Graph.t(), vertex_id :: any()}
  defp add_node_and_edge_to_parent(graph, {m, _f, _a} = mfa, nil) do
    Graph.add_vertex(graph, Display.format_mfa(mfa), group: Atom.to_string(m))
  end

  defp add_node_and_edge_to_parent(graph, {m, _, _} = mfa, parent_vertex_id) do
    {updated_graph, current_vertex_id} =
      Graph.add_vertex(graph, Display.format_mfa(mfa), group: Atom.to_string(m))

    {updated_graph_2, _edge_id} =
      Graph.add_edge(
        updated_graph,
        parent_vertex_id,
        current_vertex_id
        # label: "fxn_name",
        # color: "green"
      )

    {updated_graph_2, current_vertex_id}
  end

  defp add_node_and_edge_to_parent(graph, current_vertex_id, parent_vertex_id) do
    # Node already exists case
    {updated_graph, _edge_id} =
      Graph.add_edge(
        graph,
        parent_vertex_id,
        current_vertex_id
        # label: "fxn_name",
        # color: "green"
      )

    {updated_graph, current_vertex_id}
  end
end
