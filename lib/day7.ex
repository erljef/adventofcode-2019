defmodule Day7 do

  def from_file(path) do
    File.read!(path)
    |> String.split(",")
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&(elem(&1, 0)))
  end

  def modify(memory, address, value) do
    memory
    |> List.delete_at(address)
    |> List.insert_at(address, value)
  end

  def read_instruction(value) do
    {params, inst} = Integer.digits(value) |> Enum.split((value |> Integer.digits |> length) - 2)
    {Enum.reverse(params), Integer.undigits(inst)}
  end

  def execute(%{:memory => memory, :pc => pc} = runtime) do
    {modes, inst} = read_instruction(Enum.at(memory, pc))
    if inst == 99 do
      runtime
    else
      case exec_inst(runtime, inst, modes) do
        %{} = runtime -> execute(runtime)
        :error -> runtime
      end
    end
  end

  def value(memory, address, mode) do
    if mode == 0 do
      Enum.at(memory, Enum.at(memory, address))
    else
      Enum.at(memory, address)
    end
  end

  def mode(modes, param) do
    case Enum.fetch(modes, param) do
      {:ok, mode} -> mode
      :error -> 0
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 1, modes) do
    x = value(memory, pc + 1, mode(modes, 0))
    y = value(memory, pc + 2, mode(modes, 1))
    address = Enum.at(memory, pc + 3)
    %{runtime | :memory => memory |> modify(address, x + y), :pc => pc + 4}
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 2, modes) do
    x = value(memory, pc + 1, mode(modes, 0))
    y = value(memory, pc + 2, mode(modes, 1))
    address = Enum.at(memory, pc + 3)
    %{runtime | :memory => memory |> modify(address, x * y), :pc => pc + 4}
  end

  def exec_inst(%{:memory => memory, :pc => pc, :inputs => inputs} = runtime, 3, _) do
    address = Enum.at(memory, pc + 1)
    [input | rest] = inputs
    %{runtime | :memory => memory |> modify(address, input), :inputs => rest, :pc => pc + 2}
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 4, _) do
    address = Enum.at(memory, pc + 1)
    %{runtime | :memory => memory, :pc => pc + 2, :output => Enum.at(memory, address)}
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 5, modes) do
    jump_if_true = value(memory, pc + 1, mode(modes, 0))
    jump_to = value(memory, pc + 2, mode(modes, 1))
    if jump_if_true != 0 do
      %{runtime | :pc => jump_to}
    else
      %{runtime | :pc => pc + 3}
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 6, modes) do
    jump_if_false = value(memory, pc + 1, mode(modes, 0))
    jump_to = value(memory, pc + 2, mode(modes, 1))
    if jump_if_false == 0 do
      %{runtime | :pc => jump_to}
    else
      %{runtime | :pc => pc + 3}
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 7, modes) do
    first = value(memory, pc + 1, mode(modes, 0))
    second = value(memory, pc + 2, mode(modes, 1))
    address = Enum.at(memory, pc + 3)
    if first < second do
      %{runtime | :memory => memory |> modify(address, 1), :pc => pc + 4}
    else
      %{runtime | :memory => memory |> modify(address, 0), :pc => pc + 4}
    end
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 8, modes) do
    first = value(memory, pc + 1, mode(modes, 0))
    second = value(memory, pc + 2, mode(modes, 1))
    address = Enum.at(memory, pc + 3)
    if first == second do
      %{runtime | :memory => memory |> modify(address, 1), :pc => pc + 4}
    else
      %{runtime | :memory => memory |> modify(address, 0), :pc => pc + 4}
    end
  end

  def exec_inst(_, _, inst, _) do
    IO.puts("invalid instruction #{inst}")
    :error
  end

  def run(program, inputs) do
    execute(%{:memory => program, :pc => 0, :inputs => inputs, :output => nil})
  end

  def thruster_signal(program, inputs) do
    Enum.scan(inputs, {0, []}, fn input, {prev, _} ->
      %{:output => output} = run(program, [input, prev])
      {output, inputs}
    end)
    |> List.last
  end

  def max_thruster_signal(program) do
    permutations(0..4 |> Enum.to_list)
    |> Enum.map(&(thruster_signal(program, &1)))
    |> Enum.max_by(fn {signal, _} -> signal end)
  end

  def permutations([]), do: [[]]
  def permutations(list), do: for elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest]

  def solution do
    IO.puts("#{from_file("day7_input.txt") |> max_thruster_signal |> inspect}")
  end
end
