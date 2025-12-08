function max_joltage(bank, digits=1)
    digits == 1 && return maximum(bank)
    bank_ltail = @view bank[1:end-digits+1]
    max_msd = maximum(bank_ltail)
    i = findfirst(==(max_msd), bank_ltail)
    return max_msd * 10^(digits - 1) + max_joltage((@view bank[i+1:end]), digits - 1)
end

begin
    sum(eachline("2025/inputs/day03.txt")) do line
        bank = parse.(Int64, collect(line))
        max_joltage(bank, 2)
    end
end

begin
    sum(eachline("2025/inputs/day03.txt")) do line
        bank = parse.(Int64, collect(line))
        max_joltage(bank, 12)
    end
end