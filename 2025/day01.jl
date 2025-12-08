begin
    i = 50
    acc = 0
    for line in eachline("2025/inputs/day01.txt")
        sgn = line[1] == 'R' ? 1 : -1
        n = parse(Int, line[2:end])
        i += sgn * n
        i = mod(i, 100)
        if i == 0
            acc += 1
        end
    end
    println("Total positions on dial: $acc")
end

begin
    i = 50
    clicks = 0
    for line in eachline("2025/inputs/day01.txt")
        sgn = line[1] == 'R' ? 1 : -1
        n = parse(Int, line[2:end])
        cents = n ÷ 100
        clicks += cents
        n -= 100cents
        i += sgn * n
        if i ∉ 0:99
            i = mod(i, 100)
            clicks += 1
        end
    end
    println("Total positions on dial: $clicks")
end
