# ------ Part 1 ------
parse_line(line) = map(m -> parse(Int64, m.captures[1]), eachmatch(r"(\d+)", line))
fetch_input(path="2023/inputs/input06.txt") = zip((eachline(path) .|> parse_line)...) |> collect
distance(pulse, time) = (time - pulse) * pulse
combinations(t, d) = count(i -> distance(i, t) > d, 1:t)
combinations(td) = combinations(td...)
prod(combinations, fetch_input()) |> println

# ------ Part 2 ------
parse_line_2(line) = parse(Int64, prod(m -> m.captures[1], eachmatch(r"(\d+)", line)))
fetch_input_2(path="2023/inputs/input06.txt") = parse_line_2.(eachline(path))
t, d = fetch_input_2()
r1, r2 = (-1, 1) .|> s -> 0.5(t + s * sqrt(t^2 - 4d))
floor(Int64, r2) - ceil(Int64, r1) + 1 |> println
