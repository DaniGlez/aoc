using Memoize

function parse_input(filename="2024/inputs/day19.txt")
    chunks = split(read(filename, String), "\n\n")
    patterns = split(chunks[1], ", ")
    designs = split(chunks[2], '\n')
    patterns, designs
end

parse_input()

function is_possible(patterns, design)
    length(design) == 0 && return true
    any(patterns) do pattern
        startswith(design, pattern) ? is_possible(patterns, design[length(pattern)+1:end]) : false
    end
end

begin
    patterns, designs = parse_input()
    count(designs) do design
        is_possible(patterns, design)
    end |> println
end

@memoize function count_designs(patterns, design)
    length(design) == 0 && return 1
    sum(patterns) do pattern
        startswith(design, pattern) ? count_designs(patterns, design[length(pattern)+1:end]) : 0
    end
end

begin
    patterns, designs = parse_input()
    sum(designs) do design
        count_designs(patterns, design)
    end |> println
end