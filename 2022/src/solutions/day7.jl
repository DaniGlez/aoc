using Pipe

abstract type Command end
abstract type CDCommand <: Command end

struct CDRoot <: CDCommand end
struct CDParent <: CDCommand end
struct CD <: CDCommand
    target::String
end

struct LS <: Command end

struct File
    name::String
    ext::String
    size::Int64
end

mutable struct Folder
    name::String
    parent::Union{Nothing,Ref{Folder}}
    children::Array{Folder}
    files::Array{File}
    size::Int64
end

Folder(name::AbstractString, parent) = Folder(name, parent, [], [], 0)
Root() = Folder("", nothing)
name(f::Folder) = f.name
names(arr::Array{Folder}) = name.(arr)
names(arr::Array{File}) = name.(arr)
name(f::File) = "$(f.name).$(f.ext)"

function fsizearr(arr)
    isempty(arr) && return 0
    fsize.(arr) |> sum
end
fsize(f::File) = f.size
fsize(arr::Array{File}) = fsizearr(arr)
fsize(arr::Array{Folder}) = fsizearr(arr)
fsize(f) = fsize(f.children) + fsize(f.files)
function fsize!(f::Folder)
    f.size = sum(fsize!.(f.children)) + fsize(f.files)
    f.size
end

function parse_cd(ss)
    @assert ss[1] == ' '
    s = ss[2:end]
    (s == "..") && (return CDParent())
    (s == "/") && (return CDRoot())
    CD(s)
end

function parse_cmd(line)
    line = strip(line)
    cmd = line[1:2]
    (cmd == "cd") && return parse_cd(line[3:end])
    (line == "ls") && return LS()
    error("Unrecognized command: $(cmd)")
end

function proc_cmd!(root, cursor, cd::CDCommand, output)
    @assert isempty(output)
    proc_cd(root, cursor, cd)
end
proc_cd(root, cursor, ::CDRoot) = Ref(root)
proc_cd(root, cursor, ::CDParent) = cursor[].parent
function proc_cd(root, cursor, cd::CD)
    cwd = cursor[]
    dir_idx = findfirst(c -> (name(c) == cd.target), cwd.children)
    (dir_idx === nothing) && error("Did not find subfolder $(cd.target) in $(cwd)")
    Ref(cwd.children[dir_idx])
end

function proc_cmd!(root, cursor, ::LS, output)
    cwd = cursor[]
    for line ∈ output
        if startswith(line, "dir ")
            name = line[5:end]
            @assert !(name ∈ names(cwd.children)) && !isempty(name)
            push!(cwd.children, Folder(name, cursor))
        else
            re = r"(\d+) ([a-zA-Z]+).([a-zA-Z]+)"
            fsize_str, fname, ext = match(re, line).captures
            name = fname * '.' * ext
            @assert !(name ∈ names(cwd.files))
            push!(cwd.files, File(fname, ext, parse(Int64, fsize_str)))
        end
    end
    cursor
end

function parse_input()
    root = Root()
    cursor = Ref(root)
    chunks = split(readchomp("src/inputs/day7.txt"), "\$ ") .|> chomp
    for chunk ∈ chunks
        isempty(chunk) && continue
        lines = split(chunk, "\n")
        cmd = parse_cmd(lines[1])
        cursor = proc_cmd!(root, cursor, cmd, lines[2:end])
    end
    root
end

root = parse_input();

# part 1
const max_fsize = 100_000
function acc_fsize_p1(f::Folder)
    s = fsize(f)
    (s >= 100_000) && (s = 0)
    isempty(f.children) && (return s)
    s + sum(acc_fsize_p1.(f.children))
end
acc_fsize_p1(root) |> println

# part 2
cur_fsize = fsize!(root)
const total_fsize = 70_000_000
const target_fsize = 70_000_000 - 30_000_000
required_space = cur_fsize - target_fsize

function min_removal_size(f::Folder, req_space)
    own_size = f.size
    if f.size < req_space
        own_size = typemax(Int64)
    end
    isempty(f.children) && (return own_size)
    mrs(c) = min_removal_size(c, req_space)
    children_size = mrs.(f.children) |> minimum
    minimum((own_size, children_size))
end

min_removal_size(root, required_space) |> println

