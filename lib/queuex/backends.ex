defmodule Queuex.Backends do

  @type queue :: term
  @type priority :: term
  @type value :: term

  @callback new() :: queue

  @callback size(queue) :: integer

  @callback to_list(queue) :: [{priority, value}]

  @callback push(queue, priority, value) :: queue

  @callback pop(queue) :: {nil | {priority, value}, queue}

  @callback has_value?(queue, value) :: boolean

  @callback has_priority_value?(queue, priority, value) :: boolean
end
