defmodule TestProject do
  def i_alias do
    TestProject.ModuleA.fxn()
    TestProject.ModuleB.fxn()
    TestProject.ModuleC.fxn()
    TestProject.ModuleD.fxn()
  end

  defmodule ModuleA do
    def fxn, do: local_non_user_remote()
    defp local_non_user_remote, do: [3] |> Enum.map(fn num -> num + 1 end)
  end

  defmodule ModuleB do
    def fxn, do: TestProject.ModuleA.fxn()
  end

  defmodule ModuleC do
    def fxn, do: local_leaf()
    defp local_leaf, do: 4
  end

  defmodule ModuleD do
    def fxn, do: local_remote()
    defp local_remote, do: TestProject.ModuleA.fxn()
  end
end

defmodule SideTree do
  def fxn do
    SideTree.One.fxn()
    SideTree.Two.fxn()
  end

  defmodule One do
    def fxn, do: 4
  end

  defmodule Two do
    def fxn, do: 4
  end
end
