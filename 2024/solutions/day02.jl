using Pipe

parse_line(line) = @pipe split(line, " ") .|> parse(Int64, _)

function is_safe(v)
    d = diff(v)
    (all(d .>= 0) || all(d .<= 0)) && all(1 .<= abs.(d) .<= 3)
end

p1(input="2024/inputs/day02.txt") = count(is_safe ∘ parse_line, eachline(input))

p1() |> println

function is_safe_dampener(v)
    n = length(v)
    is_safe(v) || any(1:n) do i
        is_safe(vcat(v[1:i-1], v[i+1:end]))
    end
end

p2(input="2024/inputs/day02.txt") = count(is_safe_dampener ∘ parse_line, eachline(input))
p2() |> println