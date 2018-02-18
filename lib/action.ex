defmodule DejaVu.Action do
  @moduledoc """
  Defines an action that can be added to the stack of actions to be executed every frame call.
  Actions can be added to the stack as follows:

  DejaVu.Loop.add_action(action)

  Actions can be defined by creating a module with the use DejaVu.Action declaration,
  and implementing the callback run(action_state, time_state) :: action_state

  The action state will be your application state that will be updated every frame by your actions.
  Note that every action will be expected to handle the same state type.
  The time state is defined by the %DejaVu{} struct, and contains information such as delta time and fps.
  """

  @type action :: module
  @type action_state :: any
  @type time_state :: DejaVu.time_state
  @callback run(action_state, time_state) :: action_state

  defmacro __using__(_opts) do
    quote do
      import DejaVu.Action
      @behaviour DejaVu.Action
    end
  end
end
