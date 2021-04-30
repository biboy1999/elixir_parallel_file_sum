defmodule MtSum do
  @moduledoc """
  Documentation for `MtSum`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> MtSum.hello()
      :world

  """

  def parse_file(filepath) do
    File.read!(filepath)
    |> String.replace(~r/\r|\n/, " ")
    |> String.split()
    |> Task.async_stream(&String.to_integer/1)
    |> Stream.map(fn ({:ok, result}) -> result end)
    |> Enum.to_list()
  end

  def sum(elements) when is_list(elements) and length(elements) > 1 do
    Enum.chunk_every(elements,2)
    |> Task.async_stream(&adder/1)
    |> Stream.map(fn ({:ok, result}) -> result end)
    |> Enum.to_list()
    |> sum()
  end

  def sum([element | []]) do
    element
  end

  def adder([a | [b | []]]) when is_integer(a) and is_integer(b) do
    a + b
  end

  def adder([a | []]) when is_integer(a) do
    a
  end

  def worker(filename) do
    parse_file(filename)
    |> sum()

  end

  def start do
    Path.wildcard("../*.txt")
    |> Task.async_stream(&worker/1)
    |> Enum.to_list()
    |> IO.inspect()
  end


end
