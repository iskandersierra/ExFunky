defmodule ExFunky.Maybe do

  defmacro some(value) do
    quote do
      { :some, unquote(value) }
    end
  end

  def none do :none end

  def is_maybe({:some, _}), do: true
  def is_maybe(:none), do: true

  def is_some({:some, _}), do: true
  def is_some(:none), do: false

  def is_none({:some, _}), do: false
  def is_none(:none), do: true

  def get({:some, x}), do: {:ok, x}
  def get(:none), do: {:error, :enoent}

  def get!({:some, x}), do: x
  def get!(:none), do: throw :enoent

  def bind({:some, x}, fun), do: fun.(x)
  def bind(:none, _fun), do: :none

  def map({:some, x}, fun), do: fun.(x) |> some
  def map(:none, _fun), do: :none

  def exists({:some, x}, fun), do: fun.(x)
  def exists(:none, _fun), do: false

  def filter({:some, x} = value, fun) when fun.(x), do: value
  def filter({:some, x}, _fun), do: :none
  def filter(:none, _fun), do: :none

  def fold({:some, x}, fun, acc), do: fun.(acc, x)
  def fold(:none, _fun, acc), do: acc

  def count({:some, x}, fun), do: 1
  def count(:none), do: 0

  def list_first([x | _]), do: some x
  def list_first(list) when is_list(list), do: none

  def list_single([x]), do: some x
  def list_single(list) when is_list(list), do: none

end