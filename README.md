# CodeVis

Compile-time tool to visualize elixir applications flow.

## Setup

```bash
# External dep on `dot` cmd line util
> brew install graphviz
> mix deps.get && mix compile
# Enter example project to execute task there
> cd test_project
> mix deps.get
> mix visualize

TestProject.i_alias/0 ->
--TestProject.ModuleA.fxn/0 -> leaf
--TestProject.ModuleB.fxn/0 ->
----TestProject.ModuleA.fxn/0 -> leaf
--TestProject.ModuleC.fxn/0 -> leaf

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
  * This turned out to be really hard! How do we test a mix task that recompiles the project?
    * [Boundary](https://github.com/sasa1977/boundary/blob/master/test/support/test_project.ex) does it by generating a dynamic project within the test setup!!
* (Quality) Struct for each node with available info
* (Decision) How to display circular deps? new node or re-use?
  * Currently, adds a new node, not the end of the world
* (Improvement) How to filter non-user code? Don't want to display `Enum` calls
  * This is how [Mix.Xref.calls/1](https://github.com/elixir-lang/elixir/blob/v1.11.3/lib/mix/lib/mix/tasks/xref.ex#L235) did it until they deprecated it
  * manifest file -> Elixir compiler fxn to read -> pulls out module list
  * Useful once this is running on other projects
* (minor) Edges could be labelled with the line number in the caller's module


## Resources

* [Dashbit tracer example](https://gist.github.com/wojtekmach/4e04cbda82ba88af3f84c44ec746b7ca#file-import2alias-ex-L20)

## Installation

Try it out on your project!

```elixir
def deps do
  [
    ## {:code_vis, "~> 0.1.0"}
    {:code_vis, git: "https://github.com/shamshirz/code_vis.git", tag: "0.1"}
  ]
end
```

```bash
> mix deps.get
> mix visualize <Input of some kind to identify which function to trace>
```
