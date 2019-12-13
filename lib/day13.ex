defmodule Day13 do

  def from_file(path) do
    File.read!(path)
    |> String.split(",")
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&(elem(&1, 0)))
  end

  def game(program) do
    game_execute(Intcode.execute(Intcode.initial_state(program, [])))
  end

  def game_with_freeplay(program) do
    game_execute(Intcode.execute(Intcode.initial_state(program, []) |> set_freeplay))
  end

  def set_freeplay(state), do: %{state | :memory => Map.put(state.memory, 0, 2)}

  def game_execute(state, board \\ %{}) do
    output = state.output
    |> Enum.reverse
    |> Enum.chunk_every(3)

    new_board = update(board, output)
    input = determine_input(new_board)

    if Map.get(state, :done, false) do
      new_board
    else
      game_execute(Intcode.execute(%{state | :inputs => input, :output => []}), new_board)
    end
  end

  def determine_input(board) do
    {px, _} = board |> find(3)
    {bx, _} = board |> find(4)
    cond do
      px == bx -> [0]
      px > bx -> [-1]
      px < bx -> [1]
    end
  end

  def find(board, tile) do
    board
    |> Map.to_list
    |> Enum.find(fn {{x, _}, type} -> type == tile && x >= 0 end)
    |> elem(0)
  end

  def update(%{} = board, []), do: board
  def update(%{} = board, [head | _] = updates) when is_list(head) do
    updates
    |> Enum.reduce(board, fn tile, board ->
      update(board, tile)
    end)
  end

  def update(%{} = board, [x, y, tile_id]) do
    board |> Map.put({x, y}, tile_id)
  end

  def blocks(board) do
    board |> Map.values |> Enum.reduce(0, fn tile_id, blocks -> if tile_id == 2, do: blocks + 1, else: blocks  end)
  end

  def score(board), do: board |> Map.get({-1, 0}, 0)

  def print(board) when map_size(board) == 0, do: nil
  def print(board) do
    y_boundary = board |> Map.keys |> Enum.group_by(fn {_, y} -> y end) |> Map.keys
    y_range = (y_boundary |> Enum.min) .. (y_boundary |> Enum.max)
    x_boundary = board |> Map.keys |> Enum.group_by(fn {x, _} -> x end) |> Map.keys
    x_range = (x_boundary |> Enum.min) .. (x_boundary |> Enum.max)

    Enum.each(y_range, fn y ->
      Enum.each(x_range, fn x ->
        type = Map.get(board, {x, y}, 0)
        cond do
          {x, y} == {-1, 0} -> IO.write(type)
          type == 0 -> IO.write(" ")
          type == 1 -> IO.write("#")
          type == 2 -> IO.write("*")
          type == 3 -> IO.write("_")
          type == 4 -> IO.write(".")
        end
      end)
      IO.puts("")
    end)
  end

  def solution do
    IO.puts("#{inspect from_file("day13_input.txt") |> game |> blocks}")
    IO.puts("#{inspect from_file("day13_input.txt") |> game_with_freeplay |> score}")
  end
end
