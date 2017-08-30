defmodule ExFunky.Maybe do

  defmacro some(value) do
    quote do
      { :some, unquote(value) }
    end
  end

  def none do :none end

  defmacro either(value, clauses) do
    build_either(value, clauses)
  end

  defp build_ do
    
  end

end