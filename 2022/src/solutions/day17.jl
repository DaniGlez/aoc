const CI = CartesianIndex{2}

abstract type Piece end

struct HBar <: Piece end
struct Cross <: Piece end
struct ReverseL <: Piece end
struct VBar <: Piece end
struct Square <: Piece end

height(::HBar) = 1
height(::Cross) = 3
height(::ReverseL) = 3
height(::VBar) = 4
height(::Square) = 2

width(::HBar) = 4
width(::Cross) = 3
width(::ReverseL) = 3
width(::VBar) = 1
width(::Square) = 2

sprite(::HBar) = (CI(0, 0), CI(1, 0), CI(2, 0), CI(3, 0))
sprite(::Cross) = (CI(1, 1), CI(1, 0), CI(0, 1), CI(1, 2), CI(2, 1))
sprite(::ReverseL) = (CI(0, 0), CI(1, 0), CI(2, 0), CI(2, 1), CI(2, 2))
sprite(::VBar) = (CI(0, 0), CI(0, 1), CI(0, 2), CI(0, 3))
sprite(::Square) = (CI(0, 0), CI(0, 1), CI(1, 0), CI(1, 1))

const piece_list = (HBar(), Cross(), ReverseL(), VBar(), Square())
const left = CI(-1, 0)
const right = CI(1, 0)
const down = CI(0, -1)
x_pos(ci::CI) = ci.I[1]
y_pos(ci::CI) = ci.I[2]

function hclamp(p::Piece, coords)
    coords = (x_pos(coords) < 1) ? coords + right : coords
    coords = (x_pos(coords) + width(p) > 8) ? coords + left : coords
    coords
end

mutable struct CanvasState{N}
    grid::Matrix{Bool}
    jets::Vector{CI}
    jet_index::Int64
    highest_position::Int64
    offset::Int64
end
Base.getindex(canvas::CanvasState, coords) = canvas.grid[coords+CI(0, -canvas.offset)]
function Base.setindex!(canvas::CanvasState, val, coords)
    canvas.grid[coords+CI(0, -canvas.offset)] = val
end
CanvasState(jets) = CanvasState{length(jets)}(zeros(7, 2022 * 4), jets, 1, 0, 0)
function pop!(canvas::CanvasState{N}) where {N}
    j = canvas.jet_index
    jet = canvas.jets[j]
    canvas.jet_index = mod1(j + 1, N)
    jet
end

function collides(cv::CanvasState, piece::Piece, coords::CI)
    (y_pos(coords) > 0) || return true
    for rpos ∈ sprite(piece)
        (cv[coords+rpos]) && return true
    end
    false
end

function put_piece!(canvas::CanvasState{N}, piece::Piece) where {N}
    xy = CI(3, canvas.highest_position + 4)
    while true
        jet = pop!(canvas)
        move = hclamp(piece, xy + jet)
        collides(canvas, piece, move) ? nothing : (xy = move)
        move = xy + down
        collides(canvas, piece, move) ? break : (xy = move)
    end
    for rpos ∈ sprite(piece)
        canvas[xy+rpos] = true
        piece_top = y_pos(xy) + height(piece) - 1
        canvas.highest_position = maximum((canvas.highest_position, piece_top))
    end
end

char2dir(c) = (c == '<') ? left : right
parse_jets(fpath="src/inputs/day17.txt") = readchomp(fpath) |> collect .|> char2dir

function plot_bot(canvas::CanvasState, n)
    for col ∈ eachcol(canvas.grid[:, n:-1:1])
        for c ∈ col
            c ? print('@') : print('.')
        end
        print('\n')
    end
end

function solve_p1(jets)
    canvas = CanvasState(jets)
    for i ∈ 1:2022
        piece = piece_list[mod1(i, 5)]
        put_piece!(canvas, piece)
    end
    plot_bot(canvas, 100)
    canvas.highest_position
end

parse_jets() |> solve_p1 |> println

# ------------ Part 2 ---------------

function shift_canvas!(canvas::CanvasState, shift)
    h = canvas.highest_position - canvas.offset
    grd = copy(canvas.grid)
    fill!(canvas.grid, false)
    canvas.grid[:, 1:(h-shift)] .= grd[:, (shift+1):h]
    canvas.offset += shift
end

using StaticArrays
vbool2int(v) = evalpoly(2, reverse(v))
function encode_frontier_shape(canvas, ::Val{N}) where {N} # N = number of 64-row chunks
    signature = @MVector zeros(Int64, N * 7)
    for i ∈ 0:(N-1)
        for j ∈ 1:7
            h = canvas.highest_position - canvas.offset - 64 * i
            l = h - 64 * (i + 1)
            v = canvas.grid[j, l:h]
            signature[7i+j] = vbool2int(v)
        end
    end
    SVector(signature)
end

function run_supercycle!(canvas, n)
    for i ∈ 1:n
        piece = piece_list[mod1(i, 5)]
        put_piece!(canvas, piece)
        if canvas.highest_position - canvas.offset > 2000
            shift_canvas!(canvas, 500)
        end
    end
end

function solve_p2(jets, ::Val{N}) where {N}
    sc_length = (5 * length(jets))
    canvas = CanvasState(jets)
    d_heights = Dict{Int64,Int64}()
    signatures = Dict{Int64,SVector{N * 7,Int64}}()
    rsignatures = Dict{SVector{N * 7,Int64},Int64}()
    i = 0
    while true
        run_supercycle!(canvas, sc_length)
        i += 1
        d_heights[i] = canvas.highest_position
        signature = encode_frontier_shape(canvas, Val(N))
        if signature ∈ values(signatures)
            signatures[i] = signature
            break
        else
            signatures[i] = signature
            rsignatures[signature] = i
        end
    end
    signature = signatures[i]
    i0 = rsignatures[signature]
    Δi = i - i0
    Δh = canvas.highest_position - d_heights[i0]
    Δp = sc_length * Δi
    total_pieces = 1_000_000_000_000
    supercycles_remaining = (total_pieces - sc_length * i) ÷ Δp
    pieces_remaining = (total_pieces - sc_length * i) % Δp
    run_supercycle!(canvas, pieces_remaining)
    canvas.highest_position + supercycles_remaining * Δh
end

solve_p2(jets) = solve_p2(jets, Val(1))

parse_jets() |> solve_p2 |> println
