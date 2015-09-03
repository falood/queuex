defmodule Queuex.Backends do
  use Behaviour

  @type queue :: term
  @type priority :: term
  @type value :: term

  defcallback new() :: queue

  defcallback size(queue) :: integer

  defcallback to_list(queue) :: [{priority, value}]

  defcallback push(queue, priority, value) :: queue

  defcallback pop(queue) :: {nil | {priority, value}, queue}

  defcallback has_value?(queue, value) :: boolean

  defcallback has_priority_value?(queue, priority, value) :: boolean
end
