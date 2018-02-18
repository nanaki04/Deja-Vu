defmodule DejaVu.Loop do
  use GenServer

  @type time_state :: DejaVu.time_state

  @spec start_link(any) :: GenServer.on_start
  def start_link(_) do
    GenServer.start_link __MODULE__, %DejaVu{}, name: __MODULE__
  end

  @spec add_action(DejaVu.Action.action) :: term
  def add_action(action) do
    GenServer.call(__MODULE__, {:add_action, action})
  end

  @spec run(term) :: term
  def run(action_state) do
    run action_state, alive?()
  end

  @spec run(term, false) :: term
  def run(action_state, false), do: action_state

  @spec run(term, true) :: term
  def run(action_state, true) do
    {action_state, state} = GenServer.call(__MODULE__, {:tick, action_state})
    wait_for_next_tick(state)
    run action_state
  end

  @spec alive?() :: boolean
  def alive? do
    case GenServer.whereis(__MODULE__) do
      nil -> false
      _ -> true
    end
  end

  @spec pause :: term
  def pause do
    GenServer.call __MODULE__, :pause
  end

  @spec resume :: term
  def resume do
    GenServer.call __MODULE__, :resume
  end

  @impl(GenServer)
  def init(state) do
    {:ok, state}
  end

  @impl(GenServer)
  def handle_call({:add_action, action}, _, state) do
    state
    |> Map.update!(:actions, &[action | &1])
    |> (&{:reply, &1, &1}).()
  end

  @impl(GenServer)
  def handle_call({:tick, action_state}, _, %{pause: true} = state) do
    {:reply, {action_state, state}, state}
  end

  @impl(GenServer)
  def handle_call({:tick, action_state}, _, %{actions: actions} = state) do
    state = calculate_delta_time(state)
    actions
    |> Enum.reverse
    |> Enum.reduce(action_state, fn action, action_state -> action.run(action_state, state) end)
    |> (&{:reply, {&1, state}, state}).()
  end

  @impl(GenServer)
  def handle_call(:pause, _, state) do
    %{state | paused: true}
    |> (&{:reply, &1, &1}).()
  end

  @impl(GenServer)
  def handle_call(:resume, _, state) do
    %{state | paused: false}
    |> (&{:reply, &1, &1}).()
  end

  @spec calculate_delta_time(time_state) :: time_state
  defp calculate_delta_time(%{frame_rate: fps, frame_start_time: start} = state) do
    now = System.system_time(:milliseconds)
    diff = now - start
    dt = case diff do
      0 -> 0
      diff -> (1000 / fps) / diff
    end

    state
    |> (&%{&1 | dt: dt}).()
    |> (&%{&1 | frame_start_time: now}).()
  end

  @spec wait_for_next_tick(time_state) :: time_state
  defp wait_for_next_tick(%{frame_rate: fps, frame_start_time: start} = state) do
    Process.send_after self(), :tick, max(0, fps - (System.system_time(:millisecond) - start))
    receive do 
      :tick -> state
    after
      fps -> state
    end
  end

end
