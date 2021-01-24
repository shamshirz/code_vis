defmodule CodeVisTest do
  use ExUnit.Case
  doctest CodeVis

  test "greets the world" do
    assert CodeVis.hello() == :world
  end
end
