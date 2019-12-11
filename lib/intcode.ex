defmodule Intcode do
  defp modify(memory, address, value) do
    memory |> Map.put(address, value)
  end

  defp read_instruction(value) do
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

  defp value(memory, address, mode, base) do
    cond do
      mode == 0 -> Map.get(memory, Map.get(memory, address, 0), 0)
      mode == 1 -> Map.get(memory, address, 0)
      mode == 2 -> Map.get(memory, base + Map.get(memory, address, 0), 0)
    end
  end

  defp write_address(memory, address, mode, base) do
    cond do
      mode == 0 -> Map.get(memory, address, 0)
      mode == 1 -> Map.get(memory, address, 0)
      mode == 2 -> base + Map.get(memory, address, 0)
    end
  end

  defp mode(modes, param) do
    case Enum.fetch(modes, param) do
      {:ok, mode} -> mode
      :error -> 0
    end
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 1, modes) do
    x = value(memory, pc + 1, mode(modes, 0), runtime.base)
    y = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    %{runtime | :memory => memory |> modify(address, x + y), :pc => pc + 4}
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 2, modes) do
    x = value(memory, pc + 1, mode(modes, 0), runtime.base)
    y = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    %{runtime | :memory => memory |> modify(address, x * y), :pc => pc + 4}
  end

  defp exec_inst(%{:memory => memory, :pc => pc, :inputs => inputs} = runtime, 3, modes) do
    address = write_address(memory, pc + 1, mode(modes, 0), runtime.base)
    [input | rest] = inputs
    %{runtime | :memory => memory |> modify(address, input), :inputs => rest, :pc => pc + 2}
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 4, modes) do
    value = value(memory, pc + 1, mode(modes, 0), runtime.base)
    %{runtime | :memory => memory, :pc => pc + 2, :output => [value | runtime.output]}
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 5, modes) do
    jump_if_true = value(memory, pc + 1, mode(modes, 0), runtime.base)
    jump_to = value(memory, pc + 2, mode(modes, 1), runtime.base)
    if jump_if_true != 0 do
      %{runtime | :pc => jump_to}
    else
      %{runtime | :pc => pc + 3}
    end
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 6, modes) do
    jump_if_false = value(memory, pc + 1, mode(modes, 0), runtime.base)
    jump_to = value(memory, pc + 2, mode(modes, 1), runtime.base)
    if jump_if_false == 0 do
      %{runtime | :pc => jump_to}
    else
      %{runtime | :pc => pc + 3}
    end
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 7, modes) do
    first = value(memory, pc + 1, mode(modes, 0), runtime.base)
    second = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    if first < second do
      %{runtime | :memory => memory |> modify(address, 1), :pc => pc + 4}
    else
      %{runtime | :memory => memory |> modify(address, 0), :pc => pc + 4}
    end
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 8, modes) do
    first = value(memory, pc + 1, mode(modes, 0), runtime.base)
    second = value(memory, pc + 2, mode(modes, 1), runtime.base)
    address = write_address(memory, pc + 3, mode(modes, 2), runtime.base)
    if first == second do
      %{runtime | :memory => memory |> modify(address, 1), :pc => pc + 4}
    else
      %{runtime | :memory => memory |> modify(address, 0), :pc => pc + 4}
    end
  end

  defp exec_inst(%{:memory => memory, :pc => pc} = runtime, 9, modes) do
    new_relative_base = value(memory, pc + 1, mode(modes, 0), runtime.base)
    %{runtime | :pc => pc + 2, :base => runtime.base + new_relative_base}
  end

  defp exec_inst(_, inst, _) do
    IO.puts("invalid instruction #{inst}")
    :error
  end

  defp read_program(program) do
    program |> Enum.with_index |> Map.new(fn {v, k} -> {k, v} end)
  end

  def initial_state(program, inputs), do: %{:memory => read_program(program), :pc => 0, :inputs => inputs, :output => [], :base => 0}
end
