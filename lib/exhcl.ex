defmodule Exhcl do
  defmodule Parser do
    def parse do
      {:ok, %{}}
    end

    @spec parse(binary) :: list
    def parse(str) do
      {:ok, tokens, _} = str |> to_char_list |> :exhcl_lexer.string

      case tokens do
        [] -> {:ok, %{}}
        _ -> :exhcl_parser.parse(tokens)
      end
    end
  end
end
