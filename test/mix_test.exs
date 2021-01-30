defmodule TracerTest do
  use ExUnit.Case
  # doctest CodeVis

  test "temp" do
    # xref tests: https://github.com/elixir-lang/elixir/blob/v1.11.3/lib/mix/test/mix/tasks/xref_test.exs
    # How they do Setup:
    # They write a file (with elixir module string inside)
    # Run `mix compile` IN THE TEST!
    # Then call the mix function they intend to test
    assert false
  end
end
