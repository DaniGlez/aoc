using Pipe, StaticArrays, Accessors
const CI₃ = CartesianIndex{3}
const neighbour_offsets = (
    CI₃(-1, 0, 0),
    CI₃(1, 0, 0),
    CI₃(0, 1, 0),
    CI₃(0, -1, 0),
    CI₃(0, 0, 1),
    CI₃(0, 0, -1),
)
const origin = CI₃(1, 1, 1)

parse_line(line) = @pipe split(strip(line), ',') .|> parse(Int64, _) |> CI₃(_...)

function parse_cubes(fpath="src/inputs/day18.txt")
    shape = (1, 1, 1)
    cubes = CI₃[] # 
    for line ∈ eachline(fpath)
        cube = parse_line(line)
        push!(cubes, cube)
        for i ∈ 1:3
            shape = @set shape[i] = maximum((shape[i], cube.I[i] + 1))
        end
    end
    cubes, shape
end

function form_cube_matrix(cubes, shape)
    A = zeros(Bool, shape)
    faces = 0
    for cube ∈ cubes
        faces += 6
        for Δc ∈ neighbour_offsets
            nb = origin + cube + Δc
            checkbounds(Bool, A, nb) && A[nb] && (faces -= 2)
        end
        A[origin+cube] = true
    end
    A, faces
end

solve_p1(cubes, shape) = form_cube_matrix(cubes, shape)[2]

@pipe parse_cubes() |> solve_p1(_...) |> println

# Part2 
const UNKNOWN = 0
const LAVA = 1
const OUTSIDE = 2
const FRONTIER = 3

function expand_matrix(A0)
    new_shape = Tuple(s + 2 for s ∈ size(A0))
    A = zeros(Int8, new_shape)
    r = i -> 2:(new_shape[i]-1)
    A[r(1), r(2), r(3)] .= A0
    A
end

using DataStructures
function solve_p2(cubes, old_shape)
    A0, _ = form_cube_matrix(cubes, old_shape)
    A = expand_matrix(A0)
    A[1, 1, 1] = FRONTIER
    frontier = Stack{CI₃}()
    exposed_faces = 0
    push!(frontier, CI₃(1, 1, 1))
    while !isempty(frontier)
        cur = pop!(frontier)
        for Δ ∈ neighbour_offsets
            nb = cur + Δ
            checkbounds(Bool, A, nb) || continue
            if A[nb] == UNKNOWN
                A[nb] = FRONTIER
                push!(frontier, nb)
            elseif A[nb] == LAVA
                exposed_faces += 1
            end
            A[cur] = OUTSIDE
        end
    end
    exposed_faces
end

@pipe parse_cubes() |> solve_p2(_...) |> println
