defmodule Display.GraphIt do
  alias Graphvix.Graph

  def example(_map, _root, file_name \\ "_graphs/first_graph") do
    graph = Graph.new()

    # vertex
    {graph1, vertex_id1} = Graph.add_vertex(graph, "vertex label")
    {graph2, vertex_id2} = Graph.add_vertex(graph1, "vertex label")
    {graph3, vertex_id3} = Graph.add_vertex(graph2, "vertex label")

    # edge
    {graph4, _edge_id} =
      Graph.add_edge(
        graph3,
        vertex_id1,
        vertex_id2,
        label: "Edge",
        color: "green"
      )

    {graph5, _edge_id} =
      Graph.add_edge(
        graph4,
        vertex_id1,
        vertex_id3,
        label: "Edge",
        color: "green"
      )

    # produce graph and open
    Graph.compile(graph5, file_name)
  end

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
  @spec create(map(), mfa(), binary) :: :ok
  def create(map, mfaroot, file_name \\ "_graphs/first_graph") do
    graph = add_node(map, mfaroot, nil, Graph.new())

    Graph.compile(graph, file_name)
  end

  @spec add_node(map(), mfa(), edge_id :: any(), graph :: any()) :: graph :: any()
  defp add_node(map, mfa, parent_vertex_id, graph) do
    {updated_graph, current_vertex_id} = add_node_and_edge_to_parent(graph, mfa, parent_vertex_id)

    case Map.fetch!(map, mfa) do
      [] ->
        # Leaf, create node (eventual draw edge to parent, done)
        # "#{indent(level)}#{format_mfa(mfa)} -> leaf"
        updated_graph

      target_mfas ->
        # Branch, gather children
        Enum.reduce(target_mfas, updated_graph, fn target_mfa, acc ->
          add_node(map, target_mfa, current_vertex_id, acc)
        end)
    end
  end

  @spec add_node_and_edge_to_parent(any(), mfa(), nil | any()) ::
          {graph :: any(), vertex_id :: any()}
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
