function is_invalid(n::Int)
    s = string(n)
    L = length(s)
    for l ∈ 1:min(5, L - 1)
        if mod(L, l) != 0
            continue
        end
        pattern = s[1:l]
        for shift ∈ 0:(L÷l-1)
            start = shift * l + 1
            if s[start:start+l-1] != pattern
                @goto check_failed
            end
        end
        @show n
        return true
        @label check_failed
    end
    return false
end

function is_invalid(n::Int)
    s = string(n)
    L = length(s)
    isodd(L) && return false

    l = L ÷ 2
    pattern = s[1:l]
    for shift ∈ 0:(L÷l-1)
        start = shift * l + 1
        if s[start:start+l-1] != pattern
            @goto check_failed
        end
    end
    @show n
    return true
    @label check_failed
    return false
end


begin
    txt = read("2025/inputs/day02.txt", String)
    ranges = map(split(txt, ',')) do r
        a, b = split(r, '-')
        parse(Int, a):parse(Int, b)
    end
    max_chars = 10
    sum(ranges) do r
        sum(r) do n
            is_invalid(n) ? n : 0
        end
    end |> println
end
