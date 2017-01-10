defmodule Queuex.Backends.List do
  @behaviour Queuex.Backends

  @doc """
  O(1)
  """
  def new(), do: []

  @doc """
  O(n)
  """
  def size(list), do: length(list)

  @doc """
  O(n)
  """
  def push([], value, priority), do: [{value, priority}]
  def push([{_, list_priority}=h | t], value, priority) do
    if priority < list_priority do
      [{value, priority}, h | t]
    else
      [h | push(t, value, priority)]
    end
  end

  @doc """
  O(1)
  """
  def pop([]), do: {nil, []}
  def pop([h|t]), do: {h, t}

  @doc """
  O(1)
  """
  def to_list(list), do: list

  @doc """
  O(n)
  """
  def has_value?([], _), do: false
  def has_value?([{value, _} | _], value), do: true
  def has_value?([_ | t], value) do
    has_value?(t, value)
  end

  @doc """
  O(n)
  """
  def has_priority_value?([], _, _), do: false
  def has_priority_value?([{value, priority} | _], value, priority), do: true
  def has_priority_value?([_ | t], value, priority) do
    has_priority_value?(t, value, priority)
  end
end
