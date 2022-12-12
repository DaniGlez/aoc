using DataStructures, Pipe
const CI = CartesianIndex
# parsing
line2vec(line) = (collect ∘ strip)(line) .- 'a'
function input_elevations(fpath="src/inputs/day12.txt")
    @pipe readlines(fpath) .|> line2vec |> hcat(_...) |> transpose
end

function inputs()
    elevs = input_elevations()
    start = findfirst(e -> e == 'S' - 'a', elevs)
    finish = findfirst(e -> e == 'E' - 'a', elevs)
    elevs[start] = 0
    elevs[finish] = 'z' - 'a'
    elevs, start, finish
end

l∞(ci::CartesianIndex) = abs(ci.I[1]) + abs(ci.I[2])

const directions = (CI(1, 0), CI(0, 1), CI(-1, 0), CI(0, -1))
_in_grid(A, ci) = (ci.I[1] ∈ 1:size(A)[1]) && (ci.I[2] ∈ 1:size(A)[2])
crossing_allowed(A, from, to) = (A[to] <= A[from] + 1)
valid_neighbour(A, from, to) = _in_grid(A, to) && crossing_allowed(A, from, to)
valid_neighbour_bwd(A, from, to) = _in_grid(A, from) && crossing_allowed(A, from, to)
_neighbours(ci) = [(ci + dir) for dir ∈ directions]
neighbours_fwd(A, ci) = filter(n -> valid_neighbour(A, ci, n), _neighbours(ci))
neighbours_bwd(A, ci) = filter(n -> valid_neighbour_bwd(A, n, ci), _neighbours(ci))

function search(A, start, neighbours, finish_cond, heuristic)
    S = similar(A) # steps from start
    fill!(S, -1)
    S[start] = 0
    frontier = PriorityQueue{CartesianIndex{2},Int64}()
    enqueue!(frontier, start => 0)
    while true
        current, _ = dequeue_pair!(frontier)
        finish_cond(current) && (return S[current])
        for n ∈ neighbours(A, current)
            steps = S[current] + 1
            if (S[n] == -1) || (steps < S[n])
                S[n] = steps
                prio = steps + heuristic(n)
                (n ∈ keys(frontier)) ? (frontier[n] = prio) : enqueue!(frontier, n => prio)
            end
        end
    end
end

function solve_p1()
    A, start, finish = inputs()
    search(A, start, neighbours_fwd, x -> (x == finish), x -> l∞(x - finish))
end

solve_p1()

# part 2: BFS
function solve_p2()
    A, _, finish = inputs()
    search(A, finish, neighbours_bwd, x -> (A[x] == 0), x -> 0)
end
solve_p2()
