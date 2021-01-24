defmodule CodeVis.ModuleB do
  def fxn do
    CodeVis.ModuleA.fxn()
  end
end
