defmodule CodeVisTest do
  use ExUnit.Case
  alias CodeVis.ProjectAnalysis

  describe "ProjectAnalysis" do
    test "user_modules/0" do
      my_mods = [
        Mix.Tasks.Visualize,
        Display.GraphIt,
        CodeVis.ProjectAnalysis,
        Display,
        CodeVis.FunctionTracer
      ]

      assert my_mods == ProjectAnalysis.user_modules()
    end
  end
end
