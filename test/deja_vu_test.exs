defmodule DejaVuTest do
  use ExUnit.Case
  doctest DejaVu

  defmodule TestAction do
    use DejaVu.Action

    @impl(DejaVu.Action)
    def run({pid, count}, _time_state) do
      count = count + 1
      Process.send pid, {:tick, count}, []
      {pid, count}
    end
  end

  test "starts the loop" do
    alive = DejaVu.Loop.alive?()
    assert alive == true
  end

  test "runs the loop" do
    DejaVu.add_action(TestAction)
    pid = self()
    Task.async(fn -> DejaVu.run({pid, 0}) end)
    receive do
      {:tick, count} ->
        assert count == 1
      _ -> assert false
    after
      1000 -> assert false
    end
    receive do
      {:tick, count} ->
        assert count == 2
      _ -> assert false
    after
      1000 -> assert false
    end
  end
end
