function c2i(c::Char)
    c == '=' && return -2
    c == '-' && return -1
    c - '0'
end

i2c(i) = "=-012"[i+3]
t2i(t) = 5^(t[1] - 1) * c2i(t[2])
snafu2int(snafu) = reverse(snafu) |> enumerate .|> t2i |> sum

function int2snafu(n)
    d = digits(n, base=5)
    push!(d, 0)
    for i ∈ 1:length(d)-1
        if d[i] > 2
            d[i] -= 5
            d[i+1] += 1
        end
    end
    d[end] == 0 && (d = d[1:end-1])
    reverse(d) .|> i2c |> join
end


solve_p1(fpath="src/inputs/day25.txt") = readlines(fpath) .|> snafu2int |> sum |> int2snafu
solve_p1() |> println