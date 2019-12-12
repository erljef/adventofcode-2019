defmodule Helper do

  def read_file(path) do
    File.stream!(path)
    |> Stream.map(&String.split/1)
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))
end
