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
  def push([], priority, value), do: [{priority, value}]
  def push([{list_priority, _}=h | t], priority, value) do
    if priority <= list_priority do
      [{priority, value}, h | t]
    else
      [h | push(t, priority, value)]
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
  def has_value?([{_, value} | _], value), do: true
  def has_value?([_ | t], value) do
    has_value?(t, value)
  end

  @doc """
  O(n)
  """
  def has_priority_value?([], _, _), do: false
  def has_priority_value?([{priority, value} | _], priority, value), do: true
  def has_priority_value?([_ | t], priority, value) do
    has_priority_value?(t, priority, value)
  end
end
