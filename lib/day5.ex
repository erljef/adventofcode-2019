defmodule Day5 do

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

  def exec_inst(%{:memory => memory, :pc => pc, :input => input} = runtime, 3, _) do
    address = Enum.at(memory, pc + 1)
    %{runtime | :memory => memory |> modify(address, input), :pc => pc + 2}
  end

  def exec_inst(%{:memory => memory, :pc => pc} = runtime, 4, _) do
    address = Enum.at(memory, pc + 1)
    output = Enum.at(memory, address)
    %{runtime | :memory => memory, :pc => pc + 2, :output => output}
  end

  def exec_inst(_, _, inst, _) do
    IO.puts("invalid instruction #{inst}")
    :error
  end

  def run(program, input) do
    execute(%{:memory => program, :pc => 0, :input => input, :output => nil})
  end

  def solution do
    IO.puts("#{from_file("day5_input.txt") |> run(1) |> Map.get(:output) }")
    #IO.puts("#{from_file("day5_input.txt") }")
  end
end
