
line = readlines("2024/inputs/day09.txt") |> only |> collect |> x -> parse.(Int, x)

function process_line(line)
    fs = Int64[] #zeros(Int, sum(line))
    sizehint!(fs, sum(line))
    is_block = true
    block_id = 0
    for n ∈ line
        if is_block
            for _ ∈ 1:n
                push!(fs, block_id)
            end
            block_id += 1
        else
            for _ ∈ 1:n
                push!(fs, -1)
            end
        end
        is_block = !is_block
    end
    fs
end

function defragment(fs)
    cur_empty = firstindex(fs)
    cur_last = lastindex(fs)
    while cur_empty < cur_last
        if fs[cur_empty] != -1
            cur_empty += 1
        elseif fs[cur_last] == -1
            cur_last -= 1
        else
            fs[cur_empty], fs[cur_last] = fs[cur_last], fs[cur_empty]
        end
    end
    fs
end

function checksum(fs)
    sum(enumerate(fs)) do (i, n)
        n > 0 ? n * (i - 1) : 0
    end
end

process_line(line) |> defragment |> checksum

function show_line(line)
    for (n, block_id) ∈ line
        for i in 1:n
            if block_id == -1
                print(".")
            else
                print(block_id)
            end
        end
    end
    println("")
end

function process_line2(line)
    fs = NTuple{2,Int64}[] #zeros(Int, sum(line))
    sizehint!(fs, length(line))
    is_block = true
    block_id = 0
    for n ∈ line
        if is_block
            push!(fs, (n, block_id))
            block_id += 1
        else
            push!(fs, (n, -1))
        end
        is_block = !is_block
    end
    fs
end

function merge_empty!(fs, i)
    length(fs) < i && return nothing
    fs[i][2] == -1 || return nothing
    length(fs) < i + 1 && return nothing
    while fs[i+1][2] == -1
        fs[i] = (fs[i][1] + fs[i+1][1], -1)
        deleteat!(fs, i + 1)
        length(fs) < i + 1 && return nothing
    end
end

function defragment2(fs)
    cur_id = last(fs)[2]
    cur_empty = findfirst(x -> x[2] == -1, fs)
    while cur_id > 0
        cur_last = findlast(x -> x[2] == cur_id, fs)
        cur_empty >= cur_last && continue
        cur_size = first(fs[cur_last])
        for cur_seek ∈ cur_empty:cur_last
            last(fs[cur_seek]) == -1 || continue
            empty_size = first(fs[cur_seek])
            if empty_size == cur_size
                fs[cur_seek], fs[cur_last] = fs[cur_last], fs[cur_seek]
                break
            elseif empty_size > cur_size
                new_empty = (empty_size - cur_size, -1)
                fs[cur_seek] = fs[cur_last]
                fs[cur_last] = (cur_size, -1)
                merge_empty!(fs, cur_last - 1)
                merge_empty!(fs, cur_last) # in case previous position has a block
                insert!(fs, cur_seek + 1, new_empty)
                merge_empty!(fs, cur_seek + 1)
                break
            end
        end
        cur_id -= 1
        cur_size = first(fs[cur_last])
        cur_last -= 2
    end
    fs
end

function checksum2(fs)
    acc = 0
    i = 0
    for (n, block_id) ∈ fs
        for j ∈ 1:n
            if block_id != -1
                acc += i * block_id
            end
            i += 1
        end
    end
    acc
end

process_line2(line) |> defragment2 |> checksum2


line = readlines("2024/inputs/day09.txt") |> only |> collect |> x -> parse.(Int, x)

using Accessors

struct Block
    size::Int64
    space_after::Int64
end

function process_filesystem(line)
    blocks = Block[]
    sizehint!(blocks, length(line) ÷ 2 + 1)
    prev = Dict{Int64,Int64}()
    next = Dict{Int64,Int64}()
    for i ∈ 1:2:length(line)
        idx = i ÷ 2 + 1
        empty_space = (i + 1) ∈ eachindex(line) ? line[i+1] : 0
        b = Block(line[i], empty_space)
        push!(blocks, b)
        i == 1 && continue
        prev[idx] = idx - 1
        next[idx-1] = idx
    end
    next[length(blocks)] = length(blocks) + 1
    blocks, next, prev
end

(blocks, next, prev) = process_filesystem(line);

function find_slot(blocks, next, l, r)
    b = l
    necessary_size = blocks[r].size
    while true
        b == r && return b
        blocks[b].space_after >= necessary_size && return b
        b = next[b]
    end
end

function defragment2(inputs)
    (blocks, d_next, d_prev) = inputs
    r = length(blocks)
    l = 1
    while true
        r <= l && break
        if blocks[l].space_after == 0
            l += 1
            continue
        end
        b_swap = find_slot(blocks, d_next, l, r)
        b_swap == r && continue
        # here comes the swap
        available_space = blocks[b_swap].space_after
        block_prev = blocks[d_prev[r]]
        blocks[d_prev[r]] = @set block_prev.space_after =
            blocks[d_prev[r]].space_after + blocks[r].size + blocks[r].space_after
        block_r = blocks[r]
        blocks[r] = @set block_r.space_after = available_space - blocks[r].space_after
        block_swapped = blocks[b_swap]
        blocks[b_swap] = @set block_swapped.space_after = 0
        d_prev[r], d_prev[d_next[r]], d_prev[d_next[b_swap]],
        d_next[r], d_next[d_prev[r]], d_next[b_swap] =
            b_swap, d_prev[r], r, d_next[b_swap], d_next[r], r
        # next
        r -= 1
    end
    blocks, d_next
end

function checksum2(inputs)
    (blocks, d_next) = inputs
    acc = 0
    i = 0
    b = blocks |> first
    while b ∈ keys(d_next)
        for j ∈ 1:b.size
            acc += i * (b - 1)
            i += 1
        end
        i += b.space_after
        b = d_next[b]
    end
    acc
end

process_filesystem(line) |> defragment2 |> checksum2