# CodeVis

experiments for visualizing elixir applications

### Run

```bash
> mix run scripts/tree_tracer.exs

CodeVis.i_alias/0 ->
--CodeVis.ModuleC.fxn/0 -> leaf
--CodeVis.ModuleB.fxn/0 ->
----CodeVis.ModuleA.fxn/0 -> leaf
```

## Next steps
* Try out `digraph`
  * or an equivalent tool `https://github.com/mikowitz/graphvix`
* This basic version should be okay enough to try on a larger code base

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

