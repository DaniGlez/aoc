# part 1
parseval = (eval ∘ Meta.parse)
for line ∈ eachline("src/inputs/day21.txt")
    if line[7] ∈ '1':'9'
        parseval("$(line[1:4])() = $(line[7:end])")
    else
        c = line[12]
        (c == '/') && (c = '÷')
        parseval("$(line[1:4])() = $(line[7:10])()$(c)$(line[14:17])()")
    end
end

root()

# part 2
for line ∈ eachline("src/inputs/day21.txt")
    startswith(line, "humn") && continue
    if startswith(line, "root")
        f1 = line[7:10]
        f2 = line[14:17]
        parseval("root(x, p) = $f1(x) - $f2(x)")
    elseif line[7] ∈ '1':'9'
        parseval("$(line[1:4])(x) = $(line[7:end])")
    else
        c = line[12]
        (c == '/') && (c = '÷')
        parseval("$(line[1:4])(x) = $(line[7:10])(x) $c $(line[14:17])(x)")
    end
end
humn(x) = x

using SimpleNonlinearSolve
u0 = (-1000.0, 1000.0)
probB = IntervalNonlinearProblem(root, u0)
sol = solve(probB, Falsi())
round(Int64, sol.u)