defmodule ExFunky.Prelude do
  @doc """
  Identity function

  ## Examples

      iex> ExFunky.Prelude.id "Hello World!"
      "Hello World!"

  """
  def id(a), do: a

  @doc """
  Constant function of arity 1

  ## Examples

      iex> k = ExFunky.Prelude.konst "Hello World!"
      iex> k.(42)
      "Hello World!"

  """
  defmacro konst(a) do
    quote do
      (fn (_) -> unquote(a) end)
    end
  end

  @doc """
    Constant function of arity 2

  ## Examples

      iex> k = ExFunky.Prelude.konst2 "Hello World!"
      iex> k.(42, ?a)
      "Hello World!"

  """
  defmacro konst2(a) do
    quote do
      (fn (_, _) -> unquote(a) end)
    end
  end

end