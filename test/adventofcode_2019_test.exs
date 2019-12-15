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

  test "day 8 part 1" do
    input = "123456789012" |> String.graphemes |> Enum.map(&String.to_integer/1)
    assert Day8.create_image(input, 3, 2) == [[[1, 2, 3], [4, 5, 6]], [[7, 8, 9], [0, 1, 2]]]
  end

  test "day 8 part 2" do
    input = "0222112222120000" |> String.graphemes |> Enum.map(&String.to_integer/1)
    assert Day8.create_image(input, 2, 2) |> Day8.decode == [[0, 1], [1, 0]]
  end

  test "day 9 part 1" do
    assert Day9.run([109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]) |> Map.get(:output)
           == [109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99]

    assert Day9.run([1102,34915192,34915192,7,4,7,99,0]) |> Map.get(:output) |> List.first |> Integer.digits |> length == 16

    assert Day9.run([104,1125899906842624,99]) |> Map.get(:output) |> List.first == 1125899906842624
  end

  test "day 10 part 1" do
    input =
      """
      .#..#
      .....
      #####
      ....#
      ...##
      """
    assert input |> String.split |> Enum.to_list |> Day10.new_map |> Day10.most_visible == {{3, 4}, 8}

    input =
    """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """
    assert input |> String.split |> Enum.to_list |> Day10.new_map |> Day10.most_visible == {{11, 13}, 210}
  end

  test "day 10 part 2" do
    input =
      """
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
      """
    assert input |> String.split |> Enum.to_list |> Day10.new_map |> Day10.vaporize(200) == {8, 2}
  end

  test "day 12 part 1" do
    """
    <x=-1, y=0, z=2>
    <x=2, y=-10, z=-7>
    <x=4, y=-8, z=8>
    <x=3, y=5, z=-1>
    """
    |> String.split("\n", trim: true)
    |> Enum.map(&Day12.parse_row/1)
    |> Day12.initial_velocity
    |> Day12.steps(10)
  end

  test "day 12 part 2" do
    moons =
      """
      <x=-8, y=-10, z=0>
      <x=5, y=5, z=10>
      <x=2, y=-7, z=3>
      <x=9, y=-8, z=-3>
      """
      |> String.split("\n", trim: true)
      |> Enum.map(&Day12.parse_row/1)
      |> Day12.initial_velocity

    assert Day12.cycle(moons) == 4686774924
  end

  test "day 14 part 1" do
    input =
      """
      10 ORE => 10 A
      1 ORE => 1 B
      7 A, 1 B => 1 C
      7 A, 1 C => 1 D
      7 A, 1 D => 1 E
      7 A, 1 E => 1 FUEL
      """
    reactions = input |> String.split("\n", trim: true) |> Enum.map(&Day14.parse_row/1)
    assert Day14.simplify(reactions, [{1, :FUEL}]) == 31

    input =
    """
    171 ORE => 8 CNZTR
    7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
    114 ORE => 4 BHXH
    14 VRPVC => 6 BMBT
    6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
    6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
    15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
    13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
    5 BMBT => 4 WPTQ
    189 ORE => 9 KTJDG
    1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
    12 VRPVC, 27 CNZTR => 2 XDBXC
    15 KTJDG, 12 BHXH => 5 XCVML
    3 BHXH, 2 VRPVC => 7 MZWV
    121 ORE => 7 VRPVC
    7 XCVML => 6 RJRHP
    5 BHXH, 4 VRPVC => 5 LTCX
    """
    reactions = input |> String.split("\n", trim: true) |> Enum.map(&Day14.parse_row/1)
    assert Day14.simplify(reactions, [{1, :FUEL}]) == 2210736
  end

  test "day 14 part 2" do
    ore = 1000000000000
    input =
      """
      157 ORE => 5 NZVS
      165 ORE => 6 DCFZ
      44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
      12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
      179 ORE => 7 PSHF
      177 ORE => 5 HKGWZ
      7 DCFZ, 7 PSHF => 2 XJWVT
      165 ORE => 2 GPVTF
      3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
      """
    reactions = input |> String.split("\n", trim: true) |> Enum.map(&Day14.parse_row/1)
    assert Day14.max_fuel(reactions, ore) == 82892753

    input =
      """
      171 ORE => 8 CNZTR
      7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
      114 ORE => 4 BHXH
      14 VRPVC => 6 BMBT
      6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
      6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
      15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
      13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
      5 BMBT => 4 WPTQ
      189 ORE => 9 KTJDG
      1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
      12 VRPVC, 27 CNZTR => 2 XDBXC
      15 KTJDG, 12 BHXH => 5 XCVML
      3 BHXH, 2 VRPVC => 7 MZWV
      121 ORE => 7 VRPVC
      7 XCVML => 6 RJRHP
      5 BHXH, 4 VRPVC => 5 LTCX
      """
    reactions = input |> String.split("\n", trim: true) |> Enum.map(&Day14.parse_row/1)
    assert Day14.max_fuel(reactions, ore) == 460664
  end
end