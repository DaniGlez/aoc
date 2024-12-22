const CI = CartesianIndex

function parse_input(filename="2024/inputs/day22.txt")
    parse.(Int, eachline(filename))
end

function step(n)
    a = ((64n) ⊻ n) % 16777216
    b = ((a ÷ 32) ⊻ a) % 16777216
    ((2048b) ⊻ b) % 16777216
end

function advance(n, t)
    for _ in 1:t
        n = step(n)
    end
    n
end

last_digit(n) = n % 10

function fill_n!(A, n, i)
    Δ = (-100, -100, -100, -100)
    for _ ∈ 1:2_000
        cur_price = last_digit(n)
        n_next = step(n)
        next_price = last_digit(n_next)
        d = next_price - cur_price
        Δ = (Δ[2], Δ[3], Δ[4], d)
        n = n_next
        if minimum(Δ) > -100
            idxs = CI(i, (Δ .+ 10)...)
            if A[idxs] == -1
                A[idxs] = next_price
            end
        end
    end
end

ifsum(acc, x) = x > 0 ? acc + x : acc

function p2(inputs)
    A = zeros(Int, (length(inputs), 20, 20, 20, 20))
    fill!(A, -1)
    for (i, n) ∈ enumerate(inputs)
        fill_n!(A, n, i)
    end
    B = zeros(Int, 20, 20, 20, 20)
    for ci ∈ CartesianIndices(B)
        B[ci] = reduce(ifsum, A[:, ci.I...]; init=0)
    end
    maximum(B)
end


sum(parse_input()) do n
    advance(n, 2000)
end

begin
    n_seqs = parse_input()
    sum(n_seqs) do n
        advance(n, 2000)
    end |> println
    n_seqs |> p2 |> println
end