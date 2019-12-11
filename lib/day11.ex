defmodule Day11 do
  import Intcode

  def from_file(path) do
    File.read!(path)
    |> String.split(",")
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&(elem(&1, 0)))
  end

  def robot(program, initial_color) do
    robot_execute(execute(initial_state(program, [initial_color])), {{0, 0}, 0}, [])
  end

  def robot_execute(state, next \\ nil, painted \\ []) do
    [color, direction_mod] = state.output |> Enum.reverse
    {paint_position, _} = current = case next do
      nil -> {{0, 0}, 0}
      x -> x
    end

    {new_color_pos, _} = new_next = next_position(current, direction_mod)
    {_, current_color} = painted |> Enum.find({{0, 0}, 0}, fn {pos, _} -> pos == new_color_pos end)

    if Map.get(state, :done, false) do
      [{paint_position, color} | painted] |> Enum.reverse
    else
      robot_execute(execute(%{state | :inputs => [current_color], :output => []}), new_next, [{paint_position, color} | painted])
    end
  end

  def next_position({{x, y}, direction}, direction_modifier) do
    new_direction = direction(direction, direction_modifier)

    cond do
      new_direction == 0 -> {{x, y - 1}, new_direction}
      new_direction == 1 -> {{x + 1, y}, new_direction}
      new_direction == 2 -> {{x, y + 1}, new_direction}
      new_direction == 3 -> {{x - 1, y}, new_direction}
    end
  end

  def direction(direction, modifier) do
    if modifier == 0 do
      rem(direction + 4 - 1, 4)
    else
      rem(direction + 1, 4)
    end
  end

  def print(painted) do
    y_boundary = painted |> Map.keys |> Enum.group_by(fn {_, y} -> y end) |> Map.keys
    y_range = (y_boundary |> Enum.min) .. (y_boundary |> Enum.max)
    x_boundary = painted |> Map.keys |> Enum.group_by(fn {x, _} -> x end) |> Map.keys
    x_range = (x_boundary |> Enum.min) .. (x_boundary |> Enum.max)

    Enum.each(y_range, fn y ->
      Enum.each(x_range, fn x ->
        color = Map.get(painted, {x, y}, 0)
        cond do
          color == 1 -> IO.write("#")
          color == 0 -> IO.write(".")
        end
      end)
      IO.puts("")
    end)
  end

  def solution do
    IO.puts("#{from_file("day11_input.txt") |> robot(0) |> Enum.uniq_by(fn {pos, _} -> pos end) |> length}")
    IO.puts("#{from_file("day11_input.txt") |> robot(1) |> Map.new |> print}")
  end
end
