defmodule CodeVisTest do
  use ExUnit.Case
  alias CodeVis.ProjectAnalysis

  describe "ProjectAnalysis" do
    test "user_modules/0" do
      my_mods =
        Enum.sort([
          CodeVis,
          CodeVis.Application,
          CodeVis.FunctionTracer,
          CodeVis.Plug.Visualize,
          CodeVis.ProjectAnalysis,
          CodeVis.Repo,
          Display,
          Display.GraphIt,
          Mix.Tasks.CodeVis.Server,
          Mix.Tasks.Visualize
        ])

      assert my_mods == ProjectAnalysis.user_modules() |> Enum.sort()
    end
  end

  describe "Display" do
    test "as_string/2 graphs the correct number of vertices" do
      result = Display.as_string(adjacency_map(), {Main, :fxn, 0})

      assert result =~ "v0"
      assert result =~ "v1"
      assert result =~ "v2"
      refute result =~ "v3"
    end

    test "as_string/2 graphs the correct edges" do
      result = Display.as_string(adjacency_map(), {Main, :fxn, 0})

      assert result =~ "v0 -> v1"
      assert result =~ "v1 -> v2"
      assert result =~ "v0 -> v2"
      refute result =~ "v2 -> v1"
    end

    test "as_string/2 fails with circular dep" do
      map = %{
        {Main, :fxn, 0} => %{children: [{Main.One, :fxn, 0}, {Main.Two, :fxn, 0}]},
        {Main.One, :fxn, 0} => %{children: [{Main.Two, :fxn, 0}]},
        {Main.Two, :fxn, 0} => %{children: [{Main, :fxn, 0}]}
      }

      result = Display.as_string(map, {Main, :fxn, 0})

      assert result =~ "v0 -> v1"
      assert result =~ "v1 -> v2"
      assert result =~ "v0 -> v2"
      refute result =~ "v2 -> v1"
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
