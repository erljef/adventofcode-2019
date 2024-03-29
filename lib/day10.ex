defmodule Day10 do

  def from_file(path) do
    Helper.read_file(path)
    |> Enum.to_list
    |> List.flatten
  end

  def new_map(input) do
    input
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index
    |> Enum.map(fn {row, ix} -> row |> to_coordinates(ix) end)
    |> List.flatten
  end

  def to_coordinates(row, y) do
    row |> Enum.with_index |> Enum.flat_map(fn {col, x} ->
      if col == "#" do
        [{x, y}]
      else
        []
      end
    end)
  end

  def distance_and_angle(map) do
    for origin <- map,
        target <- map,
        origin != target do
      {origin, target, distance(origin, target)}
    end
    |> Enum.sort_by(fn {_, _, {distance, _}} -> distance end)
    |> Enum.group_by(fn {origin, _, _} -> origin end)
  end

  def most_visible(map) do
    distance_and_angle(map)
    |> Map.to_list
    |> Enum.map(fn {origin, targets} -> {origin, visible(targets)} end)
    |> Enum.map(fn {origin, targets} -> {origin, length(targets)} end)
    |> Enum.max_by(fn {_, nr_visible} -> nr_visible end)
  end

  def visible(targets) do
    targets
    |> Enum.filter(fn {_, _, da} -> visible(targets, da) end)
  end

  def visible(targets, {distance, angle}) do
    !Enum.any?(targets, fn {_, _, {d2, a2}} -> d2 < distance && a2 == angle end)
  end

  def distance(origin, target) do
    {manhattan(origin, target), angle(origin, target)}
  end

  def angle({x1, y1}, {x2, y2}) do
    angle = :math.atan2(y2 - y1, x2 - x1) * (180 / :math.pi()) + 90
    if angle < 0 do
      angle + 360
    else
      angle
    end
  end

  def manhattan({x1, y1}, {x2, y2}), do: Kernel.abs(x1 - x2) + Kernel.abs(y1 - y2)

  def vaporize(map, amount) do
    {origin, _} = most_visible(map)
    targets = distance_and_angle(map)
    |> Map.get(origin)
    |> Enum.map(fn {_, target, da} -> {target, da} end)
    |> Enum.group_by(fn {_, {_, a}} -> a end)
    |> Map.to_list
    |> Enum.sort_by(fn {angle, _} -> angle end)
    |> Enum.map(fn {_, by_angle} -> Enum.map(by_angle, fn {target, _} -> target end) end)

    targets
    |> Enum.with_index
    |> Enum.map(fn {sub, ix} ->
        Enum.with_index(sub)
        |> Enum.map(fn {target, sub_ix} -> {target, ix + sub_ix * length(targets)} end)
    end)
    |> List.flatten
    |> Enum.sort_by(fn {_, ix} -> ix end)
    |> Enum.fetch!(amount - 1)
    |> elem(0)
  end

  def solution do
    IO.puts("#{inspect from_file("day10_input.txt") |> new_map |> most_visible}")
    IO.puts("#{inspect from_file("day10_input.txt") |> new_map |> vaporize(200)}")
  end
end
