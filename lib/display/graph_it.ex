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
    graph = traverse(map, mfaroot, Graph.new())

    Graph.compile(graph, file_name)
  end

  @spec traverse(map(), mfa(), graph :: any()) :: graph :: any()
  defp traverse(map, mfa, graph) do
    {updated_graph, _this_vertex_id} = Graph.add_vertex(graph, Display.format_mfa(mfa))

    case Map.fetch!(map, mfa) do
      [] ->
        # Leaf, create node (eventual draw edge to parent, done)
        # "#{indent(level)}#{format_mfa(mfa)} -> leaf"
        updated_graph

      target_mfas ->
        # Branch, gather children
        Enum.reduce(target_mfas, updated_graph, fn target_mfa, acc ->
          traverse(map, target_mfa, acc)
        end)
    end
  end
end
