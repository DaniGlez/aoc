function parse_line(line)
    chunks = split(line, ":")
    parse(Int64, chunks[1]), [parse(Int64, x) for x in split(chunks[2], " ") if !isempty(x)]
end

# "get the star ASAP" version:
# concat(x, y) = parse(Int, "$x$y")
concat(x, y) = y + x * 10^(floor(Int64, log10(y)) + 1)

function solve(input; n_ops=2)
    sum(input) do (target, values)
        matches = any(0:(n_ops^(length(values)-1))) do i
            d, r = i - 1, 0
            acc = values[1]
            for j ∈ eachindex(values)[2:end]
                d, r = divrem(d, n_ops)
                if r == 1
                    acc += values[j]
                elseif r == 0
                    acc *= values[j]
                elseif r == 2
                    # "get the star ASAP" version
                    # acc = parse(Int, "$(acc)$(values[j])") 
                    acc = concat(acc, values[j])
                end
                acc > target && break # save the planet
            end
            acc == target
        end
        matches ? target : 0
    end
end

solve_p1(input) = solve(input)
solve_p2(input) = solve(input; n_ops=3)

begin
    input = map(parse_line, readlines("2024/inputs/day07.txt"))
    solve_p1(input) |> println
    solve_p2(input) |> println
end

# ========================================================
# optimized version (my implementation, though not my idea)

number_of_digits(x) = floor(Int64, log10(x)) + 1
check_prod(target, x) = iszero(target % x)
check_concat(target, x) = target % 10^(number_of_digits(x)) == x
deconcat(target, x) = target ÷ 10^(number_of_digits(x))

function solve(target, nums, ::Val{n_ops}) where {n_ops}
    length(nums) == 1 && return only(nums) == target
    ltail = @view nums[1:end-1]
    target >= last(nums) &&
            solve(target - last(nums), ltail, Val(n_ops)) ||
        (check_prod(target, last(nums)) &&
         solve(target ÷ last(nums), ltail, Val(n_ops))) ||
        n_ops > 2 && check_concat(target, last(nums)) &&
            solve(deconcat(target, last(nums)), ltail, Val(n_ops))
end


function solve(input; n_ops=2)
    sum(input) do (target, values)
        solve(target, values, Val(n_ops)) ? target : 0
    end
end

begin
    input = map(parse_line, readlines("2024/inputs/day07.txt"))
    solve(input) |> println
    solve(input; n_ops=3) |> println
end

using BenchmarkTools
bsolve(input) = (solve(input), solve(input; n_ops=3))
input = map(parse_line, readlines("2024/inputs/day07.txt"))
@btime bsolve(input)