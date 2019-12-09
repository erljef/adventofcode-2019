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

  def feedback_thruster_signal(program, inputs) do
    signal = Stream.cycle([inputs])
              |> Enum.reduce_while(%{}, fn sequence, program_states ->
                states = Enum.reduce(sequence, program_states, fn input, program_states ->
                  program_state = Map.get(program_states, input, %{:memory => program, :pc => 0, :inputs => [], :output => 0})
                  prev_output = Map.get(program_states, :output, 0)
                  next_inputs = if Map.has_key?(program_states, input) do [prev_output] else [input, prev_output] end

                  new_state = execute(%{program_state | :inputs => next_inputs})
                  program_states |> Map.put(input, new_state) |> Map.put(:output, new_state.output)
                end)

                is_done = states |> Map.split(inputs) |> elem(0) |> Map.values |> Enum.map(fn %{:done => done} -> done end) |> Enum.any?
                if is_done do
                  {:halt, states}
                else
                  {:cont, states}
                end
              end)
              |> Map.get(:output)
    {signal, inputs}
  end

  def max_feedback_thruster_signal(program) do
    permutations(5..9 |> Enum.to_list)
    |> Enum.map(&(feedback_thruster_signal(program, &1)))
    |> Enum.max_by(fn {signal, _} -> signal end)
  end

  def solution do
    IO.puts("#{from_file("day7_input.txt") |> max_thruster_signal |> inspect}")
    IO.puts("#{from_file("day7_input.txt") |> max_feedback_thruster_signal |> inspect}")
  end
end
