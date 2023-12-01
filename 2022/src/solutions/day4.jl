using Pipe

# inputs
task_range(s) = @pipe split(s, '-') .|> parse(Int64, _) |> (:)(_...)
range_pair(line) = split(line, ',') .|> task_range
lines = split(readchomp("src/inputs/day4.txt"), "\n")
pairs = range_pair.(lines)

# p1
range_contained(r1, r2) = (r1[begin] ∈ r2) && (r1[end] ∈ r2)
matches_p1(pair) = range_contained(pair[1], pair[2]) || range_contained(pair[2], pair[1])
@pipe matches_p1.(pairs) .|> Int64 |> sum

# p2
overlaps(pair) = length(intersect(Set.(pair)...)) > 0
@pipe overlaps.(pairs) .|> Int64 |> sum