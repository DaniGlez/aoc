

begin
    coords = map(eachline("2025/inputs/day08.txt")) do line
        map(split(line, ",") |> Tuple) do x
            parse(Int, x)
        end
    end
    N = length(coords)
    distances = NTuple{3,Int64}[]
    for (i, x) ∈ enumerate(coords)
        for j ∈ (i+1):N
            y = coords[j]
            r = x .- y
            d = sum(r .^ 2)
            push!(distances, (d, i, j))
        end
    end
    sort!(distances; by=x -> x[1])
    connected_at = zeros(Int64, N)
    connected(i) = connected_at[i] > 0
    circuits = Set{Int64}[]
    max_conns = 1000
    p1_answer = 0
    p2_answer = 0
    n_conns = 1
    disabled_circuits = Set{Int64}()
    while !isempty(distances)
        if n_conns == max_conns
            sizes = length.(circuits)
            sort!(sizes; rev=true)
            p1_answer = sizes[1] * sizes[2] * sizes[3]
        end
        n_conns += 1
        (d, i, j) = popfirst!(distances)
        if !connected(i) && !connected(j)
            push!(circuits, Set((i, j)))
            connected_at[i] = length(circuits)
            connected_at[j] = length(circuits)
        else
            c_i = connected_at[i]
            c_j = connected_at[j]
            if c_i != c_j
                p2_answer = coords[i][1] * coords[j][1]
            end
            if connected(i) + connected(j) == 1
                k = max(c_i, c_j)
                circuit = circuits[k]
                push!(circuit, i)
                push!(circuit, j)
                connected_at[i] = k
                connected_at[j] = k
            else # both connected but in different circuits
                c_l, c_h = minmax(c_i, c_j)
                circuit_l = circuits[c_l]
                circuit_h = circuits[c_h]
                union!(circuit_l, circuit_h)
                push!(circuit_l, i)
                push!(circuit_l, j)
                if c_i != c_j
                    #deleteat!(circuits, c_h)
                    push!(disabled_circuits, c_h)
                    for idx in 1:N
                        if connected_at[idx] == c_h
                            connected_at[idx] = c_l
                        end
                    end
                end
                connected_at[i] = c_l
                connected_at[j] = c_l
            end
        end
    end
    p1_answer, p2_answer
end

# < 75727690