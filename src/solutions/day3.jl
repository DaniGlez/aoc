using Pipe, StaticArrays

priority(c::Char) = islowercase(c) ? c + 1 - 'a' : 27 + c - 'A'
function process_line(line)
    n = length(line)
    p1 = collect(line[1:(n÷2)])
    p2 = collect(line[(n÷2+1):n])
    for c ∈ p2
        if c ∈ p1
            return priority(c)
        end
    end
end

split(readchomp("src/inputs/day3.txt"), "\n") .|> process_line |> sum

function get_arr(line)
    arr = @MArray zeros(Int32, 52)
    n = length(line)
    for i ∈ 1:n
        c = line[i]
        arr[priority(c)] = 1
    end
    return SArray(arr)
end

function process_group(bags...)
    prios = bags .|> get_arr
    for i ∈ 1:52
        if sum(arr[i] for arr ∈ prios) == length(bags)
            return i
        end
    end
end

lines = split(readchomp("src/inputs/day3.txt"), "\n")
n_groups = length(lines) ÷ 3
threes = reshape(lines, (3, n_groups))
@pipe 1:n_groups .|> threes[:, _] .|> process_group(_...) |> sum