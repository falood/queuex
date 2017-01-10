defmodule Queuex do
  defmacro __using__(opts) do
    max_num          = opts |> Keyword.fetch!(:max_num)
    worker           = opts |> Keyword.fetch!(:worker)
    backend          = opts |> Keyword.get(:backend, Queuex.Backends.List)
    unique           = opts |> Keyword.get(:unique, false)
    default_priority = opts |> Keyword.get(:default_priority, 1)
    unique in [:strictly, true, false] || raise "unknown value"

    quote do
      @max_num          unquote(max_num)
      @worker           unquote(worker)
      @unique           unquote(unique)
      @backend          unquote(backend)
      @default_priority unquote(default_priority)
      @before_compile   unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_) do
    quote do
      def child_spec do
        Supervisor.Spec.worker(Queuex.Worker, [[__MODULE__, @max_num, @backend, @unique]], id: __MODULE__)
      end

      def start_link do
        func = fn -> receive do {term, priority} -> apply __MODULE__, @worker, [term, priority] end end
        {:ok, :proc_lib.spawn_link(func)}
      end

      def push(term) do
        GenServer.cast(__MODULE__, {term, @default_priority})
      end

      def push(term, priority) do
        GenServer.cast(__MODULE__, {term, priority})
      end

      def status do
        GenServer.call(__MODULE__, :status)
      end
    end
  end
end
