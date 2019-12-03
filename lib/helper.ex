defmodule Helper do

  def read_file(path) do
    File.stream!(path)
    |> Stream.map(&String.split/1)
  end

end
