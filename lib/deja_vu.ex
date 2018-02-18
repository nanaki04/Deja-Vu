defmodule DejaVu do
  @moduledoc """
  Module to create a interval loop based on a frame rate set in your config settings.
  """

  @type time_state :: %DejaVu{}
  @type action :: DejaVu.Action.action

  defstruct dt: 0,
    start_time: 0,
    frame_start_time: 0,
    frame_rate: Application.get_env(:deja_vu, :frame_rate),
    actions: [],
    paused: false

  @spec run(term) :: term
  def run(state), do: DejaVu.Loop.run state

  @spec add_action(action) :: term
  def add_action(action), do: DejaVu.Loop.add_action action

  @spec pause :: term
  def pause, do: DejaVu.Loop.pause()

  @spec resume :: term
  def resume, do: DejaVu.Loop.resume()

end
