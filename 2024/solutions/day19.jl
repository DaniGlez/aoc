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

# Bonus - no @memoize, low allocations

function count_designs_alt(patterns, design)
    length(design) == 0 && return 1
    length(design) == 1 && return design ∈ patterns
    midpoint = length(design) ÷ 2
    before = @view design[1:midpoint]
    after = @view design[midpoint+1:end]
    c = count_designs_alt(patterns, before) *
        count_designs_alt(patterns, after)
    @views for pattern ∈ patterns
        l = length(pattern)
        l == 1 && continue
        for n_before ∈ 1:(l-1)
            n_after = l - n_before
            p_before, p_after = pattern[1:n_before], pattern[n_before+1:end]
            if endswith(before, p_before) && startswith(after, p_after)
                c += count_designs_alt(patterns, before[1:end-n_before]) *
                     count_designs_alt(patterns, after[n_after+1:end])
            end
        end
    end
    c
end

begin
    patterns, designs = parse_input()
    @b sum(designs) do design
        count_designs_alt(patterns, design)
    end |> println
end
