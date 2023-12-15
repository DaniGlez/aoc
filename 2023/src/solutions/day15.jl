using Pipe

op(n, c) = 17 * (n + Int64(c)) % 256
HASH(s) = foldl(op, s; init=0)

sum(HASH, @pipe (
    read("2023/inputs/input15.txt", String)
    |> replace(_, '\n' => "") |> split(_, ',')
)) |> println

# ------ Part 2 ------
struct Lens
    label::String
    focal_length::UInt8
end

function remove_label!(boxes, instruction)
    label = chop(instruction)
    box = boxes[HASH(label)]
    for (i, lens) ∈ enumerate(box)
        if lens.label == label
            deleteat!(box, i)
            return nothing
        end
    end
    nothing
end

chopchop = (chop ∘ chop)

function set_lens!(boxes, instruction)
    f = last(instruction) - '0'
    label = chopchop(instruction)
    new_lens = Lens(label, f)
    box = boxes[HASH(label)]
    for (i, lens) ∈ enumerate(box)
        if lens.label == label
            box[i] = new_lens
            return nothing
        end
    end
    push!(box, new_lens)
end

function solve_p2(instructions)
    boxes = Dict(i => Lens[] for i ∈ 0:255)
    for instruction ∈ instructions
        if last(instruction) == '-'
            remove_label!(boxes, instruction)
        else
            set_lens!(boxes, instruction)
        end
    end
    boxes
end

function focusing_power(ibox)
    i, box = ibox
    isempty(box) && return 0
    sum(((j, lens),) -> j * lens.focal_length, enumerate(box)) * (i + 1)
end


sum(focusing_power, @pipe (
    read("2023/inputs/input15.txt", String)
    |> replace(_, '\n' => "") |> split(_, ',') |> solve_p2 |> collect
)) |> println