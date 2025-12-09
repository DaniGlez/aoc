function parse_line(line)
    split(line, " ") .|> strip |> filter(!isempty)
end

begin
    lines = parse_line.(readlines("2025/inputs/day06.txt"))
    sum(eachindex(lines[1])) do i
        op = last(lines)[i] == "+" ? (+) : (*)
        mapreduce(op, lines[1:end-1]) do l
            parse(Int, l[i])
        end
    end
end

begin
    lines = readlines("2025/inputs/day06.txt")
    number_lines = lines[1:end-1]
    max_l = maximum(length.(number_lines))
    ops = last(lines)
    ops_idx = filter(collect(eachindex(ops))) do i
        ops[i] ∈ ('+', '*')
    end
    col_idxs = zip(ops_idx, vcat(ops_idx[2:end] .- 1, max_l + 1))
    sum(col_idxs) do (start_idx, end_idx)
        op = ops[start_idx] == '+' ? (+) : (*)
        rows = map(number_lines) do line
            @view line[start_idx:(end_idx-1)]
        end
        nos = map(eachindex(rows |> first)) do i
            number_string = map(rows) do r
                                r[i]
                            end |> String |> strip

            parse(Int, number_string)
        end
        reduce(op, nos)
    end
end