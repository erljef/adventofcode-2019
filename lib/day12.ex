defmodule Day12 do

  def from_file(path) do
    File.stream!(path)
    |> Enum.to_list
    |> Enum.map(&parse_row/1)
  end

  def parse_row(row) do
    [x, y, z] = Regex.run(~r{<x=(.*), y=(.*), z=(.*)>}, row, capture: :all_but_first)
    {String.to_integer(x), String.to_integer(y), String.to_integer(z)}
  end

  def initial_velocity(moons) do
    Enum.map(moons, fn moon -> {moon, {0, 0, 0}} end)
  end

  def apply_gravity(moons) do
    moons
    |> Enum.reduce([], fn {{x1, y1, z1}, velocity}, updated ->
      new_velocity =
        Enum.reduce(moons, velocity, fn {{x2, y2, z2}, _}, v_acc ->
        if {x1, y1, z1} == {x2, y2, z2} do
          v_acc
        else
          {vx, vy, vz} = v_acc
          {vx + gravity(x1, x2), vy + gravity(y1, y2), vz + gravity(z1, z2)}
        end
      end)
      [{{x1, y1, z1}, new_velocity} | updated]
    end)
    |> Enum.reverse
  end

  def gravity(a, b) do
    cond do
      a == b -> 0
      a > b -> -1
      a < b -> 1
    end
  end

  def move(moons) do
    moons
    |> Enum.map(fn {{x, y, z}, {vx, vy, vz}} -> {{x + vx, y + vy, z + vz}, {vx, vy, vz}} end)
  end

  def steps(moons, amount) when amount > 0 do
    Enum.reduce(1..amount, moons, fn _, updated -> step(updated) end)
  end

  def step(moons) do
    moons |> apply_gravity |> move
  end

  def energy(moons) do
    moons
    |> Enum.reduce(0, fn {{x, y, z}, {vx, vy, vz}}, acc ->
           acc + ((abs(x) + abs(y) + abs(z)) * (abs(vx) + abs(vy) + abs(vz)))
    end)
  end

  def cycle(moons) do
    Enum.map(0..2, fn ix -> cycle(moons, ix) end)
    |> Enum.reduce(fn a, b -> Helper.lcm(a, b) end)
  end

  def cycle(moons, index) when index >= 0 and index <= 2 do
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({moons, MapSet.new, 0}, fn step, {moons, acc, _} ->
      positions = Enum.map(moons, fn {pos, vel} -> {elem(pos, index), elem(vel, index)} end)
      new_state = step(moons)
      cond do
        !MapSet.member?(acc, positions) ->
          {:cont, {new_state, MapSet.put(acc, positions), step}}
        MapSet.member?(acc, positions) ->
          {:halt, {moons, acc, step}}
      end
    end)
    |> elem(2)
  end

  def solution do
    IO.puts("#{from_file("day12_input.txt") |> initial_velocity |> steps(1000) |> energy}")
    IO.puts("#{from_file("day12_input.txt") |> initial_velocity |> cycle}")
  end
end
