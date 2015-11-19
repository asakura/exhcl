defmodule Exhcl do
  @moduledoc """
  ExHCL is configuration language inspired by HCL.
  """
end

defmodule Exhcl.Parser do
  @moduledoc """
  Parses text and traslates to Elixir data structures.
  """

  @doc """
  Parses a string and transform data to Elixir data structures.

  See README.md for more information about syntax.
  """
  @spec parse(binary) :: {:ok, map} | {:error, term}
  def parse(str) do
    {:ok, tokens, _} = str |> to_char_list |> :exhcl_lexer.string

    case tokens do
      [] -> {:ok, %{}}
      _ -> :exhcl_parser.parse(tokens)
    end
  end

  @doc """
  Does as same as `Exhcl.Parse.pasre/1`, but raises an exception in case of fail.
  """
  @spec parse!(binary) :: map
  def parse!(str) do
    case parse(str) do
      {:ok, res} -> res
      {:error, reason} -> raise format_error(reason)
    end
  end

  defp format_error({lineno, _, msg}) do
    "#{msg}, at line #{lineno}"
  end
end
