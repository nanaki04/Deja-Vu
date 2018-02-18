defmodule DejaVu.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    Supervisor.start_link([DejaVu.Loop], strategy: :one_for_one, restart: :transient)
  end
end
