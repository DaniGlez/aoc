function predict(seq)
    all(iszero, seq) && return 0
    last(seq) + predict(diff(seq))
end

parse_line(l) = parse.(Int64, split(l))
sum(predict, parse_line.(eachline("2023/inputs/input09.txt"))) |> println
sum(predict ∘ reverse, parse_line.(eachline("2023/inputs/input09.txt"))) |> println