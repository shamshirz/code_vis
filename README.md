# CodeVis

Compile-time tool to visualize elixir applications flow.

## Setup

```bash
# External dep on `dot` cmd line util
> brew install graphviz
> mix deps.get && mix compile
# this alias simplifies a big step
# Go to an example project, use `CodeVis` as a dep, and run the visualize task
> mix try

TestProject.i_alias/0 ->
--TestProject.ModuleA.fxn/0 -> leaf
--TestProject.ModuleB.fxn/0 ->
----TestProject.ModuleA.fxn/0 -> leaf

--TestProject.ModuleC.fxn/0 ->
----TestProject.ModuleC.local_leaf/0 -> leaf

--TestProject.ModuleD.fxn/0 ->
----TestProject.ModuleD.local_remote/0 ->
------TestProject.ModuleA.fxn/0 -> leaf

```

## Next steps
* ✅ Capture local function calls as well
  * Hide local functions from graph
* ✅ Make it easy to run on other repositories
  * ✅ allow `mix visualize` to accept an arg for root function
  * Test on another repo!
* Add tests
  * ✅ Easier manual test of full `mix visualize`
  * Test compilation tracer
  * Test Graphing independently
  * Test `:ets` to `Map` fxn
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
  * Needs to collect more data - struct step


## Resources

* [Dashbit tracer example](https://gist.github.com/wojtekmach/4e04cbda82ba88af3f84c44ec746b7ca#file-import2alias-ex-L20)

## Installation

Try it out on your project!

```elixir
def deps do
  [
    {:code_vis, git: "https://github.com/shamshirz/code_vis.git", tag: "0.1"}
  ]
end
```

```bash
> mix deps.get
> mix visualize YourModule.and_function/arity
```
