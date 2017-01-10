defmodule Queuex.Backends.ListTest do
  use ExUnit.Case, async: true
  alias Queuex.Backends.List, as: Q

  test "initializing" do
    assert [] == Q.new
    assert 0 == Q.new |> Q.size
  end

  test "push" do
    queue = Q.new |> Q.push(:a, 1)
    assert [{:a, 1}] == queue |> Q.to_list
    assert 1 == queue |> Q.size

    queue = queue |> Q.push(:c, 0)
    assert [{:c, 0}, {:a, 1}] == queue |> Q.to_list
    assert 2 == queue |> Q.size
  end

  test "pop" do
    queue = Q.new
    assert {nil, ^queue} = queue |> Q.pop

    queue = queue |> Q.push(:a, 1)
    assert {{:a, 1}, new_queue} = queue |> Q.pop
    assert [] == new_queue |> Q.to_list
    assert 0 = new_queue |> Q.size

    queue = queue |> Q.push(:b, 2)
    assert {{:a, 1}, new_queue} = queue |> Q.pop
    assert [{:b, 2}] == new_queue |> Q.to_list
    assert 1 = new_queue |> Q.size

    queue = queue |> Q.push(:c, 0)
    assert {{:c, 0}, new_queue} = queue |> Q.pop
    assert [{:a, 1}, {:b, 2}] == new_queue |> Q.to_list
    assert 2 = new_queue |> Q.size
  end

  test "has_value? and has_priority_value?" do
    queue = Q.new |> Q.push(:a, 1) |> Q.push(:a, 2)
    assert true  == queue |> Q.has_value?(:a)
    assert false == queue |> Q.has_value?(:b)

    assert true  == queue |> Q.has_priority_value?(:a, 1)
    assert false == queue |> Q.has_priority_value?(:a, 3)
    assert false == queue |> Q.has_priority_value?(:b, 1)
  end

  test "order" do
    queue =
      [ {:a, 1}, {:b, 2}, {:c, 2}, {:d, 2}, {:e, 3}, {:f, 2}, {:g, 2}
      ] |> Enum.reduce(Q.new, fn({v, p}, acc) -> acc |> Q.push(v, p) end)
    {{:a, 1}, queue} = queue |> Q.pop
    {{:b, 2}, queue} = queue |> Q.pop
    {{:c, 2}, queue} = queue |> Q.pop
    {{:d, 2}, queue} = queue |> Q.pop
    {{:f, 2}, queue} = queue |> Q.pop
    {{:g, 2}, queue} = queue |> Q.pop
    {{:e, 3}, []}    = queue |> Q.pop
  end
end
