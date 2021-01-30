defmodule CodeVis do
  @moduledoc """
  Top level example module
  This is basically a test and should probably live in /test
  There is no real code here, just an example structure to validate against
  """
  def i_alias do
    CodeVis.ModuleA.fxn()
    CodeVis.ModuleB.fxn()
    CodeVis.ModuleC.fxn()
  end

  defmodule ModuleA do
    def fxn, do: 4
  end

  defmodule ModuleB do
    def fxn, do: CodeVis.ModuleA.fxn()
  end

  defmodule ModuleC do
    def fxn, do: 4
  end
end
