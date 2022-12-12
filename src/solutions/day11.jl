using DataStructures, Pipe

abstract type Worry end
struct LowWorry <: Worry end
struct HighWorry <: Worry end
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

modworry(::LowWorry, worry_level) = worry_level ÷ 3
modworry(::HighWorry, worry_level) = worry_level
function turn!(monkey::Monkey{O,T}, output, worry) where {O,T}
    while !isempty(monkey.items)
        item = dequeue!(monkey.items)
        new_worry = monkey.op(item)
        new_worry = modworry(worry, new_worry)
        destinations = (monkey.pass_if_false, monkey.pass_if_true)
        pass_to = destinations[Int(new_worry % monkey.test == 0)+1]
        enqueue!(output, (pass_to, new_worry))
    end
    nothing
end

function round!(monkeys, inspections, to_deliver, worry)
    for (i, monkey) ∈ enumerate(monkeys)
        turn!(monkey, to_deliver, worry)
        inspections[i] += length(to_deliver)
        while !isempty(to_deliver)
            j, item = dequeue!(to_deliver)
            enqueue!(monkeys[j+1].items, item)
        end
    end
end

function solve(T, worry, n_rounds=20)
    monkeys = init_monkeys(; T=T)
    inspections = zeros(Int64, length(monkeys))
    to_deliver = Queue{Tuple{Int64,T}}()
    for _ ∈ 1:n_rounds
        round!(monkeys, inspections, to_deliver, worry)
    end
    sort!(inspections)
    inspections[end-1] * inspections[end]
end

solve_p1() = solve(Int64, LowWorry(), 20)
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
    solve(MND, HighWorry(), 10_000)
end

solve_p2() |> println
function find_cycle_length(monkeys, number, in_monkey)
    D = divisors(monkeys)
    P = prod(D)
    visited_on = zeros(Int64, P, 8)
    visited_on[number, in_monkey] = 1
    i = 1
    j = in_monkey
    n = number
    while true
        i += 1
        monkey = monkeys[j]
        n = monkey.op(n)
        n = n % P
        destinations = (monkey.pass_if_false, monkey.pass_if_true)
        j = destinations[Int(n % monkey.test == 0)+1] + 1
        if visited_on[n, j] != 0
            return i - visited_on[n, j]
            break
        end
        visited_on[n, j] = i
    end
end

monkeys = init_monkeys()
s = Set{Int64}()
n_items = 0
for i ∈ 1:8
    monkey = monkeys[i]
    for item ∈ monkey.items
        n_items += 1
        push!(s, find_cycle_length(monkeys, item, i))
    end
end