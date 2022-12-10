using Pipe, Accessors, StaticArrays, DataStructures

# structs
abstract type Op end
struct NoOp <: Op end
struct AddX <: Op
    value::Int64
end

struct CPUState
    cycle::Int64
    X::Int64
    accumulator::Int64
    pixel::Int64
end
CPUState() = CPUState(1, 1, 0, 0)

n_cycles(::NoOp) = 1
n_cycles(::AddX) = 2
apply(c::CPUState, ::NoOp) = c
apply(c::CPUState, op::AddX) = @set c.X += op.value
checkpoint_and_yield(c::CPUState) = c.cycle ∈ 20:40:220 ? (c.cycle * c.X) : 0

# input
pline(line) = startswith(line, "addx") ? AddX(parse(Int64, line[6:end])) : NoOp()
function input_ops()
    q = Queue{Union{NoOp,AddX}}()
    for line ∈ eachline("src/inputs/day10.txt")
        enqueue!(q, pline(line))
    end
    q
end

# part 1&2
function process!(c::CPUState, crt, op::Op)
    for _ ∈ 1:n_cycles(op)
        y = (c.cycle - 1) ÷ 40
        x = (c.cycle - 1) % 40
        sprite = (c.X-1):(c.X+1)
        (x ∈ sprite) ? (crt[y+1, x+1] = '#') : nothing
        c = @set c.accumulator += checkpoint_and_yield(c)
        c = @set c.cycle += 1
        c = @set c.pixel = (c.pixel + 1) % 3
    end
    apply(c, op)
end

function solve(ops)
    cpu = CPUState()
    crt = fill('.', (6, 40))
    while !isempty(ops)
        cpu = process!(cpu, crt, dequeue!(ops))
    end
    for i ∈ 1:6
        println(join(crt[i, :]))
    end
    cpu.accumulator
end

input_ops() |> solve |> println