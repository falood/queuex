alias Queuex.Backends.RedBlackTree
alias Queuex.Backends.RedBlackTree.Node

defmodule Queuex.Backends.RedBlackTree.Node do
  @moduledoc """
  The origin version of this module module is forked from https://github.com/SenecaSystems/red_black_tree.
  """
  defstruct(
    color: :black,
    depth: 1,
    priority: nil,
    value: nil,
    left: nil,
    right: nil
  )

  def new(priority, value, depth \\ 1) do
    %__MODULE__{priority: priority, value: value, depth: depth}
  end

  def color(%__MODULE__{}=node, color) do
    %__MODULE__{ node | color: color}
  end
end

defmodule Queuex.Backends.RedBlackTree do
  @moduledoc """
  The origin version of this module module is forked from https://github.com/SenecaSystems/red_black_tree.
  """

  @behaviour Queuex.Backends

  defstruct root: nil, size: 0

  @doc """
  O(1)
  """
  def new() do
    %RedBlackTree{}
  end

  @doc """
  O(log2(n))
  """
  def push(%RedBlackTree{root: nil}=tree, priority, value) do
    %RedBlackTree{tree | root: Node.new(priority, value), size: 1}
  end

  def push(%RedBlackTree{root: root, size: size}=tree, priority, value) do
    {nodes_added, new_root} = do_insert(root, priority, value, 1)
    %RedBlackTree{
      tree |
      root: make_node_black(new_root),
      size: size + nodes_added
    }
  end

  @doc """
  O(log2(n))
  """
  def pop(%RedBlackTree{root: root, size: size}=tree) do
    {kv, nodes_removed, new_root} = do_smallest(root)
    {
      kv,
      %RedBlackTree{
        tree |
        root: new_root,
        size: size - nodes_removed
      }
    }
  end

  @doc """
  O(n)
  """
  def has_value?(%RedBlackTree{root: root}, value) do
    do_has_value?(root, value)
  end

  defp do_has_value?(nil, _value), do: false
  defp do_has_value?(%Node{value: value}, value), do: true
  defp do_has_value?(%Node{left: left, right: right}, value) do
    do_has_value?(left, value) || do_has_value?(right, value)
  end

  @doc """
  O(n)
  """
  def has_priority_value?(%RedBlackTree{root: root}, priority, value) do
    do_has_priority_value?(root, priority, value)
  end

  defp do_has_priority_value?(nil, _priority, _value), do: false
  defp do_has_priority_value?(%Node{left: left, right: right, priority: node_priority, value: node_value}, priority, value) do
    node_priority === priority
    && node_value === value
    || do_has_priority_value?(left, priority, value)
    || do_has_priority_value?(right, priority, value)
  end

  @doc """
  O(1)
  """
  def size(%RedBlackTree{size: size}) do
    size
  end

  @doc """
  O(n)
  """
  def to_list(%RedBlackTree{root: root}) do
    do_to_list(root)
  end

  defp do_to_list(nil), do: []
  defp do_to_list(%Node{left: left, right: right, priority: priority, value: value}) do
    do_to_list(left) ++ [{priority, value}] ++ do_to_list(right)
  end


  def balance(%RedBlackTree{root: root}=tree) do
    %RedBlackTree{tree | root: do_balance(root)}
  end

  ## Helpers

  defp make_node_black(%Node{}=node) do
    Node.color(node, :black)
  end

  ### Operations

  #### Insert
  defp do_insert(nil, insert_priority, insert_value, depth) do
   {
      1,
      %Node{
        Node.new(insert_priority, insert_value, depth) |
        color: :red
      }
    }
  end

  defp do_insert(%Node{priority: node_priority}=node, insert_priority, insert_value, depth) do
    if insert_priority < node_priority do
      do_insert_left(node, insert_priority, insert_value, depth)
    else
      do_insert_right(node, insert_priority, insert_value, depth)
    end
  end

  defp do_insert_left(%Node{left: left}=node, insert_priority, insert_value, depth) do
    {nodes_added, new_left} = do_insert(left, insert_priority, insert_value, depth + 1)
    {nodes_added, %Node{node | left: do_balance(new_left)}}
  end

  defp do_insert_right(%Node{right: right}=node, insert_priority, insert_value, depth) do
    {nodes_added, new_right} = do_insert(right, insert_priority, insert_value, depth + 1)
    {nodes_added, %Node{node | right: do_balance(new_right)}}
  end


  #### Smallest

  defp do_smallest(nil) do
    {nil, 0, nil}
  end

  defp do_smallest(%Node{left: nil, priority: priority, value: value}=node) do
    {{priority, value}, 1, do_delete_node(node)}
  end

  defp do_smallest(%Node{left: left}=node) do
    {{priority, value}, 1, new_left} = do_smallest(left)
    {
      {priority, value},
      1,
      %Node{
        node |
        left: do_balance(new_left)
      }
    }
  end


  defp do_delete_node(%Node{left: left, right: right}) do
    cond do
      (left === nil && right === nil) -> nil
      (left === nil && right) -> %Node{right | depth: right.depth - 1}
      (left && right === nil) -> %Node{left | depth: left.depth - 1}
      true ->
        do_balance(%Node{
          left |
          depth: left.depth - 1,
          left: do_balance(promote(left)),
          right: right
        })
    end
  end


  defp promote(nil) do
    nil
  end

  defp promote(%Node{left: nil, right: nil, depth: depth}=node) do
    %Node{ node | color: :red, depth: depth - 1 }
  end

  defp promote(%Node{left: left, right: nil, depth: depth}) do
    %Node{ left | color: :red, depth: depth - 1}
  end

  defp promote(%Node{left: nil, right: right, depth: depth}) do
    %Node{ right | color: :red, depth: depth - 1}
  end

  defp promote(%Node{left: left, right: right, depth: depth}) do
    balance(%Node{
      left |
      depth: depth - 1,
      left: do_balance(promote(left)),
      right: right
    })
  end

  defp do_balance(
    %Node{
      color: :black,
      left: a_node,
      right: %Node{
        color: :red,
        left: c_node,
        right: %Node{
          color: :red,
          left: e_node,
          right: g_node
        }=f_node
      }=d_node
    }=b_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end

  defp do_balance(
    %Node{
      color: :black,
      left: a_node,
      right: %Node{
        color: :red,
        left: %Node{
          color: :red,
          left: c_node,
          right: e_node
        }=d_node,
        right: g_node
      }=f_node
    }=b_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end
  defp do_balance(%Node{
      color: :black,
      left: %Node{
        color: :red,
        left: %Node{
          color: :red,
          left: a_node,
          right: c_node
        }=b_node,
        right: e_node
      }=d_node,
      right: g_node
    }=f_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end

  defp do_balance(%Node{
      color: :black,
      left: %Node{
        color: :red,
        left: a_node,
        right: %Node{
          color: :red,
          left: c_node,
          right: e_node
        }=d_node
      }=b_node,
      right: g_node
    }=f_node) do

    balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node)
  end


  defp do_balance(node) do
    node
  end

  defp balanced_tree(a_node, b_node, c_node, d_node, e_node, f_node, g_node) do
    min_depth = min_depth([a_node, b_node, c_node, d_node, e_node, f_node, g_node])
    %Node {
      d_node |
      color: :red,
      depth: min_depth,
      left: %Node{b_node | color: :black, depth: min_depth + 1,
        left: %Node{a_node | depth: min_depth + 2},
        right: %Node{c_node | depth: min_depth + 2}},
      right: %Node{f_node | color: :black, depth: min_depth + 1,
        left: %Node{e_node | depth: min_depth + 2},
        right: %Node{g_node | depth: min_depth + 2},}
    }
  end

  defp min_depth(list_of_nodes) do
    Enum.reduce(list_of_nodes, -1, fn (node, acc) ->
      if acc == -1 || node.depth < acc do
        node.depth
      else
        acc
      end
    end)
  end
end

defimpl Inspect, for: RedBlackTree do
  import Inspect.Algebra

  def inspect(tree, opts) do
    concat ["#RedBlackTree<", Inspect.List.inspect(RedBlackTree.to_list(tree), opts), ">"]
  end
end
