defmodule ExFunky.Trial do

  @moduledoc """
  This modules allows working with values representing the succesful results
  or errors messages.

  A `Trial` value is either a succesful value (`{:ok, value}`) or one of the 
  possible error forms (`{:error, reason}`, `{:errors, [reasons]}`, `:error`).
  """

  @type value :: term
  
  @type reason :: term
  
  @type acc :: term
  # @type ok :: {:ok, value}
  
  # @type error :: {:error, reason} | {:errors, list(reason)}

  @typedoc """
  A `Trial` value is either a succesful value (`{:ok, value}`) or one of the 
  possible error forms (`{:error, reason}`, `{:errors, [reasons]}`, `:error`).
  """
  @type t :: term # ok | error

  @typedoc """
  A binder is a function that given a value returns a `Trial` value
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
  Returns a map representing a successful `value` (`{:ok, value}`).

  ## Examples

      iex> ExFunky.Trial.ok 42
      {:ok, 42}

  """
  @spec ok(term) :: t
  def ok(value), do: {:ok, value}


  @doc """
  Returns a map representing an error result (`{:error, reason}`).

  ## Examples

      iex> ExFunky.Trial.error("Invalid arg")
      {:error, "Invalid arg"}

  """
  @spec error(reason) :: t
  def error(reason \\ :enoent) do {:error, reason} end


  @doc """
  Returns a map representing an error result (`{:errors, reasons}`).

  ## Examples

      iex> ExFunky.Trial.errors(["Invalid arg", "Nil dereferenced"])
      {:errors, ["Invalid arg", "Nil dereferenced"]}

  """
  @spec errors(list(reason)) :: t
  def errors(reasons) when is_list(reasons), do: {:errors, reasons} |> normalize()
  @doc """
  Returns a map representing an error result (`{:errors, reasons}`).

  ## Examples

      iex> ExFunky.Trial.is_trial(nil)
      true

      iex> ExFunky.Trial.is_trial(42)
      true

      iex> ExFunky.Trial.is_trial({:ok, 42})
      true

      iex> ExFunky.Trial.is_trial({:error, :enoent})
      true

      iex> ExFunky.Trial.is_trial({:errors, []})
      true

      iex> ExFunky.Trial.is_trial({:errors, [:invalid_arg, :nul_dereferenced]})
      true

  """
  @spec is_trial(t) :: boolean
  def is_trial(trial)
  def is_trial(_), do: true
  
  @doc """
  Returns a map representing an error result (`{:errors, reasons}`).

  ## Examples

      iex> ExFunky.Trial.normalize(nil)
      {:error, :enoent}

      iex> ExFunky.Trial.normalize(42)
      {:ok, 42}

      iex> ExFunky.Trial.normalize({:ok, 42})
      {:ok, 42}

      iex> ExFunky.Trial.normalize({:error, :enoent})
      {:error, :enoent}

      iex> ExFunky.Trial.normalize({:errors, []})
      {:errors, []}

      iex> ExFunky.Trial.normalize({:errors, [:invalid_arg, :nul_dereferenced]})
      {:errors, [:invalid_arg, :nul_dereferenced]}

  """
  @spec normalize(t) :: t
  def normalize(trial)
  def normalize(nil), do: {:error, :enoent}
  def normalize({:ok, _} = trial), do: trial
  def normalize({:error, _} = trial), do: trial
  def normalize({:errors, [reason]}), do: {:error, reason}
  def normalize({:errors, reasons} = trial) when is_list(reasons), do: trial
  def normalize(x), do: {:ok, x}
  
  @doc """
  Evaluates the corresponding function, `ok_fun` or `err_fun`, depending on
  whether the `trial` is a success or an error

  ## Examples

      iex> ExFunky.Trial.matches(nil, &(&1), &(&1))
      [:enoent]

      iex> ExFunky.Trial.matches(42, &(&1), &(&1))
      42

      iex> ExFunky.Trial.matches({:ok, 42}, &(&1), &(&1))
      42

      iex> ExFunky.Trial.matches({:error, :enoent}, &(&1), &(&1))
      [:enoent]

      iex> ExFunky.Trial.matches({:errors, []}, &(&1), &(&1))
      []

      iex> ExFunky.Trial.matches({:errors, [:invalid_arg, :nul_dereferenced]}, &(&1), &(&1))
      [:invalid_arg, :nul_dereferenced]

  """
  @spec matches(t, (value -> any), (list(reason) -> any)) :: any
  def matches(trial, ok_fun, err_fun) 
    when (is_function(ok_fun, 1) and is_function(err_fun, 1)) do
    case normalize(trial) do
      {:ok, value} -> ok_fun.(value)
      {:error, reason} -> err_fun.([reason])
      {:errors, reasons} -> err_fun.(reasons)
    end
  end
  @doc """
  Returns whether the `trial` value is a success.

  ## Examples
      iex> ExFunky.Trial.is_ok({:ok, 42})
      true

      iex> ExFunky.Trial.is_ok({:error, :enoent})
      false

  """
  @spec is_ok(t) :: boolean
  def is_ok(trial), do: trial |> matches((fn _ -> true end), (fn _ -> false end))
  @doc """
  Returns whether the `trial` value is an error.

  ## Examples
      iex> ExFunky.Trial.is_error({:ok, 42})
      false

      iex> ExFunky.Trial.is_error({:error, :enoent})
      true

  """
  @spec is_error(t) :: boolean
  def is_error(trial), do: trial |> matches((fn _ -> false end), (fn _ -> true end))
  

  @doc """
  Returns a `:some/:none` maybe value from a `Trial`.

  ## Examples

      iex> ExFunky.Trial.ok(42) 
      ...> |> ExFunky.Trial.to_maybe()
      {:some, 42}

      iex> ExFunky.Trial.error() 
      ...> |> ExFunky.Trial.to_maybe()
      :none

  """
  @spec to_maybe(t) :: ExFunky.Maybe.t
  def to_maybe(trial), do: trial |> matches(&ExFunky.Maybe.some/1, (fn _ -> ExFunky.Maybe.none() end))


  @doc """
  Returns the value of a `Trial` or fails with a `:enoent` error.

  ## Examples

      iex> ExFunky.Trial.ok(42) 
      ...> |> ExFunky.Trial.get_value!()
      42

      iex> try do
      ...>    ExFunky.Trial.error() 
      ...>    |> ExFunky.Trial.get_value!()
      ...>    :ok
      ...> catch
      ...>    x -> x
      ...> end
      :enoent

  """
  @spec get_value!(t) :: term | no_return
  def get_value!(trial), do: trial |> matches(&(&1), (fn _ -> throw :enoent end))
  

  @doc """
  Applies a given `binder` function to `x` if the given `Trial` is successful.
  The result is given as such, unlike the `map/2` which wraps the result 
  into a `:ok` value.

  Returns error if `trial` is error.

  ## Examples

      iex> ExFunky.Trial.ok(42) 
      ...> |> ExFunky.Trial.bind(fn x -> ExFunky.Trial.ok(x + 1) end)
      ExFunky.Trial.ok 43

      iex> ExFunky.Trial.ok(42) 
      ...> |> ExFunky.Trial.bind(fn _ -> ExFunky.Trial.error(:error2) end)
      ExFunky.Trial.error :error2

      iex> ExFunky.Trial.error(:error1) 
      ...> |> ExFunky.Trial.bind(fn x -> ExFunky.Trial.ok(x + 1) end)
      ExFunky.Trial.error :error1

      iex> ExFunky.Trial.error(:error1) 
      ...> |> ExFunky.Trial.bind(fn _ -> ExFunky.Trial.error(:error2) end)
      ExFunky.Trial.error :error1

  """
  @spec bind(t, binder) :: t
  def bind(trial, binder), do: trial |> matches(binder, &(errors &1))


  @doc """
  Applies a given `mapper` function to `x` if the given `Trial` is successful. 
  The result is wrapped into a `:ok`, unlike the `bind/2` which return
  the function's result as such.
  
  Returns error if `trial` is error.

  ## Examples

      iex> ExFunky.Trial.ok(42) 
      ...> |> ExFunky.Trial.map(fn x -> x + 1 end)
      ExFunky.Trial.ok 43

      iex> ExFunky.Trial.error(:error1) 
      ...> |> ExFunky.Trial.map(fn x -> x + 1 end)
      ExFunky.Trial.error :error1

  """
  @spec map(t, mapper) :: t
  def map(trial, mapper), do: trial |> matches(&(mapper.(&1) |> ok), &(errors &1))


  # @doc """
  # Returns `true` if the given `Trial` is `{:some, x}` and `predicate.(x)` is `true`.
  
  # Returns `false` if the `Trial` is `:none`.

  # ## Examples

  #     iex> ExFunky.Trial.ok(42) 
  #     ...> |> ExFunky.Trial.exists(fn _ -> true end)
  #     true

  #     iex> ExFunky.Trial.ok(42) 
  #     ...> |> ExFunky.Trial.exists(fn _ -> false end)
  #     false

  #     iex> ExFunky.Trial.none() 
  #     ...> |> ExFunky.Trial.exists(fn _ -> true end)
  #     false

  # """
  # @spec exists(t, predicate) :: boolean
  # def exists(trial, predicate)
  # def exists({:some, x}, predicate) when is_function(predicate, 1), do: predicate.(x)
  # def exists(:none, predicate) when is_function(predicate, 1), do: false


  # @doc """
  # Returns `true` if the given `Trial` is `{:some, x}` and `predicate.(x)` is `true`.
  
  # Returns `false` if the `Trial` is `:none`.

  # ## Examples

  #     iex> ExFunky.Trial.ok(42) 
  #     ...> |> ExFunky.Trial.filter(fn _ -> true end)
  #     {:some, 42}

  #     iex> ExFunky.Trial.ok(42) 
  #     ...> |> ExFunky.Trial.filter(fn _ -> false end)
  #     :none

  #     iex> ExFunky.Trial.none() 
  #     ...> |> ExFunky.Trial.filter(fn _ -> true end)
  #     :none

  # """
  # @spec filter(t, predicate) :: t
  # def filter(trial, predicate)
  # def filter({:some, x} = value, predicate) when is_function(predicate, 1) do
  #   cond do
  #     predicate.(x) -> value
  #     :else -> :none
  #   end
  # end
  # def filter(:none, predicate) when is_function(predicate, 1), do: none()


  # @doc """
  # Returns `folder(acc, x)` if the given `Trial` is `{:some, x}`.
  
  # Returns `acc` if the `Trial` is `:none`.

  # ## Examples

  #     iex> ExFunky.Trial.ok(32) 
  #     ...> |> ExFunky.Trial.fold(fn (a, b) -> a + b end, 10)
  #     42

  #     iex> ExFunky.Trial.none() 
  #     ...> |> ExFunky.Trial.fold(fn (a, b) -> a + b end, 10)
  #     10

  # """
  # @spec fold(t, folder, acc) :: acc
  # def fold(trial, folder, accumulator)
  # def fold({:some, x}, folder, acc) when is_function(folder, 2), do: folder.(acc, x)
  # def fold(:none, folder, acc) when is_function(folder, 2), do: acc


  # @doc """
  # Returns `1` if the given `Trial` is `{:some, x}`.
  
  # Returns `0` if the `Trial` is `:none`.

  # ## Examples

  #     iex> ExFunky.Trial.ok(32) 
  #     ...> |> ExFunky.Trial.count()
  #     1

  #     iex> ExFunky.Trial.none() 
  #     ...> |> ExFunky.Trial.count()
  #     0

  # """
  # @spec count(t) :: 0 | 1
  # def count(trial)
  # def count({:some, _}), do: 1
  # def count(:none), do: 0


  # @doc """
  # Flattens the `Trial` value one level, if needed.

  # ## Examples

  #     iex> ExFunky.Trial.ok(42) 
  #     ...> |> ExFunky.Trial.flatten()
  #     {:some, 42}

  #     iex> ExFunky.Trial.ok(ExFunky.Trial.ok(42))
  #     ...> |> ExFunky.Trial.flatten()
  #     {:some, 42}

  #     iex> ExFunky.Trial.ok(ExFunky.Trial.ok(ExFunky.Trial.ok(42)))
  #     ...> |> ExFunky.Trial.flatten()
  #     {:some, {:some, 42}}

  #     iex> ExFunky.Trial.none() 
  #     ...> |> ExFunky.Trial.flatten()
  #     :none

  # """
  # @spec flatten(t) :: t
  # def flatten(trial)
  # def flatten({:some, {:some, x}}), do: {:some, x}
  # def flatten({:some, x}), do: {:some, x}
  # def flatten(:none), do: :none


  # @doc """
  # Flattens the `Trial` value one level, if needed.

  # ## Examples

  #     iex> ExFunky.Trial.ok(42) 
  #     ...> |> ExFunky.Trial.flatten_all()
  #     {:some, 42}

  #     iex> ExFunky.Trial.ok(ExFunky.Trial.ok(42))
  #     ...> |> ExFunky.Trial.flatten_all()
  #     {:some, 42}

  #     iex> ExFunky.Trial.ok(ExFunky.Trial.ok(ExFunky.Trial.ok(42)))
  #     ...> |> ExFunky.Trial.flatten_all()
  #     {:some, 42}

  #     iex> ExFunky.Trial.none() 
  #     ...> |> ExFunky.Trial.flatten_all()
  #     :none

  # """
  # @spec flatten_all(t) :: t
  # def flatten_all(trial)
  # def flatten_all({:some, {:some, x}}), do: flatten_all({:some, x})
  # def flatten_all({:some, x}), do: {:some, x}
  # def flatten_all(:none), do: :none


  # @doc """
  # Returns `{:some, x}` if the given `list` has any element and `x` is 
  # the first element of the list.

  # Returns `:none` if the `list` is `empty`.

  # ## Examples

  #     iex> [] 
  #     ...> |> ExFunky.Trial.list_first()
  #     :none

  #     iex> [1] 
  #     ...> |> ExFunky.Trial.list_first()
  #     {:some, 1}

  #     iex> [1,2] 
  #     ...> |> ExFunky.Trial.list_first()
  #     {:some, 1}

  # """
  # @spec list_first(list(value)) :: t
  # def list_first(list)
  # def list_first([]), do: :none
  # def list_first([x | _]), do: some x


  # @doc """
  # Returns `{:some, x}` if the given `list` has exactly one element.

  # Returns `:none` if the `list` is `empty` or has more than one element.

  # ## Examples

  #     iex> [] 
  #     ...> |> ExFunky.Trial.list_single()
  #     :none

  #     iex> [1] 
  #     ...> |> ExFunky.Trial.list_single()
  #     {:some, 1}

  #     iex> [1,2] 
  #     ...> |> ExFunky.Trial.list_single()
  #     :none

  # """
  # @spec list_single(list(value)) :: t
  # def list_single(list)
  # def list_single([x]), do: some x
  # def list_single([]), do: :none
  # def list_single([_ | _]), do: :none

end
