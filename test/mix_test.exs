defmodule MixTest do
  use ExUnit.Case
  # Copied this strategy from
  # xref tests:
  # https://github.com/elixir-lang/elixir/blob/v1.11.3/lib/mix/test/mix/tasks/xref_test.exs
  # How they do Setup:
  # They write a file (with elixir module string inside)
  # Run `mix compile` IN THE TEST!
  # Then call the mix function they intend to test

  # That is done through a pretty involved macro to get the current modules file address and then cleanup

  test "temp" do
    assert true
  end

  # test "returns all function calls" do
  #   files = %{
  #     "lib/a.ex" => """
  #     defmodule A do
  #       def a, do: A.a()
  #       def a(arg), do: A.a(arg)
  #       def c, do: B.a()
  #     end
  #     """,
  #     "lib/b.ex" => """
  #     defmodule B do
  #       def a, do: nil
  #     end
  #     """
  #   }

  #   output = [
  #     %{callee: {A, :a, 0}, caller_module: A, file: "lib/a.ex", line: 2},
  #     %{callee: {A, :a, 1}, caller_module: A, file: "lib/a.ex", line: 3},
  #     %{callee: {B, :a, 0}, caller_module: A, file: "lib/a.ex", line: 4}
  #   ]

  #   assert_all_calls(files, output)
  # end

  # defp assert_all_calls(files, expected, after_compile \\ fn -> :ok end) do
  #   in_fixture("no_mixfile", fn ->
  #     generate_files(files)

  #     Mix.Task.run("compile")
  #     after_compile.()
  #     assert Enum.sort(Mix.Tasks.Xref.calls()) == Enum.sort(expected)
  #   end)
  # end

  # defp generate_files(files) do
  #   for {file, contents} <- files do
  #     File.write!(file, contents)
  #   end
  # end
end
