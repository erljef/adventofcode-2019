defmodule Day8 do

  def from_file(path) do
    File.read!(path)
    |> String.graphemes
    |> Enum.filter(&(&1 != "\n"))
    |> Enum.map(&String.to_integer/1)
  end

  def create_image(input, width, height) do
    input |> Enum.chunk_every(width) |> Enum.chunk_every(height)
  end

  def layer_with_fewest(image, digit) do
    image
      |> Enum.map(fn layer -> Enum.concat(layer) end)
      |> Enum.map(fn layer -> {layer, count(layer, digit)} end)
      |> Enum.min_by(fn {_, digits} -> digits end)
      |> elem(0)
  end

  def count(layer, digit) do
    Enum.filter(layer, &(&1 == digit)) |> length
  end

  def checksum(layer, {first, second}) do
    (layer |> count(first)) * (layer |> count(second))
  end

  def decode(image) do
    image
    |> Enum.reduce([], fn layer, image -> merge(image, layer) end)
  end

  def merge([], layer), do: layer
  def merge(image, layer) do
    width = List.first(image) |> length
    ci = image |> Enum.concat
    cl = layer |> Enum.concat
    Enum.zip(ci, cl)
    |> Enum.map(fn {i, l} -> merge_pixel(i, l) end)
    |> Enum.chunk_every(width)
  end

  def merge_pixel(top, bottom) do
    if top == 2 do
      bottom
    else
      top
    end
  end

  def print(image) when is_list(image) do
    image
    |> Enum.each(fn row ->
      Enum.each(row, &print/1)
      IO.write("\n")
    end)
  end
  def print(pixel) when is_integer(pixel) do
    if pixel == 1 do
      IO.write("0")
    else
      IO.write(" ")
    end
  end

  def solution do
    IO.puts("#{from_file("day8_input.txt") |> create_image(25, 6) |> layer_with_fewest(0) |> checksum({1, 2})}")
    IO.puts("#{from_file("day8_input.txt") |> create_image(25, 6) |> decode |> print}")
  end
end
