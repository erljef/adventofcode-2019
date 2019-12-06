defmodule Day6 do

  def from_file(path) do
    Helper.read_file(path)
    |> Enum.to_list
    |> List.flatten
    |> parse_input
  end

  def parse_input(input) do
    input
    |> Enum.map(fn x -> String.split(x, ")") end)
    |> Enum.map(fn [v, k] -> Map.new([{k, v}]) end)
    |> Enum.reduce(%{}, fn m, acc -> Map.merge(m, acc) end)
  end

  def nr_of_orbits(orbits) do
    Enum.reduce(orbits |> Map.keys, 0, fn x, acc -> acc + steps(orbits, x) end)
  end

  def steps(orbits, item) do
    case Map.fetch(orbits, item) do
      {:ok, next} -> 1 + steps(orbits, next)
      :error -> 0
    end
  end

  def create_graph(input) do
    input
    |> Map.to_list
    |> Enum.reduce(Graph.new, fn {from, to}, graph ->
      graph |> Graph.add_edge(from, to) |> Graph.add_edge(to, from)
    end)
  end

  def orbital_transfers(orbits) do
    start = Map.get(orbits, "YOU")
    target = Map.get(orbits, "SAN")

    create_graph(orbits) |> Graph.dijkstra(start, target) |> Enum.filter(&(&1 != target)) |> length
  end

  def solution do
    IO.puts("#{from_file("day6_input.txt") |> nr_of_orbits}")
    IO.puts("#{from_file("day6_input.txt") |> orbital_transfers}")
  end
end
