# CodeVis

Compile-time tool to visualize elixir applications flow.

## Setup

```bash
# External dep on `dot` cmd line util
> brew install graphviz
> mix deps.get
> mix run scripts/tree_tracer.exs

CodeVis.i_alias/0 ->
--CodeVis.ModuleA.fxn/0 -> leaf
--CodeVis.ModuleB.fxn/0 ->
----CodeVis.ModuleA.fxn/0 -> leaf
--CodeVis.ModuleC.fxn/0 -> leaf

> open _graphs/first_graph.png

```

## Next steps
* (Essential Feature) Capture local function calls as well
  * Without this, we are missing outgoing calls
  * Don't want to show local calls in the graph, not essential
* (Quality) Add tests
  * 3 steps to data: collect -> Intermediate form (map rn) -> Graph
  * Testing tracer seems hard
  * Testing intermediate would probs be really useful - need to decide on a form
  * testing the graph should be easy, but also least important
  * main logic functions
    * build map from ETS
    * Build Graph from Map
* (Quality) Struct for each node with available info
* (Decision) How to display circular deps? new node or re-use?
  * Currently, adds a new node, not the end of the world
* (Improvement) How to filter non-user code? Don't want to display `Enum` calls
  * This is how [Mix.Xref.calls/1](https://github.com/elixir-lang/elixir/blob/v1.11.3/lib/mix/lib/mix/tasks/xref.ex#L235) did it until they deprecated it
  * manifest file -> Elixir compiler fxn to read -> pulls out module list
  * Useful once this is running on other projects
* (minor) Edges could be labelled with the line number in the caller's module

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `code_vis` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:code_vis, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/code_vis](https://hexdocs.pm/code_vis).

