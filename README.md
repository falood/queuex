Queuex
======

> Queuex is a Priority Queue.

[![Build Status](https://img.shields.io/travis/falood/queuex.svg?style=flat-square)](https://travis-ci.org/falood/queuex)
[![Hex.pm Version](https://img.shields.io/hexpm/v/queuex.svg?style=flat-square)](https://hex.pm/packages/queuex)
[![Hex.pm Downloads](https://img.shields.io/hexpm/dt/queuex.svg?style=flat-square)](https://hex.pm/packages/queuex)


These backends are supported:

    1. List (Queuex.Backends.List)
    2. Red-black tree (Queue.Backends.RedBlackTree)


## Usage

    1. Define your queue module.
```elixir
defmodule MyQueue do
  use Queuex, max_num: 3, worker: :my_worker

  def my_worker(term, _priority) do
    :timer.sleep(10000)
    term |> IO.inspect
  end
end
```

    2. supervise your queue module

```elixir
[ MyQueue.child_spec
  ... # your other supervisor or worker
] |> supervise strategy: :one_for_one
```

    3. push term to queue

```elixir
MyQueue.push(term, priority)
MyQueue.push(term) # push term with default priority
```

### Options

`:max_num`: integer, max worker numbers

`:worker`: atom, function to process term

`:backend`: queue backend, `Queuex.Backends.List`(default) or `Queuex.Backends.RedBlackTree`

`:unique`: boolean, whether repeated term is allowned in queue

`:default_priority`, integer, default priority for &Module.push/1


## TODO
- [ ] Benchmark
- [ ] Document
