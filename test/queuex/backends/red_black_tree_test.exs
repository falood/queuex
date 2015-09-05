defmodule Queuex.Backends.RedBlackTreeTest do
  use ExUnit.Case, async: true
  alias Queuex.Backends.RedBlackTree, as: Q

  test "initializing" do
    assert %Q{} == Q.new
    assert 0 == Q.new |> Q.size
  end

  test "push" do
    queue = Q.new |> Q.push(1, :a)
    assert [{1, :a}] == queue |> Q.to_list
    assert 1 == queue |> Q.size

    queue = queue |> Q.push(0, :c)
    assert [{0, :c}, {1, :a}] == queue |> Q.to_list
    assert 2 == queue |> Q.size
  end

  test "pop" do
    queue = Q.new
    assert {nil, ^queue} = queue |> Q.pop

    queue = queue |> Q.push(1, :a)
    assert {{1, :a}, new_queue} = queue |> Q.pop
    assert [] == new_queue |> Q.to_list
    assert 0 = new_queue |> Q.size

    queue = queue |> Q.push(2, :b)
    assert {{1, :a}, new_queue} = queue |> Q.pop
    assert [{2, :b}] == new_queue |> Q.to_list
    assert 1 = new_queue |> Q.size

    queue = queue |> Q.push(0, :c)
    assert {{0, :c}, new_queue} = queue |> Q.pop
    assert [{1, :a}, {2, :b}] == new_queue |> Q.to_list
    assert 2 = new_queue |> Q.size
  end

  test "has_value? and has_priority_value?" do
    queue = Q.new |> Q.push(1, :a) |> Q.push(2, :a)
    assert true == queue |> Q.has_value?(:a)
    assert false == queue |> Q.has_value?(:b)

    assert true == queue |> Q.has_priority_value?(1, :a)
    assert false == queue |> Q.has_priority_value?(3, :a)
    assert false == queue |> Q.has_priority_value?(1, :b)
  end


  test "order" do
    queue =
      [ {1, :a}, {2, :b}, {2, :c}, {2, :d}, {3, :e}, {2, :f}, {2, :g}
      ] |> Enum.reduce Q.new, fn({p, v}, acc) -> acc |> Q.push(p, v) end
    {{1, :a}, queue} = queue |> Q.pop
    {{2, :b}, queue} = queue |> Q.pop
    {{2, :c}, queue} = queue |> Q.pop
    {{2, :d}, queue} = queue |> Q.pop
    {{2, :f}, queue} = queue |> Q.pop
    {{2, :g}, queue} = queue |> Q.pop
    {{3, :e}, %Q{size: 0, root: nil}} = queue |> Q.pop
  end
end
