using DataStructures, Pipe

abstract type Op end
struct Square <: Op end
struct Add <: Op
    value::Int64
end
struct Mul <: Op
    value::Int64
end

square(x::Integer) = x^2
(::Square)(x) = square(x)
(m::Mul)(x) = m.value * x
(a::Add)(x) = a.value + x

struct Monkey{O<:Op,T}
    items::Queue{T}
    op::O
    test::Int64
    pass_if_true::Int64
    pass_if_false::Int64
    function Monkey(starting_items::Vector{T}, op::O, test, pit, pif) where {O,T}
        q = Queue{T}()
        for item in starting_items
            enqueue!(q, item)
        end
        new{O,T}(q, op, test, pit, pif)
    end
end

pInt(x) = parse(Int64, x)
function parse_op(line_end)
    startswith(line_end, "* old") && return Square()
    startswith(line_end, "*") && return Mul(line_end[3:end] |> strip |> pInt)
    startswith(line_end, "+") && return Add(line_end[3:end] |> strip |> pInt)
    error("Instruction not found: old $line_end")
end

function Monkey(txt, T)
    lines = split(txt, '\n')
    starting_items = split(lines[2][19:end], ", ") .|> pInt
    o = parse_op(lines[3][24:end])
    test = lines[4][22:end] |> strip |> pInt
    pit = split(lines[5], " to monkey ")[2] |> strip |> pInt
    pif = split(lines[6], " to monkey ")[2] |> strip |> pInt
    Monkey(starting_items .|> T, o, test, pit, pif)
end

function init_monkeys(fpath="src/inputs/day11.txt"; T=Int64)
    @pipe split(readchomp(fpath), "Monkey ")[2:end] .|> Monkey(_, T)
end

function turn!(monkey::Monkey{O,T}; high_worry=false) where {O,T}
    output = Queue{Tuple{Int64,T}}()
    while !isempty(monkey.items)
        item = dequeue!(monkey.items)
        new_worry = monkey.op(item)
        new_worry = high_worry ? new_worry : (new_worry ÷ 3)
        destinations = (monkey.pass_if_false, monkey.pass_if_true)
        pass_to = destinations[Int(new_worry % monkey.test == 0)+1]
        enqueue!(output, (pass_to, new_worry))
    end
    output
end

function round!(monkeys, inspections; high_worry=false)
    for (i, monkey) ∈ enumerate(monkeys)
        to_deliver = turn!(monkey; high_worry=high_worry)
        inspections[i] += length(to_deliver)
        for (j, item) ∈ to_deliver
            enqueue!(monkeys[j+1].items, item)
        end
    end
end

function solve(T, n_rounds=20; high_worry=false)
    monkeys = init_monkeys(; T=T)
    inspections = zeros(Int64, length(monkeys))
    for _ ∈ 1:n_rounds
        round!(monkeys, inspections; high_worry=high_worry)
    end
    sort!(inspections)
    inspections[end-1] * inspections[end]
end

solve_p1() = solve(Int64, 20; high_worry=false)
solve_p1() |> println

# Part 2
struct ModuloNumber{N,D}
    rems::NTuple{N,Int64}
end
ModuloNumber{N,D}(x::Integer) where {N,D} = ModuloNumber{N,D}(x .% D)
import Base: +, *, rem
+(m::ModuloNumber{N,D}, x) where {N,D} = ModuloNumber{N,D}((m.rems .+ x) .% D)
*(m::ModuloNumber{N,D}, x) where {N,D} = ModuloNumber{N,D}((m.rems .* x) .% D)
*(x::Integer, m::ModuloNumber) = m * x
+(x::Integer, m::ModuloNumber) = m + x
square(m::ModuloNumber{N,D}) where {N,D} = ModuloNumber{N,D}((m.rems .* m.rems) .% D)

import Base.Cartesian: @nexprs
@generated function rem(m::ModuloNumber{N,D}, d::Integer) where {N,D}
    quote
        @nexprs $N i -> (d == D[i]) && (return m.rems[i])
    end
end

divisors(monkeys) = Set(m.test for m ∈ monkeys) |> collect |> sort |> Tuple
function solve_p2()
    monkeys = init_monkeys(; T=Int64)
    D = divisors(monkeys)
    N = length(D)
    MND = ModuloNumber{N,D}
    solve(MND, 10000; high_worry=true)
end

solve_p2() |> println

