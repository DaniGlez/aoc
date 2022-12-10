using Accessors

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
end
CPUState() = CPUState(1, 1, 0)

n_cycles(::NoOp) = 1
n_cycles(::AddX) = 2
apply(c::CPUState, ::NoOp) = c
apply(c::CPUState, op::AddX) = @set c.X += op.value
checkpoint_and_yield(c::CPUState) = c.cycle ∈ 20:40:220 ? (c.cycle * c.X) : 0

# input
pline(line) = startswith(line, "addx") ? AddX(parse(Int64, line[6:end])) : NoOp()

# part 1&2
function process!(c::CPUState, crt, op::Op)
    for _ ∈ 1:n_cycles(op)
        y = (c.cycle - 1) ÷ 40
        x = (c.cycle - 1) % 40
        sprite = (c.X-1):(c.X+1)
        if x ∈ sprite
            crt[y+1, x+1] = '#'
        end
        c = @set c.accumulator += checkpoint_and_yield(c)
        c = @set c.cycle += 1
    end
    apply(c, op)
end

function solve(ops)
    cpu = CPUState()
    crt = fill('.', (6, 40))
    for line ∈ eachline("src/inputs/day10.txt")
        op = pline(line)
        cpu = process!(cpu, crt, op)
    end
    for row ∈ eachrow(crt)
        join(row) |> println
    end
    cpu.accumulator
end

input_ops() |> solve |> println