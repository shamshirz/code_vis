defmodule CodeVisTest do
  use ExUnit.Case
  alias CodeVis.ProjectAnalysis

  describe "ProjectAnalysis" do
    test "user_modules/0" do
      my_mods =
        Enum.sort([
          CodeVis,
          Mix.Tasks.Visualize,
          Display.GraphIt,
          CodeVis.ProjectAnalysis,
          CodeVis.FunctionTracer,
          CodeVis.Repo,
          Display
        ])

      assert my_mods == ProjectAnalysis.user_modules() |> Enum.sort()
    end
  end

  describe "CodeVis" do
    test "module_stats/1" do
      stats = CodeVis.module_stats(adjacency_map())

      assert get_in(stats, [Main, :outgoing]) == 2
      assert get_in(stats, [Main.One, :outgoing]) == 1
      assert get_in(stats, [Main.Two, :outgoing]) == 0
    end

    test "module_stats_colors/1" do
      stats =
        adjacency_map()
        |> CodeVis.module_stats()
        |> CodeVis.assign_module_colors()

      assert get_in(stats, [Main, :color]) == "red"
      assert get_in(stats, [Main.One, :color]) == "orange"
      assert get_in(stats, [Main.Two, :color]) == "yellow"
    end
  end

  defp adjacency_map do
    %{
      {Main, :fxn, 0} => [{Main.One, :fxn, 0}, {Main.Two, :fxn, 0}],
      {Main.One, :fxn, 0} => [{Main.Two, :fxn, 0}],
      {Main.Two, :fxn, 0} => []
    }
  end
end
