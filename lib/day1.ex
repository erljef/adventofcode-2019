defmodule Day1 do

  def from_file(path) do
    Helper.read_file(path)
    |> Enum.to_list
    |> List.flatten
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&(elem(&1, 0)))
  end

  def fuel_sum(modules) do
    Enum.reduce(modules, 0, fn m, acc -> acc + fuel(m) end)
  end

  def fuel(mass) do
    div(mass, 3) - 2
  end

  def fuel_rec(mass) do
    if mass <= 0 do
      0
    else
      mass + fuel_rec(fuel(mass))
    end
  end

  def fuel_rec_sum(modules) do
    Enum.reduce(modules, 0, fn m, acc -> acc + fuel_rec(fuel(m)) end)
  end

  def solution do
    IO.puts("#{from_file("day1_input.txt") |> fuel_sum}")
    IO.puts("#{from_file("day1_input.txt") |> fuel_rec_sum}")
  end
end
