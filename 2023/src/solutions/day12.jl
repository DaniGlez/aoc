parse_line(line) = split(line, ' ') |> parse_record
parse_record(record) = record[1], parse.(Int64, split(record[2], ','))
find_combinations(record) = find_combinations(record...)

function find_combinations(springs, group_sizes)
    length(group_sizes) == 0 && return ('#' ∈ springs) ? 0 : 1
    sum(group_sizes) + length(group_sizes) - 1 > length(springs) && return 0
    startswith(springs, '.') && return find_combinations(springs[2:end], group_sizes)
    if startswith(springs, '#')
        i1 = group_sizes[1]
        '.' ∈ springs[1:i1] && return 0
        length(springs) > i1 && springs[i1+1] == '#' && return 0
        group_sizes[1] == 1 && return find_combinations(springs[3:end], group_sizes[2:end])
        return find_combinations(springs[i1+2:end], group_sizes[2:end])
    end
    endswith(springs, '?') || return find_combinations(reverse(springs), reverse(group_sizes))
    idx = findfirst('.', springs)
    isnothing(idx) && return find_combinations_no_undamaged(springs, group_sizes)
    s1 = springs[1:idx-1]
    s2 = springs[idx+1:end]
    total_ways = 0

    for cut ∈ 1:(length(group_sizes)+1)
        gs1, gs2 = group_sizes[1:cut-1], group_sizes[cut:end]
        sum(gs1) + length(gs1) - 1 > length(s1) && continue
        sum(gs2) + length(gs2) - 1 > length(s2) && continue
        total_ways += find_combinations(s1, gs1) * find_combinations(s2, gs2)
    end
    total_ways
end

function find_combinations_no_undamaged(springs, group_sizes)
    length(group_sizes) > 0 || return ('#' ∈ springs) ? 0 : 1
    length(group_sizes) == 1 && group_sizes[1] == length(springs) && return 1
    necessary_length = sum(group_sizes) + length(group_sizes) - 1
    l = length(springs)
    necessary_length > l && return 0
    if startswith(springs, '#')
        springs[group_sizes[1]+1] == '?' || return 0
        return find_combinations_no_undamaged(springs[group_sizes[1]+2:end], group_sizes[2:end])
    end
    endswith(springs, '#') && return find_combinations_no_undamaged(reverse(springs), reverse(group_sizes))
    if '#' ∉ springs
        necessary_length == l && return 1
        return binomial(length(springs) - sum(group_sizes) + 1, length(group_sizes))
    end
    total_ways = 0
    # Using findfirst instead of the ~halving heuristic leads to getting rekt by 2-3 inputs
    idxs = findall('#', springs)
    idx = argmin(idx -> (idx - (length(springs) >> 1))^2, idxs)
    s1 = springs[1:idx]
    s2 = springs[idx:end]
    for i ∈ eachindex(group_sizes)
        # Assume the first # is in group i, position j
        n = group_sizes[i]
        for j ∈ 1:n
            s1_re = s1[1:end-j] * '#'^j
            s2_re = '#'^(n - j + 1) * s2[n-j+2:end]
            length(s1_re) == length(s1) || continue
            length(s2_re) == length(s2) || continue
            gs1 = [group_sizes[1:i-1]..., j]
            gs2 = [n - j + 1, group_sizes[i+1:end]...]
            comb1 = find_combinations_no_undamaged(s1_re, gs1)
            comb2 = find_combinations_no_undamaged(s2_re, gs2)
            total_ways += comb1 * comb2
        end
    end
    total_ways
end

find_combinations.(eachline("2023/inputs/input12.txt") .|> parse_line)
sum(find_combinations, eachline("2023/inputs/input12.txt") .|> parse_line)

# ------ Part 2 ------
unfold_record(springs, groups) = join(map(_ -> springs, 1:5), '?'), repeat(groups, 5)
unfold_record(record) = unfold_record(record...)
sum(find_combinations ∘ unfold_record, eachline("2023/inputs/input12.txt") .|> parse_line)

