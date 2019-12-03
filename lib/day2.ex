defmodule Day2 do

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

  def execute({memory, pc}) do
    inst = Enum.at(memory, pc)

    if inst == 99 do
      memory
    else
      execute(exec_inst(memory, pc, inst))
    end
  end

  def exec_inst(memory, pc, 1) do
    x = Enum.at(memory, pc + 1)
    y = Enum.at(memory, pc + 2)
    address = Enum.at(memory, pc + 3)
    res = Enum.at(memory, x) + Enum.at(memory, y)
    {memory |> modify(address, res), pc + 4}
  end

  def exec_inst(memory, pc, 2) do
    x = Enum.at(memory, pc + 1)
    y = Enum.at(memory, pc + 2)
    address = Enum.at(memory, pc + 3)
    res = Enum.at(memory, x) * Enum.at(memory, y)
    {memory |> modify(address, res), pc + 4}
  end

  def run(program, noun, verb) do
    modified = program |> modify(1, noun) |> modify(2, verb)
    execute({modified, 0}) |> Enum.at(0)
  end

  def find_input(program, output) do
    for noun <- 0..99,
      verb <- 0..99 do
        if run(program, noun, verb) == output do
          {noun, verb}
        end
      end
    |> Enum.filter(&(&1 != nil))
    |> Enum.at(0)
  end

  def solution do
    IO.puts("#{from_file("day2_input.txt") |> run(12, 2) }")
    IO.puts("#{from_file("day2_input.txt") |> find_input(19690720) |> (fn {noun, verb} -> 100 * noun + verb end).()}")
  end
end
