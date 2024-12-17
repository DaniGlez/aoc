using Accessors, Test

function parse_input(filename="2024/inputs/day17.txt")
    text = read(filename, String)
    A, B, C = map(collect("ABC")) do c
        parse(Int64, match(Regex("Register $c: (\\d+)"), text).captures |> only)
    end
    program_txt = split(text, "Program: ") |> last
    (A, B, C), parse.(Int64, split(program_txt, ','))
end

const op_codes = (:adv, :bxl, :bst, :jnz, :bxc, :out, :bdv, :cdv)
struct Instruction{I,O} end

struct Program{L,II}
    instructions::II
    Program{L}(instructions::I) where {L,I<:Tuple} = new{L,I}(instructions)
end

Program(instructions) = Program{length(instructions)}(instructions)

function compile(program)
    instructions = ()
    for (opcode, operand) ∈ zip(program[1:2:end], program[2:2:end])
        instructions = (instructions...,
            Instruction{op_codes[opcode+1],operand}()
        )
    end
    Program(instructions)
end

struct Combo{I} end
(::Combo{I})(_) where {I} = I
(::Combo{4})(ABC) = ABC[1]
(::Combo{5})(ABC) = ABC[2]
(::Combo{6})(ABC) = ABC[3]
(::Combo{7})(_) = error("")

struct Output
    value::Int8
end

const NoOutput = Output(-1)
has_output(out::Output) = out.value >= 0
unwrap(out::Output) = out.value

(inst::Instruction)(ABC, ip) = (inst(ABC)..., ip + 2)

function xdv(ABC, ::Val{O}, ::Val{idx}) where {O,idx}
    (@set ABC[idx] = ABC[1] >> Combo{O}()(ABC)), NoOutput
end

(::Instruction{:adv,O})(ABC) where {O} = xdv(ABC, Val(O), Val(1))
(::Instruction{:bdv,O})(ABC) where {O} = xdv(ABC, Val(O), Val(2))
(::Instruction{:cdv,O})(ABC) where {O} = xdv(ABC, Val(O), Val(3))
(::Instruction{:bxl,O})(ABC) where {O} = (@set ABC[2] = ABC[2] ⊻ O), NoOutput
(::Instruction{:bst,O})(ABC) where {O} = (@set ABC[2] = Combo{O}()(ABC) % 8), NoOutput
(::Instruction{:jnz,O})(ABC, ip) where {O} = (ABC, NoOutput, iszero(ABC[1]) ? ip + 2 : O)
(::Instruction{:bxc})(ABC) = (@set ABC[2] = ABC[2] ⊻ ABC[3]), NoOutput
(::Instruction{:out,O})(ABC) where {O} = ABC, Output(Combo{O}()(ABC) % 8)

@generated function (program::Program{L})(ABC) where {L}
    quote
        ip = 0
        output = Int8[]
        while true
            instruction_idx = ip ÷ 2 + 1
            instruction_idx > L && break
            Base.@nexprs $L i -> begin
                if instruction_idx == i
                    ABC, out, ip = program.instructions[i](ABC, ip)
                    if has_output(out)
                        push!(output, unwrap(out))
                    end
                end
            end
        end
        ABC, output
    end
end

# Part 1 ===============================
begin
    ABC₀, program = parse_input()
    p = compile(program)
    p(ABC₀) |> last
end

# Part 2 ===============================

function remove_corruption(program)
    @assert program[end-1:end] == [3, 0]
    loopbody = compile(program[1:end-2])
    search_digits(0, loopbody, reverse(program))
end

function search_digits(a_next, loopbody, targets, n=0)
    n == length(targets) && return a_next
    for a in 0:7
        A = (a_next << 3) + a
        _, out = loopbody((A, 0, 0))
        if only(out) == targets[n+1]
            A_prev = search_digits(A, loopbody, targets, n + 1)
            !isnothing(A_prev) && return A_prev
            # search order guarantees we don't need to collect solutions & minimize
        end
    end
end

begin
    _, program = parse_input()
    remove_corruption(program) |> println
end