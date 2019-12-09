defmodule Adventofcode2019Test do
  use ExUnit.Case

  test "solves day 1 part 1" do
    assert Day1.fuel_sum([12]) == 2
    assert Day1.fuel_sum([14]) == 2
    assert Day1.fuel_sum([1969]) == 654
    assert Day1.fuel_sum([100756]) == 33583
  end

  test "solves day 1 part 2" do
    assert Day1.fuel_rec_sum([14]) == 2
    assert Day1.fuel_rec_sum([1969]) == 966
    assert Day1.fuel_rec_sum([100756]) == 50346
  end

  test "solves day 2 part 1" do
    assert Day2.execute({[1, 1, 1, 4, 99, 5, 6, 0, 99], 0}) == [30, 1, 1, 4, 2, 5, 6, 0, 99]
  end

  test "solves day3 part 1" do
    file =
      """
      R75,D30,R83,U83,L12,D49,R71,U7,L72
      U62,R66,U55,R34,D71,R55,D58,R83
      """
    assert Day3.distance(Day3.parse_file(file)) == 159

    file =
      """
      R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
      U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
      """
    assert Day3.distance(Day3.parse_file(file)) == 135
  end

  test "solves day3 part 2" do
    file =
      """
      R75,D30,R83,U83,L12,D49,R71,U7,L72
      U62,R66,U55,R34,D71,R55,D58,R83
      """
    assert Day3.lowest_total_distance(Day3.parse_file(file)) == 610

    file =
      """
      R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
      U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
      """
    assert Day3.lowest_total_distance(Day3.parse_file(file)) == 410
  end

  test "day4 part 1" do
    assert Day4.valid?(111111)
    assert !Day4.valid?(223450)
    assert !Day4.valid?(123789)
  end

  test "day4 part 2" do
    assert Day4.valid_part2?(112233)
    assert !Day4.valid_part2?(123444)
    assert Day4.valid_part2?(111122)
  end

  test "day 5 part 1" do
    assert Day5.run([1002, 4, 3, 4, 33], 0) == %{input: 0, memory: [1002, 4, 3, 4, 99], output: nil, pc: 4}
    assert Day5.run([3,0,4,0,99], 123) == %{input: 123, memory: [123, 0, 4, 0, 99], output: 123, pc: 4}
  end

  test "day 5 part 2" do
    assert Day5.run([3,9,8,9,10,9,4,9,99,-1,8], 8) |> Map.get(:output) == 1
    assert Day5.run([3,9,8,9,10,9,4,9,99,-1,8], 5) |> Map.get(:output) == 0

    assert Day5.run([3,9,7,9,10,9,4,9,99,-1,8], 7) |> Map.get(:output) == 1
    assert Day5.run([3,9,7,9,10,9,4,9,99,-1,8], 8) |> Map.get(:output) == 0

    assert Day5.run([3,3,1108,-1,8,3,4,3,99], 8) |> Map.get(:output) == 1
    assert Day5.run([3,3,1108,-1,8,3,4,3,99], 5) |> Map.get(:output) == 0

    assert Day5.run([3,3,1107,-1,8,3,4,3,99], 7) |> Map.get(:output) == 1
    assert Day5.run([3,3,1107,-1,8,3,4,3,99], 8) |> Map.get(:output) == 0

    assert Day5.run([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], 5) |> Map.get(:output) == 1
    assert Day5.run([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], 0) |> Map.get(:output) == 0

    assert Day5.run([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], 5) |> Map.get(:output) == 1
    assert Day5.run([3,3,1105,-1,9,1101,0,0,12,4,12,99,1], 0) |> Map.get(:output) == 0
  end

  test "day 6 part 1" do
    input = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """
    |> String.split
    |> Day6.parse_input
    assert Day6.nr_of_orbits(input) == 42
  end

  test "day 6 part 2" do
    input = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    K)YOU
    I)SAN
    """
    |> String.split
    |> Day6.parse_input
    assert Day6.orbital_transfers(input) == 4
  end

  test "day 7 part 1" do
    assert Day7.max_thruster_signal([3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0]) == {43210, [4, 3, 2, 1, 0]}
    assert Day7.max_thruster_signal([3, 23, 3, 24, 1002, 24, 10, 24, 1002, 23, -1, 23, 101, 5, 23, 23, 1, 24, 23, 23, 4, 23, 99, 0, 0]) == {54321, [0, 1, 2, 3, 4]}
    assert Day7.max_thruster_signal([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]) == {65210, [1,0,4,3,2]}
  end

  test "day 7 part 2" do
    assert Day7.max_feedback_thruster_signal([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]) == {139629729, [9,8,7,6,5]}
    assert Day7.max_feedback_thruster_signal([3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]) == {18216, [9,7,8,5,6]}
  end
end