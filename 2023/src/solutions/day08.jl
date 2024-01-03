const C3 = NTuple{3,Char}
tcollect = Tuple ∘ collect
lr2idx(c::Char) = (c == 'L' ? 1 : 2)

function fetch_input(path="2023/inputs/input08.txt")
    instructs = Char[]
    nodes = Dict{C3,Tuple{C3,C3}}()
    for (i, line) ∈ enumerate(eachline(path))
        i == 1 && append!(instructs, collect(line))
        i == 2 && continue
        a, b, c = map(pos -> ntuple(i -> line[pos+i], 3), (0, 7, 12))
        nodes[a] = (b, c)
    end
    instructs, nodes
end

begin
    instructs, nodes = fetch_input()
    n = length(instructs)
    steps = 0
    cur_node = tcollect("AAA")
    while cur_node != tcollect("ZZZ")
        steps += 1
        lr = instructs[mod1(steps, n)]
        cur_node = nodes[cur_node][lr2idx(lr)]
    end
    steps
end |> println

# ------ Part 2 ------
ends_in_z(n) = (last(n) == 'Z')
function compute_cycle(instructions, nodes, n)
    zvec = BitVector(undef, length(instructions))
    for (i, lr) ∈ enumerate(instructions)
        n = nodes[n][lr2idx(lr)]
        zvec[i] = ends_in_z(n)
    end
    n, zvec
end

check_no_z_ending_in_cycle(zvec) = sum(zvec) == 0

function cycle_transition_map(instructions, nodes)
    cycle_map = Dict{C3,C3}()
    cur_nodes = keys(nodes) |> filter(k -> last(k) == 'A') |> collect
    z_nodes = C3[]
    sizehint!(z_nodes, 6)
    while !isempty(cur_nodes)
        start_node = pop!(cur_nodes)
        start_node ∈ keys(cycle_map) && continue
        end_node, zvec = compute_cycle(instructions, nodes, start_node)
        @assert sum(zvec[1:end-1]) == 0 # z at end only 
        zvec[end] == 1 && push!(z_nodes, start_node)
        cycle_map[start_node] = end_node
        push!(cur_nodes, end_node)
    end
    cycle_map, z_nodes
end

struct SuperCycle
    time_to_z::Int64
    period::Int64
end

_after_n(sc::SuperCycle, n) = sc.time_to_z + n * sc.period

function merge(a::SuperCycle, b::SuperCycle)
    # cba to implement Extended Euclidean stuff
    period = lcm(a.period, b.period)
    n, m = 0, 0
    while true
        a_n = _after_n(a, n)
        b_m = _after_n(b, m)
        a_n == b_m && return SuperCycle(a_n, period)
        a_n > b_m ? (m += 1) : (n += 1)
    end
end

function find_supercycle(transition_map, z_nodes, start_node)
    visited_nodes = [start_node]
    i = 0
    current_node = start_node
    ttz = 0
    while true
        i += 1
        next_node = transition_map[current_node]
        if next_node ∈ z_nodes
            loc = findfirst(==(next_node), visited_nodes)
            isnothing(loc) ? (ttz = i) : return SuperCycle(ttz, i - ttz)
        end
        push!(visited_nodes, next_node)
        current_node = next_node
    end
end

begin
    instructs, nodes = fetch_input()
    cur_nodes = keys(nodes) |> filter(k -> last(k) == 'A') |> Tuple
    cycles = 0
    N = length(instructs)
    cycle_map, z_nodes = cycle_transition_map(instructs, nodes)
    cycles = [find_supercycle(cycle_map, z_nodes, n) for n ∈ cur_nodes]
    total_cycles = reduce(merge, cycles).time_to_z
    (1 + total_cycles) * length(instructs)
end |> println
