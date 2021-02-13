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

      main_color = get_in(stats, [Main, :color])
      main_1_color = get_in(stats, [Main.One, :color])
      main_2_color = get_in(stats, [Main.Two, :color])

      assert main_color != main_1_color
      assert main_color != main_2_color
      assert main_1_color != main_2_color
    end
  end

  defp adjacency_map do
    %{
      {Main, :fxn, 0} => %{children: [{Main.One, :fxn, 0}, {Main.Two, :fxn, 0}]},
      {Main.One, :fxn, 0} => %{children: [{Main.Two, :fxn, 0}]},
      {Main.Two, :fxn, 0} => %{children: []}
    }
  end
end
