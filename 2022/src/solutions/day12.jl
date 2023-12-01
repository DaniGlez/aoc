using DataStructures, Pipe, StaticArrays
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

const directions = @SArray [CI(1, 0), CI(0, 1), CI(-1, 0), CI(0, -1)]
_in_grid(A, ci) = (ci.I[1] ∈ 1:size(A)[1]) && (ci.I[2] ∈ 1:size(A)[2])
crossing_allowed(A, from, to) = (A[to] <= A[from] + 1)
valid_neighbour_fwd(A, from, to) = _in_grid(A, to) && crossing_allowed(A, from, to)
valid_neighbour_bwd(A, from, to) = _in_grid(A, to) && crossing_allowed(A, to, from)

using Base.Cartesian: @nexprs
@generated function search(A, start, valid_neighbour, finish_cond)
    quote
        S = similar(A) # steps from start
        fill!(S, -1)
        S[start] = 0
        frontier = Queue{CartesianIndex{2}}()
        enqueue!(frontier, start)
        while true
            current = dequeue!(frontier)
            finish_cond(current) && (return S[current])
            @nexprs 4 i -> begin
                n = current + directions[i]
                if valid_neighbour(A, current, n)
                    steps = S[current] + 1
                    if (S[n] == -1) || (steps < S[n])
                        S[n] = steps
                        enqueue!(frontier, n)
                    end
                end
            end
        end
    end
end

function solve_p1()
    A, start, finish = inputs()
    search(A, start, valid_neighbour_fwd, x -> (x == finish))
end

solve_p1() |> println

# part 2: BFS
function solve_p2()
    A, _, finish = inputs()
    search(A, finish, valid_neighbour_bwd, x -> (A[x] == 0))
end
solve_p2() |> println
