defmodule Day11 do

  def from_file(path) do
    File.read!(path)
    |> String.split(",")
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&(elem(&1, 0)))
  end

  def modify(memory, address, value) do
    memory |> Map.put(address, value)
  end

  def read_instruction(value) do
    {params, inst} = Integer.digits(value) |> Enum.split((value |> Integer.digits |> length) - 2)
    {Enum.reverse(params), Integer.undigits(inst)}
  end

  def execute(%{:memory => memory, :pc => pc} = runtime) do
    {modes, inst} = read_instruction(Map.get(memory, pc))
    cond do
      inst == 99 ->
        Map.put(runtime, :done, true)
      inst == 3 && runtime.inputs == [] ->
        Map.put(runtime, :done, false)
      true ->
        case exec_inst(runtime, inst, modes) do
          %{} = runtime -> execute(runtime)
          :error -> runtime
        end
    end
  end

  def value(memory, address, mode, base) do
    cond do
      mode == 0 -> Map.get(memory, Map.get(memory, address, 0), 0)
      mode == 1 -> Map.get(memory, address, 0)
      mode == 2 -> Map.get(memory, base + Map.get(memory, address, 0), 0)
    end
  end

  def write_address(memory, address, mode, base) do
    cond do
      mode == 0 -> Map.get(memory, address, 0)
      mode == 1 -> Map.get(memory, address, 0)
      mode == 2 -> base + Map.get(memory, address, 0)
    end
  end

  def mode(modes, param) do
    case Enum.fetch(modes, param) do
      {:ok, mode} -> mode
      :error -> 0
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 1, modes) do
    x = value(memory, pc + 1, mode(modes, 0), runtime.base)
    y = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    %{runtime | :memory => memory |> modify(address, x + y), :pc => pc + 4}
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 2, modes) do
    x = value(memory, pc + 1, mode(modes, 0), runtime.base)
    y = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    %{runtime | :memory => memory |> modify(address, x * y), :pc => pc + 4}
  end

  def exec_inst(%{:memory => memory, :pc => pc, :inputs => inputs} = runtime, 3, modes) do
    address = write_address(memory, pc + 1, mode(modes, 0), runtime.base)
    [input | rest] = inputs
    %{runtime | :memory => memory |> modify(address, input), :inputs => rest, :pc => pc + 2}
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 4, modes) do
    value = value(memory, pc + 1, mode(modes, 0), runtime.base)
    %{runtime | :memory => memory, :pc => pc + 2, :output => [value | runtime.output]}
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 5, modes) do
    jump_if_true = value(memory, pc + 1, mode(modes, 0), runtime.base)
    jump_to = value(memory, pc + 2, mode(modes, 1), runtime.base)
    if jump_if_true != 0 do
      %{runtime | :pc => jump_to}
    else
      %{runtime | :pc => pc + 3}
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 6, modes) do
    jump_if_false = value(memory, pc + 1, mode(modes, 0), runtime.base)
    jump_to = value(memory, pc + 2, mode(modes, 1), runtime.base)
    if jump_if_false == 0 do
      %{runtime | :pc => jump_to}
    else
      %{runtime | :pc => pc + 3}
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 7, modes) do
    first = value(memory, pc + 1, mode(modes, 0), runtime.base)
    second = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    if first < second do
      %{runtime | :memory => memory |> modify(address, 1), :pc => pc + 4}
    else
      %{runtime | :memory => memory |> modify(address, 0), :pc => pc + 4}
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 8, modes) do
    first = value(memory, pc + 1, mode(modes, 0), runtime.base)
    second = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    if first == second do
      %{runtime | :memory => memory |> modify(address, 1), :pc => pc + 4}
    else
      %{runtime | :memory => memory |> modify(address, 0), :pc => pc + 4}
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 9, modes) do
    new_relative_base = value(memory, pc + 1, mode(modes, 0), runtime.base)
    %{runtime | :pc => pc + 2, :base => runtime.base + new_relative_base}
  end

  def exec_inst(_, _, inst, _) do
    IO.puts("invalid instruction #{inst}")
    :error
  end

  def read_program(program) do
    program |> Enum.with_index |> Map.new(fn {v, k} -> {k, v} end)
  end

  def initial_state(program, inputs), do: %{:memory => read_program(program), :pc => 0, :inputs => inputs, :output => [], :base => 0}

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

  def grid(outputs) do
    outputs
    |> Enum.chunk_every(2)
    |> Enum.reduce(%{}, fn [color, direction_modifier], grid ->
      current = case grid do
        map when map == %{} -> {{0, 0}, 0}
        %{:current => current} -> current
      end
      grid
      |> Map.put(current, color)
      |> Map.put(:current, next_position(current, direction_modifier))
    end)
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
