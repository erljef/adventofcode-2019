defmodule Day4 do

  def generate_passwords(input, validation) do
    {lower, upper} = input |> String.split("-") |> Enum.map(&String.to_integer/1) |> List.to_tuple
    Enum.reduce(lower..upper, [], fn password, valid ->
      if validation.(password) do
          [password | valid]
        else
          valid
        end
      end
    )
  end

  def valid?(password), do: digits?(password) && adjacent?(password) && increasing?(password)
  def valid_part2?(password), do: valid?(password) && adjacent_with_size?(password)

  def digits?(password), do: Integer.digits(password) |> length == 6

  def adjacent?(password) do
    length = Integer.digits(password) |> length
    dedup_length = Integer.digits(password) |> Enum.dedup |> length
    length != dedup_length
  end

  def adjacent_with_size?(password) do
    Integer.digits(password) |> Enum.group_by(&(&1)) |> Map.values |> Enum.filter(&(length(&1) == 2)) |> length > 0
  end

  def increasing?(password) do
    Integer.digits(password) == Integer.digits(password) |> Enum.sort
  end

  def solution do
    IO.puts("#{generate_passwords("136760-595730", &valid?/1) |> length }")
    IO.puts("#{generate_passwords("136760-595730", &valid_part2?/1) |> length }")
  end
end
