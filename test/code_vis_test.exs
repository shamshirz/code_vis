defmodule CodeVisTest do
  use ExUnit.Case
  alias CodeVis.{ProjectAnalysis, Repo}

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

  describe "CodeVis" do
    test "can map recursive calls" do
      Repo.start()
      mfa_main = {Main, :fxn, 0}
      mfa_1 = {Main.One, :fxn, 0}
      mfa_2 = {Main.Two, :fxn, 0}
      user_modules = [Main, Main.One, Main.Two]

      Repo.insert({mfa_main, mfa_1})
      Repo.insert({mfa_main, mfa_2})
      _recursive_call = Repo.insert({mfa_2, mfa_main})

      adj_map = CodeVis.build_adjacency_map(%{}, mfa_main, user_modules)

      assert Map.has_key?(adj_map, mfa_main)
      assert Map.has_key?(adj_map, mfa_1)
      assert Map.has_key?(adj_map, mfa_2)
      assert length(Map.keys(adj_map)) == 3
    end

    test "ignores non-user modules" do
      Repo.start()
      mfa_main = {Main, :fxn, 0}
      mfa_1 = {Dependency.Main, :fxn, 0}
      mfa_2 = {Elixir.BuiltIn, :fxn, 0}
      user_modules = [Main]

      Repo.insert({mfa_main, mfa_1})
      Repo.insert({mfa_main, mfa_2})

      adj_map = CodeVis.build_adjacency_map(%{}, mfa_main, user_modules)

      assert Map.has_key?(adj_map, mfa_main)
      assert Map.get(adj_map, mfa_main) == %{children: []}
    end
  end

  describe "Repo" do
    test "rejects invalid input" do
      assert_raise ArgumentError, fn -> Repo.insert({"not a tuple!", {Main, :fxn, 0}}) end
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
