defmodule ExFunky.Maybe do

  @moduledoc """
  This modules allows working with values representing the posibility of missing values.

  A `Maybe` value is either a present value (`{:some, value}`) or no value at all (`:none`).
  """

  @typedoc """
  A `Maybe` value is either a present value (`{:some, value}`) or no value at all (`:none`).
  """
  @type t :: :none | {:some, term}

  @type value :: term
  
  @type acc :: term

  @typedoc """
  A binder is a function that given a value returns a `Maybe` value
  """
  @type binder :: (value -> t)

  @typedoc """
  A mapper is a function that given a value returns another value.
  """
  @type mapper :: (value -> value)

  @typedoc """
  A predicate is a function that given a value returns boolean.
  """
  @type predicate :: (value -> boolean)

  @typedoc """
  A folder is a function that given an accumulator and a value returns a new accumulator.
  """
  @type folder :: (acc, value -> term)


  @doc """
  Returns a map representing `:some` `value`.

  ## Examples

      iex> ExFunky.Maybe.some 42
      {:some, 42}

  """
  @spec some(term) :: t()
  def some(value), do: {:some, value}


  @doc """
  Returns a value representing `:none`.

  ## Examples

      iex> ExFunky.Maybe.none()
      :none

  """
  @spec none() :: t()
  def none do :none end


  @doc """
  Returns whether the `value` represents a `Maybe` value.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.is_maybe()
      true

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.is_maybe()
      true

      iex> 42
      ...> |> ExFunky.Maybe.is_maybe()
      false

      iex> nil
      ...> |> ExFunky.Maybe.is_maybe()
      false

  """
  @spec is_maybe(term) :: boolean
  def is_maybe(value)
  def is_maybe({:some, _}), do: true
  def is_maybe(:none), do: true
  def is_maybe(_), do: false


  @doc """
  Returns whether the `value` represents `:some` value.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.is_some()
      true

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.is_some()
      false

      iex> nil
      ...> |> ExFunky.Maybe.is_some()
      false

  """
  @spec is_some(term) :: boolean
  def is_some(value)
  def is_some({:some, _}), do: true
  def is_some(:none), do: false
  def is_some(_), do: false
  

  @doc """
  Returns whether the `value` represents `:none`.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.is_none()
      false

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.is_none()
      true

      iex> nil
      ...> |> ExFunky.Maybe.is_none()
      false

  """
  @spec is_none(term) :: boolean
  def is_none(value)
  def is_none({:some, _}), do: false
  def is_none(:none), do: true
  def is_none(_), do: false
  

  @doc """
  Returns a :ok/:error result value from a `maybe`.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.to_trial()
      ExFunky.Trial.ok 42

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.to_trial()
      ExFunky.Trial.error nil

  """
  @spec to_trial(t) :: ExFunky.Trial.t
  def to_trial(maybe)
  def to_trial({:some, x}), do: ExFunky.Trial.ok x
  def to_trial(:none), do: ExFunky.Trial.error nil


  @doc """
  Returns the value of a `maybe` or fails with a `:enoent` error.

  ## Examples

      iex> ExFunky.Maybe.some(42) |> ExFunky.Maybe.get_value!()
      42

      iex> try do
      ...>    ExFunky.Maybe.none() |> ExFunky.Maybe.get_value!()
      ...>    :ok
      ...> catch
      ...>    x -> x
      ...> end
      :enoent

  """
  @spec get_value!(t) :: term | no_return
  def get_value!(maybe)
  def get_value!({:some, x}), do: x
  def get_value!(:none), do: throw :enoent


  @doc """
  Applies a given `binder` function to `x` if the given `maybe` is `{:some, x}`.
  The result is given as such, unlike the `map/2` which wraps the result 
  into a `:some` value.

  Returns `:none` if the `maybe` is `:none`.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.bind(fn x -> ExFunky.Maybe.some(x + 1) end)
      {:some, 43}

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.bind(fn _ -> ExFunky.Maybe.none() end)
      :none

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.bind(fn x -> ExFunky.Maybe.some(x + 1) end)
      :none

  """
  @spec bind(t, binder) :: t
  def bind(maybe, binder)
  def bind({:some, x}, binder) when is_function(binder, 1), do: binder.(x)
  def bind(:none, binder) when is_function(binder, 1), do: :none


  @doc """
  Applies a given `mapper` function to `x` if the given `maybe` is `{:some, x}`. 
  The result is wrapped into a `:some`, unlike the `bind/2` which return
  the function's result as such.
  
  Returns `:none` if the `maybe` is `:none`.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.map(fn x -> x + 1 end)
      {:some, 43}

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.map(fn x -> x + 1 end)
      :none

  """
  @spec map(t, mapper) :: t
  def map(maybe, mapper)
  def map({:some, x}, mapper) when is_function(mapper, 1), do: mapper.(x) |> some
  def map(:none, mapper) when is_function(mapper, 1), do: :none


  @doc """
  Returns `true` if the given `maybe` is `{:some, x}` and `predicate.(x)` is `true`.
  
  Returns `false` if the `maybe` is `:none`.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.exists(fn _ -> true end)
      true

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.exists(fn _ -> false end)
      false

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.exists(fn _ -> true end)
      false

  """
  @spec exists(t, predicate) :: boolean
  def exists(maybe, predicate)
  def exists({:some, x}, predicate) when is_function(predicate, 1), do: predicate.(x)
  def exists(:none, predicate) when is_function(predicate, 1), do: false


  @doc """
  Returns `true` if the given `maybe` is `{:some, x}` and `predicate.(x)` is `true`.
  
  Returns `false` if the `maybe` is `:none`.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.filter(fn _ -> true end)
      {:some, 42}

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.filter(fn _ -> false end)
      :none

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.filter(fn _ -> true end)
      :none

  """
  @spec filter(t, predicate) :: t
  def filter(maybe, predicate)
  def filter({:some, x} = value, predicate) when is_function(predicate, 1) do
    cond do
      predicate.(x) -> value
      :else -> :none
    end
  end
  def filter(:none, predicate) when is_function(predicate, 1), do: none()


  @doc """
  Returns `folder(acc, x)` if the given `maybe` is `{:some, x}`.
  
  Returns `acc` if the `maybe` is `:none`.

  ## Examples

      iex> ExFunky.Maybe.some(32) 
      ...> |> ExFunky.Maybe.fold(fn (a, b) -> a + b end, 10)
      42

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.fold(fn (a, b) -> a + b end, 10)
      10

  """
  @spec fold(t, folder, acc) :: acc
  def fold(maybe, folder, accumulator)
  def fold({:some, x}, folder, acc) when is_function(folder, 2), do: folder.(acc, x)
  def fold(:none, folder, acc) when is_function(folder, 2), do: acc


  @doc """
  Returns `1` if the given `maybe` is `{:some, x}`.
  
  Returns `0` if the `maybe` is `:none`.

  ## Examples

      iex> ExFunky.Maybe.some(32) 
      ...> |> ExFunky.Maybe.count()
      1

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.count()
      0

  """
  @spec count(t) :: 0 | 1
  def count(maybe)
  def count({:some, _}), do: 1
  def count(:none), do: 0


  @doc """
  Flattens the `maybe` value one level, if needed.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.flatten()
      {:some, 42}

      iex> ExFunky.Maybe.some(ExFunky.Maybe.some(42))
      ...> |> ExFunky.Maybe.flatten()
      {:some, 42}

      iex> ExFunky.Maybe.some(ExFunky.Maybe.some(ExFunky.Maybe.some(42)))
      ...> |> ExFunky.Maybe.flatten()
      {:some, {:some, 42}}

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.flatten()
      :none

  """
  @spec flatten(t) :: t
  def flatten(maybe)
  def flatten({:some, {:some, x}}), do: {:some, x}
  def flatten({:some, x}), do: {:some, x}
  def flatten(:none), do: :none


  @doc """
  Flattens the `maybe` value one level, if needed.

  ## Examples

      iex> ExFunky.Maybe.some(42) 
      ...> |> ExFunky.Maybe.flatten_all()
      {:some, 42}

      iex> ExFunky.Maybe.some(ExFunky.Maybe.some(42))
      ...> |> ExFunky.Maybe.flatten_all()
      {:some, 42}

      iex> ExFunky.Maybe.some(ExFunky.Maybe.some(ExFunky.Maybe.some(42)))
      ...> |> ExFunky.Maybe.flatten_all()
      {:some, 42}

      iex> ExFunky.Maybe.none() 
      ...> |> ExFunky.Maybe.flatten_all()
      :none

  """
  @spec flatten_all(t) :: t
  def flatten_all(maybe)
  def flatten_all({:some, {:some, x}}), do: flatten_all({:some, x})
  def flatten_all({:some, x}), do: {:some, x}
  def flatten_all(:none), do: :none


  @doc """
  Returns `{:some, x}` if the given `list` has any element and `x` is 
  the first element of the list.

  Returns `:none` if the `list` is `empty`.

  ## Examples

      iex> [] 
      ...> |> ExFunky.Maybe.list_first()
      :none

      iex> [1] 
      ...> |> ExFunky.Maybe.list_first()
      {:some, 1}

      iex> [1,2] 
      ...> |> ExFunky.Maybe.list_first()
      {:some, 1}

  """
  @spec list_first(list(value)) :: t
  def list_first(list)
  def list_first([]), do: :none
  def list_first([x | _]), do: some x


  @doc """
  Returns `{:some, x}` if the given `list` has exactly one element.

  Returns `:none` if the `list` is `empty` or has more than one element.

  ## Examples

      iex> [] 
      ...> |> ExFunky.Maybe.list_single()
      :none

      iex> [1] 
      ...> |> ExFunky.Maybe.list_single()
      {:some, 1}

      iex> [1,2] 
      ...> |> ExFunky.Maybe.list_single()
      :none

  """
  @spec list_single(list(value)) :: t
  def list_single(list)
  def list_single([x]), do: some x
  def list_single([]), do: :none
  def list_single([_ | _]), do: :none

end
