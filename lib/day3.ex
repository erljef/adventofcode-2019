defmodule Day3 do

  def from_file(path) do
    File.read!(path)
  end

  def parse_file(input) do
    input
    |> String.split
    |> Enum.map(fn line -> String.split(line, ",") end)
    |> Enum.map(fn line -> Enum.map(line, &vector/1) end)
  end

  def vector(str) do
    {
      String.at(str, 0),
      Integer.parse(String.slice(str, 1, String.length(str)))
      |> (&(elem(&1, 0))).()
    }
  end

  def distance(lines) do
    lines
    |> Enum.map(&draw/1)
    |> Enum.map(&Map.keys/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> Enum.map(&manhattan/1)
    |> Enum.min
  end

  def draw(line) do
    {drawn, _, _} = line |> Enum.reduce({%{}, {0, 0}, 0}, fn vector, agg -> move(vector, agg) end)
    drawn
  end

  def move(vector, {visited, current_pos, total_distance}) do
    distance = elem(vector, 1)
    new_visited = Enum.reduce(1..distance, visited, fn d, agg -> Map.put_new(agg, next({elem(vector, 0), d}, current_pos), total_distance + d) end)
    {new_visited, next(vector, current_pos), total_distance + distance}
  end

  def next({direction, distance}, {x, y}) do
    case direction do
      "U" -> {x, y + distance}
      "D" -> {x, y - distance}
      "L" -> {x - distance, y}
      "R" -> {x + distance, y}
    end
  end

  def manhattan({x, y}), do: abs(x) + abs(y)

  def lowest_total_distance(lines) do
    lines
    |> Enum.map(&draw/1)
    |> Enum.reduce(&intersection/2)
    |> Enum.min
  end

  def intersection(a, b) do
    positions_a = Map.keys(a) |> MapSet.new()
    positions_b = Map.keys(b) |> MapSet.new()
    distance_a = &(Map.get(a, &1))
    distance_b = &(Map.get(b, &1))
    MapSet.intersection(positions_a, positions_b) |> Enum.map(&(distance_a.(&1) + distance_b.(&1)))
  end

  def solution do
    IO.puts("#{from_file("day3_input.txt") |> parse_file |> distance }")
    IO.puts("#{from_file("day3_input.txt") |> parse_file |> lowest_total_distance }")
  end
end
