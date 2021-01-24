defmodule CodeVis do
  @moduledoc """
  Documentation for `CodeVis`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> CodeVis.hello()
      :world

  """
  def hello do
    :world
  end

  def i_alias do
    CodeVis.ModuleC.fxn()
    CodeVis.ModuleB.fxn()
  end
end
