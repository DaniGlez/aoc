using Accessors

# ------ Parsing & types ------

@enum Effect Accept Reject SendTo Continue

const xmas = (:x, :m, :a, :s)
const WorkflowID = NTuple{3,Char}
const NullID = Tuple("___")
workflow_id(str) = ntuple(i -> i ∈ eachindex(str) ? str[i] : '_', 3)

struct Rule
    attribute::Symbol
    max_val::Int64
    effect::Effect
    send_to::WorkflowID
end

Rule(attr, max_val, effect) = Rule(attr, max_val, effect, NullID)

function parse_part(str)
    chunks = split(chop(str; head=1, tail=1), ',') .|> s -> split(s, '=')
    NamedTuple(Symbol(kv[1]) => parse(Int64, kv[2]) for kv ∈ chunks)
end

function parse_workflow(str)
    wfid_str, rules_str = split(str, '{')
    (workflow_id(wfid_str), split(chop(rules_str), ',') .|> parse_rule)
end

function parse_rule(str)
    ':' ∈ str || return no_cond(str)
    cond_str, eff_str = split(str, ':')
    attribute = Symbol(cond_str[1])
    max_val = parse(Int64, cond_str[3:end]) * (cond_str[2] == '<' ? 1 : -1)
    eff_str == "A" && return Rule(attribute, max_val, Accept)
    eff_str == "R" && return Rule(attribute, max_val, Reject)
    Rule(attribute, max_val, SendTo, workflow_id(eff_str))
end

function no_cond(str)
    str == "A" && return Rule(:x, typemax(Int64), Accept, NullID)
    str == "R" && return Rule(:x, typemax(Int64), Reject, NullID)
    Rule(:x, typemax(Int64), SendTo, workflow_id(str))
end

function load_input(path="2023/inputs/input19.txt")
    chunk_workflows, chunk_parts = split(read(path, String), "\n\n")
    parse_workflow.(split(chunk_workflows, '\n')), parse_part.(split(chunk_parts, '\n'))
end

# ------ Part 1 ------

(r::Rule)(p) = sign(r.max_val) * p[r.attribute] < r.max_val ? r.effect : Continue

solve_p1(input) = solve_p1(input...)

accept(workflows, part) = accept(workflows, part, Tuple("in_"))
function accept(workflows::Dict, part, wfid)
    for rule ∈ workflows[wfid]
        outcome = rule(part)
        outcome == Accept && return true
        outcome == Reject && return false
        outcome == SendTo && return accept(workflows, part, rule.send_to)
    end
end

rating(part) = sum(s -> part[s], xmas)

function solve_p1(workflow_tuples, parts)
    workflows = Dict(workflow_tuples)
    sum(rating, parts |> filter(p -> accept(workflows, p)))
end

load_input() |> solve_p1

# ------ Part 2 ------
# Not sure if all the preprocessing is significantly useful tbh

total_effect(rule) = rule.effect, rule.send_to

function simplify_workflow!(workflow)
    length(workflow) > 1 || return nothing
    if total_effect(workflow[end-1]) == total_effect(workflow[end])
        deleteat!(workflow, eachindex(workflow)[end-1])
    end
end

function inline_workflows!(workflows)
    trivial_workflows = filter(p -> length(p.second) == 1, workflows)
    for k ∈ keys(trivial_workflows)
        k == Tuple("in_") && continue
        delete!(workflows, k)
        for w ∈ values(workflows)
            inline_workflow!(w, k, trivial_workflows[k][1])
        end
    end
end

function inline_workflow!(w, k, v)
    for (i, rule) ∈ enumerate(w)
        if rule.send_to == k
            w[i] = Rule(rule.attribute, rule.max_val, v.effect, v.send_to)
        end
    end
end

total_rules(workflows) = sum(length, values(workflows))

function preprocess_workflows!(workflows::Dict)
    n = total_rules(workflows)
    while true
        simplify_workflow!.(values(workflows))
        inline_workflows!(workflows)
        new_n = total_rules(workflows)
        new_n < n || break
        n = new_n
    end
end

# Actual solution

struct RangeCube
    x::UnitRange{Int64}
    m::UnitRange{Int64}
    a::UnitRange{Int64}
    s::UnitRange{Int64}
end

const NullCube = RangeCube(1:0, 1:0, 1:0, 1:0)

volume(rc) = prod(s -> length(getfield(rc, s)), xmas)
contains_solutions(rc) = volume(rc) > 0
solutions_in_cube(rc) = volume(rc)

function _slice(rc::RangeCube, slicing_dim::Symbol, cutoff, current_dim)
    range = getfield(rc, current_dim)
    current_dim != slicing_dim && return range, range
    range.start:(cutoff-1), cutoff:range.stop
end

function slice(rc::RangeCube, dim::Symbol, cutoff)
    ranges = xmas .|> d -> _slice(rc, dim, cutoff, d)
    (1, 2) .|> i -> RangeCube((r[i] for r in ranges)...)
end

function (r::Rule)(rc::RangeCube)
    range = getfield(rc, r.attribute)
    lt = r.max_val > 0
    cutoff = lt ? r.max_val : -r.max_val + 1
    if cutoff ∈ range
        lower_upper = slice(rc, r.attribute, cutoff)
        return (r.max_val > 0 ? lower_upper : reverse(lower_upper))
    else
        out = rc, NullCube
        cutoff < range.start && (out = reverse(out))
        lt || (out = reverse(out))
        return out
    end
end

solutions_in_cube(workflows, cube) = solutions_in_cube(workflows, cube, Tuple("in_"))

function solutions_in_cube(workflows, cube, wfid)
    contains_solutions(cube) || return 0
    sols = 0
    for rule ∈ workflows[wfid]
        cube_act, cube = rule(cube)
        rule.effect == Accept && (sols += solutions_in_cube(cube_act))
        rule.effect == SendTo && (sols += solutions_in_cube(workflows, cube_act, rule.send_to))
    end
    sols
end

function solve_p2(workflows)
    preprocess_workflows!(workflows)
    solutions_in_cube(workflows, RangeCube(1:4_000, 1:4_000, 1:4_000, 1:4_000))
end

load_input()[1] |> Dict |> solve_p2 |> println