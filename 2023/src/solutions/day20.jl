using DataStructures

const HIGH = true
const LOW = false
const ON = true
const OFF = false

parse_input(path="2023/inputs/input20.txt") =
    map(eachline(path)) do line
        pre, post = split(line, "->")
        strip(pre) => split(strip(post), ", ")
    end |> Dict

struct FlipFlop
    on_off::Ref{Bool}
    outputs::Vector{Symbol}
end

FlipFlop(outputs) = FlipFlop(Ref(false), Symbol.(outputs))

struct Conjunction
    last_pulse_inputs::Dict{Symbol,Bool}
    outputs::Vector{Symbol}
end

Conjunction(input_ids::Vector, outputs) = Conjunction(
    Dict(Symbol(id) => LOW for id ∈ input_ids), Symbol.(outputs)
)
module_id(str) = str == "broadcaster" ? :broadcaster : Symbol(chop(str; tail=0, head=1))

function modules_which_have_the_given_id_as_output(lines, id)
    inputs = Symbol[]
    for (key, outputs) ∈ lines
        id ∈ Symbol.(outputs) && push!(inputs, module_id(key))
    end
    inputs
end

function build_machine(lines)
    broadcaster = Symbol[]
    modules = Dict{Symbol,Union{FlipFlop,Conjunction}}()
    for (k, v) ∈ lines
        id = module_id(k)
        if k == "broadcaster"
            append!(broadcaster, Symbol.(v))
        elseif startswith(k, '%')
            modules[id] = FlipFlop(v)
        elseif startswith(k, '&')
            inputs = modules_which_have_the_given_id_as_output(lines, id)
            modules[id] = Conjunction(inputs, v)
        end
    end
    modules[:output] = FlipFlop(Symbol[])
    broadcaster, modules
end

struct Pulse
    source_id::Symbol
    destination_id::Symbol
    signal::Bool
end
Base.show(io::IO, p::Pulse) = Base.show(io, """$(p.source_id) -$(p.signal ? "high" : "low")-> $(p.destination_id)""")

is_high(p::Pulse) = p.signal

send!(modules, pulse) = send!(modules[pulse.destination_id], pulse)

send_to_all_outputs(md, source, signal) = [Pulse(source, out, signal) for out ∈ md.outputs]

function send!(ff::FlipFlop, pulse)
    pulse.signal == HIGH && return Pulse[]
    ff.on_off[] = !ff.on_off[]
    send_to_all_outputs(ff, pulse.destination_id, ff.on_off[])
end

function send!(cm::Conjunction, pulse)
    cm.last_pulse_inputs[pulse.source_id] = pulse.signal
    signal = !all(==(HIGH), values(cm.last_pulse_inputs))
    send_to_all_outputs(cm, pulse.destination_id, signal)
end

function push_the_button!(broadcaster, modules)
    q = Queue{Pulse}()
    for id ∈ broadcaster
        enqueue!(q, Pulse(:broadcaster, Symbol(id), LOW))
    end
    h, l = 0, length(broadcaster) + 1 # button-to-broadcaster
    while !isempty(q)
        pulse = dequeue!(q)
        pulse.destination_id ∈ keys(modules) || continue
        next_pulses = send!(modules, pulse)
        h += count(is_high, next_pulses)
        l += count(!is_high, next_pulses)
        map(p -> enqueue!(q, p), next_pulses)
    end
    h, l
end

function solve_p1(inputs)
    broadcaster, modules = build_machine(inputs)
    hl = [0, 0]
    for _ ∈ 1:1_000
        hl .+= push_the_button!(broadcaster, modules)
    end
    prod(hl)
end

parse_input() |> solve_p1 |> println

# ------ Part 2 ------