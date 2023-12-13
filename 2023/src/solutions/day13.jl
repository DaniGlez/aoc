process_map(chunk) = stack(split(chunk, "\n") .|> collect, dims=1)
fetch_maps(path="2023/inputs/input13.txt") = read(path, String) |> txt -> split(txt, "\n\n") .|> process_map

function match_mirror(line, mirror)
    w = min(mirror, length(line) - mirror)
    reverse(line[(mirror-w+1):mirror]) == line[(mirror+1):(mirror+w)]
end

function determine_mirrors(M, ::Val{dim}) where {dim}
    l = size(M)[3-dim]
    potential_mirrors = Set(1:l-1)
    for line ∈ eachslice(M; dims=dim)
        for mirror ∈ potential_mirrors
            match_mirror(line, mirror) || delete!(potential_mirrors, mirror)
        end
    end
    length(potential_mirrors) == 1 ? pop!(potential_mirrors) : 0
end

score_map(M) = determine_mirrors(M, Val(1)) + 100determine_mirrors(M, Val(2))
sum(score_map, fetch_maps("2023/inputs/input13.txt")) |> println

# ------ Part 2 ------

smudges_to_match(line1, line2) = count(((c1, c2),) -> c1 != c2, zip(line1, line2))
smudges_to_match(ll) = smudges_to_match(ll...)
total_smudges(lines, idx) = sum(smudges_to_match,
    zip(reverse(lines[1:idx]), lines[idx+1:min(length(lines), 2idx)])
)

function find_smudged_reflection(M, ::Val{dim}) where {dim}
    lines = collect(eachslice(M; dims=3 - dim))
    for i ∈ 1:length(lines)-1
        total_smudges(lines, i) == 1 && return i
    end
    0
end

score_map_2(M) = find_smudged_reflection(M, Val(1)) + 100find_smudged_reflection(M, Val(2))
sum(score_map_2, fetch_maps("2023/inputs/input13.txt")) |> println

