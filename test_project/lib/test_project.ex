defmodule TestProject do
  def i_alias do
    TestProject.ModuleA.fxn()
    TestProject.ModuleB.fxn()
    TestProject.ModuleC.fxn()
  end

  defmodule ModuleA do
    def fxn, do: 4
  end

  defmodule ModuleB do
    def fxn, do: TestProject.ModuleA.fxn()
  end

  defmodule ModuleC do
    def fxn, do: 4
  end
end
