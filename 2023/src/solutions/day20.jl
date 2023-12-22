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
    last_pulse_inputs::OrderedDict{Symbol,Bool}
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

current_signal(cm::Conjunction) = !all(==(HIGH), values(cm.last_pulse_inputs))

function send!(cm::Conjunction, pulse)
    cm.last_pulse_inputs[pulse.source_id] = pulse.signal
    send_to_all_outputs(cm, pulse.destination_id, current_signal(cm))
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

bits(::FlipFlop) = 1
bits(c::Conjunction) = length(c.last_pulse_inputs)
max_state_size(modules_dict) = 2^sum(bits, values(modules_dict))

struct SubMachine # gun 
    input::Symbol
    output::Symbol
    state_indexes::Vector{Tuple{Symbol,UnitRange{Int64}}}
    modules::Dict{Symbol,Union{FlipFlop,Conjunction}}
end

function SubMachine(modules::Dict, input::Symbol, key_set::Set{Symbol}, output_nodes)
    submodules = pairs(modules) |> filter(kv -> kv.first ∈ key_set) |> Dict
    output = keys(submodules) |> filter(in(output_nodes)) |> first
    module_keys = Tuple(keys(submodules))
    end_indices = cumsum(map(k -> bits(submodules[k]), module_keys))
    start_indices = (1, (end_indices[1:end-1] .+ 1)...)
    indices = [a:b for (a, b) ∈ zip(start_indices, end_indices)]
    SubMachine(input, output, collect(zip(module_keys, indices)), submodules)
end

bits_required(sm) = sm.state_indexes[end][2].stop
encode_state(ff::FlipFlop) = BitVector([ff.on_off[]])
encode_state(c::Conjunction) = BitVector(values(c.last_pulse_inputs))

function bitvec2int(bv)
    n = length(bv)
    sum(((i, v),) -> v ? 2^(n - i) : 0, enumerate(bv))
end

function encode_state(sm::SubMachine)
    v = BitVector(undef, bits_required(sm))
    for (k, st_idx) ∈ sm.state_indexes
        v[st_idx] = encode_state(sm.modules[k])
    end
    bitvec2int(v)
end

function expand_set!(idset, modules, x, outputs)
    for y ∈ modules[x].outputs
        y ∈ idset && continue
        push!(idset, y)
        y ∈ outputs && continue
        expand_set!(idset, modules, y, outputs)
    end
end

split_machine(inputs) = split_machine(inputs...)
function split_machine(broadcaster, modules)
    rx_predecessors = modules |> pairs |> filter(kv -> :rx ∈ kv.second.outputs)
    length(rx_predecessors) == 1 || error("Expected only one node connected to the output")
    rx_predecessor = first(rx_predecessors)
    output_nodes = keys(rx_predecessor.second.last_pulse_inputs)
    submachines = map(broadcaster) do md_input
        key_set = Set((md_input,))
        expand_set!(key_set, modules, md_input, output_nodes)
        SubMachine(modules, md_input, key_set, output_nodes)
    end
    submachines
end

struct Cycle
    time_to_target::Int64
    period::Int64
end

function push_the_button!(submachine::SubMachine)
    q = Queue{Pulse}()
    enqueue!(q, Pulse(:broadcaster, submachine.input, LOW))
    output_rises = false
    while !isempty(q)
        pulse = dequeue!(q)
        pulse.destination_id ∈ keys(submachine.modules) || continue
        next_pulses = send!(submachine.modules, pulse)
        map(p -> enqueue!(q, p), next_pulses)
        current_signal(submachine.modules[submachine.output]) && (output_rises = true)
    end
    output_rises
end

function find_cycle(submachine::SubMachine)
    n_bits = bits_required(submachine)
    N = 2^n_bits
    state_history = Vector{UInt32}()
    state_occurrence = zeros(UInt32, N)
    sizehint!(state_history, N)
    i = 0
    while true
        i += 1
        push_the_button!(submachine)
        state = encode_state(submachine)
        push!(state_history, state)
        if state_occurrence[state] == 0
            state_occurrence[state] = i
        else
            j = state_occurrence[state]
            return Cycle(j, i - j)
        end
    end
end

shift_to_high_output(t::Tuple) = shift_to_high_output(t...)
shift_to_high_output(cycle, presses_to_high) = Cycle(presses_to_high[2], cycle.period)

function solve_p2(inputs)
    cycles = inputs |> build_machine |> split_machine .|> find_cycle .|> c -> c.period
    lcm(cycles...)
end

parse_input() |> solve_p2

