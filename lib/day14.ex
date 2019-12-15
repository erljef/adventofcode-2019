defmodule Day14 do

  def from_file(path) do
    File.stream!(path)
    |> Enum.to_list
    |> Enum.map(&parse_row/1)
  end

  def parse_material([amount, type]), do: {String.to_integer(amount), String.to_atom(type)}

  def parse_row(row) do
    [from, to] = Regex.run(~r{(.*) => (.*)}, row, capture: :all_but_first)

    {
      from |> String.split(", ") |> Enum.map(&String.split/1) |> Enum.map(&parse_material/1),
      to |> String.split |> parse_material
    }
  end

  def reaction(reactions, to_material) do
    Enum.find(reactions, fn {_, {_, material}} -> material == to_material end)
  end

  def simplify(reactions, {amount, material}) do
    if amount <= 0 do
      []
    else
      {from, {to_amount, _}} = reaction(reactions, material)
      multiplier =
        if amount <= to_amount do
          1
        else
          m = div(amount, to_amount)
          if m * to_amount >= amount, do: m, else: m + 1
        end
      produced = to_amount * multiplier
      rest = produced - amount
      if rest > 0 do
        Enum.map(from, fn {a, m} -> {a * multiplier, m} end) ++ [{-rest, material}]
      else
        Enum.map(from, fn {a, m} -> {a * multiplier, m} end)
      end
    end
  end

  def simplify(reactions, simplified) when is_list(simplified) do
    added = add(simplified)
    case added do
      [] -> 0
      [{a, :ORE} | rest] -> a + simplify(reactions, rest)
      [m | rest] -> simplify(reactions, simplify(reactions, m) ++ rest |> List.flatten)
    end
  end

  def add(list) do
    list
    |> Enum.reduce(%{}, fn {a, m}, acc -> acc |> Map.put(m, a + Map.get(acc, m, 0)) end)
    |> Map.to_list
    |> Enum.map(fn {m, a} -> {a, m} end)
    |> Enum.sort_by(fn {a, _} -> a end, &>=/2)
  end

  def max_fuel(reactions, ore) do
    ore_per_fuel = simplify(reactions, [{1, :FUEL}])
    min = div(ore, ore_per_fuel)
    max = min * 2
    {min_s, max_s} =
      Stream.iterate(
        {min, max},
        fn {min, max} ->
          produced = min + div(max - min, 2)
          used = simplify(reactions, [{produced, :FUEL}])
          if used > ore do
            {min, produced}
          else
            {produced, max}
          end
        end
      )
      |> Enum.take_while(fn {min, max} -> max > (min + 1) end)
      |> List.last

    Enum.map(min_s..max_s, fn produced -> {produced, simplify(reactions, [{produced, :FUEL}])} end)
    |> Enum.filter(fn {_, used} -> used < ore end)
    |> List.last
    |> elem(0)
  end

  def solution do
    IO.puts("#{from_file("day14_input.txt") |> simplify([{1, :FUEL}])}")
    IO.puts("#{from_file("day14_input.txt") |> max_fuel(1000000000000)}")
  end
end
