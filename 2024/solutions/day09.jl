
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