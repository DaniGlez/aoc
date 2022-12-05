using Pipe, DataStructures

# inputs
const initial_levels = 8
const n_stacks = 9
initial_chunk, moves_chunk = split(readchomp("src/inputs/day5.txt"), " 1   2   3   4   5   6   7   8   9 ")
initial_lines = split(initial_chunk, "\n")

function init_stacks()
    stacks = [Stack{Char}() for _ ∈ 1:n_stacks]
    for level ∈ 1:initial_levels
        level_line = initial_lines[initial_levels+1-level]
        for (stack_id, c) ∈ enumerate(level_line[2:4:end])
            if c != ' '
                push!(stacks[stack_id], c)
            end
        end
    end
    stacks
end

function proc_move(line)
    nmoves_str, rem_str = split(line[5:end], " from ")
    origin, destination = @pipe split(rem_str, " to ") .|> parse(Int64, _)
    nmoves = parse(Int64, nmoves_str)
    (nmoves, origin, destination)
end

# part 1
stacks = init_stacks()
for line ∈ @pipe strip(moves_chunk) .|> split(_, '\n')
    (nmoves, origin, destination) = proc_move(line)
    for _ ∈ 1:nmoves
        c = pop!(stacks[origin])
        push!(stacks[destination], c)
    end
end

stacks .|> first |> join |> println

# part 2
stacks = init_stacks()
for line ∈ @pipe strip(moves_chunk) .|> split(_, '\n')
    (nmoves, origin, destination) = proc_move(line)
    cache_stack = Stack{Char}()
    for _ ∈ 1:nmoves
        c = pop!(stacks[origin])
        push!(cache_stack, c)
    end
    for _ ∈ 1:nmoves
        c = pop!(cache_stack)
        push!(stacks[destination], c)
    end
end

stacks .|> first |> join |> println

