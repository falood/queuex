require Logger

defmodule Queuex.Worker do
  defstruct module: nil, pid: nil, num: 0, max_num: 0, unique: false, backend: nil, queue: nil

  use GenServer

  def start_link([module|_]=args) do
    GenServer.start_link(__MODULE__, args, name: module)
  end

  def init([module, max_num, backend, unique]) do
    {:ok, pid} = Queuex.Supervisor.start_link(module)
    {
      :ok,
      %__MODULE__{
        module: module,
        pid: pid,
        max_num: max_num,
        unique: unique,
        backend: backend,
        queue: backend.new
      }
    }
  end

  def handle_cast({priority, term}, %__MODULE__{num: num, max_num: num, unique: true, queue: queue}=sd) do
    queue =
      if sd.backend.has_value?(queue, term) do
        Logger.info "Queuex #{sd.module}: Repeated task ignored."
        queue
      else
        queue |> sd.backend.push(priority, term)
      end
    {:noreply, %{sd | queue: queue}}
  end

  def handle_cast({priority, term}, %__MODULE__{num: num, max_num: num, unique: false, queue: queue}=sd) do
    {:noreply, %{sd | queue: sd.backend.push(queue, priority, term)}}
  end

  def handle_cast({_priority, term}, %__MODULE__{num: num}=sd) do
    {sd.pid, sd.module} |> new_worker |> send term
    {:noreply, %{sd | num: num + 1}}
  end

  def handle_cast(_, sd) do
    Logger.info "Queuex #{sd.module}: Unknown cask message ignored."
    {:noreply, sd}
  end


  def handle_call(:status, _from, sd) do
    {
      :reply,
      %{ avalible: sd.max_num - sd.num,
         active: sd.num,
         backend: sd.backend,
         unique: sd.unique,
         queue_size: sd.queue |> sd.backend.size,
      },
      sd
    }
  end

  def handle_call(_, _, sd) do
    Logger.info "Queuex #{sd.module}: Unknown call message ignored."
    {:noreply, sd}
  end


  # result is :normal | {error, stack}
  def handle_info({:DOWN, ref, :process, _pid, _result}, %__MODULE__{num: num}=sd) do
    Logger.info "Queuex #{sd.module}: Task completed."
    ref |> Process.demonitor [:flush]
    case sd.queue |> sd.backend.pop do
      {nil, queue} ->
        {:noreply, %{sd | num: num - 1, queue: queue}}
      {{_priority, term}, queue} ->
        {sd.pid, sd.module} |> new_worker |> send term
        {:noreply, %{sd | num: num, queue: queue}}
    end
  end


  defp new_worker({pid, module}) do
    Logger.info "Queuex #{module}: Task started."
    {:ok, worker_pid} = Supervisor.start_child pid, []
    Process.monitor worker_pid
    worker_pid
  end
end
