defmodule Queuex.Supervisor do
  use Supervisor

  def start_link(module) do
    Supervisor.start_link(__MODULE__, [module])
  end

  def init([module]) do
    [ worker(module, [], [restart: :temporary])
    ] |> supervise(strategy: :simple_one_for_one)
  end
end
