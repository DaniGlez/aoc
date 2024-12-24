@enum OP AND OR XOR

struct Gate
    inp::NTuple{2,Symbol}
    out::Symbol
    op::OP
end

function Gate(gate::AbstractString)
    parts = split(gate, " ")
    op = parts[2] == "AND" ? AND : parts[2] == "OR" ? OR : XOR
    return Gate((Symbol(parts[1]), Symbol(parts[3])), Symbol(parts[5]), op)
end

function (g::Gate)(wires::AbstractDict)
    a, b = wires[g.inp[1]], wires[g.inp[2]]
    return g.op == AND ? a & b : g.op == OR ? a | b : a ⊻ b
end

function parse_input(filename="2024/inputs/day24.txt")
    chunks = split(read(filename, String), "\n\n")
    wires = Dict(
        Symbol(wire) => parse(Bool, value) for (wire, value) in map(s -> split(s, ": "), split(chunks[1], '\n'))
    )
    gates = Gate.(split(chunks[2], '\n'))
    return wires, gates
end

parse_input()

simulate(wg) = simulate(wg...)
simulate(wires, gates) = simulate!(copy(wires), copy(gates))

function simulate!(wires, gates)
    while !isempty(gates)
        for (i, gate) ∈ enumerate(gates)
            if all(haskey(wires, inp) for inp ∈ gate.inp)
                wires[gate.out] = gate(wires)
                deleteat!(gates, i)
            end
        end
    end
    return wires
end

reg_code(r, n) = Symbol(n < 10 ? "$(r)0$n" : "$r$n")

function z_value(wires)
    n = 0
    for b ∈ 0:45
        zreg = b < 10 ? "z0$b" : "z$b"
        n += wires[Symbol(zreg)] << b
    end
    return n
end


parse_input() |> simulate |> z_value

# Unedited random shit for p2, solved with pen, paper, Ctrl+F, and inspecting output

wires, gates = parse_input()
for g ∈ gates
    for n in 0:44
        if g.inp ∈ (
            (reg_code('x', n), reg_code('y', n)),
            (reg_code('y', n), reg_code('x', n)),
        ) && g.op == XOR
            occ = eachmatch(Regex("$(g.out)"), input_txt) |> collect |> length
            println("$(g.out) $occ")
            for line ∈ split(input_txt, '\n')
                if occursin("$(g.out)", line) && !endswith(line, " -> $(g.out)")
                    println(line)
                end
            end
        end
    end
end

for g ∈ gates
    if g.op == AND
        out = "$(g.out)"
        occ = eachmatch(Regex(out), input_txt) |> collect |> length
        println("$(g.out) $occ")
        for line ∈ split(input_txt, '\n')
            if occursin("$(g.out)", line) && !endswith(line, " -> $(g.out)")
                println(line)
            end
        end
    end
end


input_txt = """x01 XOR y01 -> fht
cpg OR qrh -> wtp
wtk XOR thb -> z30
mrj OR cbd -> bjr
y12 XOR x12 -> kng
hrh AND chp -> bgc
qkp XOR ggh -> z36
x24 XOR y24 -> mqt
jbp AND qsw -> dhs
kng XOR jqh -> z12
x21 XOR y21 -> rvk
qqd AND hfb -> qmd
ggh AND qkp -> svm
y26 AND x26 -> bch
mms AND qsf -> cvm
kdt AND rqf -> mrj
jrg OR kqm -> ngk
y43 XOR x43 -> fns
x10 XOR y10 -> jkn
hjc XOR cgv -> z09
swm OR wjb -> cgv
y17 AND x17 -> fvk
qsw XOR jbp -> z44
y01 AND x01 -> dmk
y29 XOR x29 -> gnj
x32 XOR y32 -> qqd
x25 XOR y25 -> cbd
y23 AND x23 -> bvb
dvj AND bjg -> djv
dbv XOR bcm -> z03
x02 XOR y02 -> qdt
qqv OR qkh -> nqr
tmh AND bjr -> cjf
knp XOR nvr -> z08
rmc XOR hdk -> z42
y07 XOR x07 -> mms
nqr AND jtk -> jgf
y18 AND x18 -> qdp
x31 AND y31 -> cbh
x06 AND y06 -> z06
wwt OR rjp -> bkk
y17 XOR x17 -> ptj
y14 XOR x14 -> fgr
y11 XOR x11 -> tsh
fhk XOR bkq -> z28
kkg AND nwg -> jpt
y03 AND x03 -> qkh
tmh XOR bjr -> z26
rkw OR pww -> kdt
tfn AND qgq -> jgt
nrs XOR qdt -> z02
kgw OR rds -> bjg
fcb OR hnr -> jbp
y38 AND x38 -> cpg
rqf XOR kdt -> z25
y12 AND x12 -> fcd
pnh XOR jsp -> z27
hfb XOR qqd -> z32
ftc OR fjm -> bkq
y05 XOR x05 -> pvt
cjt XOR sfm -> jmq
x27 XOR y27 -> jsp
rrt AND cjs -> nsb
hjc AND cgv -> dfj
x34 AND y34 -> qtd
x00 AND y00 -> nqp
qvh AND cgj -> mmm
x21 AND y21 -> vfv
gts XOR cvg -> z16
x38 XOR y38 -> njc
pbb OR mkc -> bcm
hct OR hmc -> wbt
rvk XOR jgk -> z21
cjt AND sfm -> fmd
svm OR bbb -> nsf
dmk OR ntf -> nrs
y44 XOR x44 -> qsw
x36 XOR y36 -> qkp
x27 AND y27 -> ftc
gbd OR fjv -> z13
nmh OR nsb -> jgk
rjj OR fvk -> nwg
qqj OR vwp -> pqg
x04 AND y04 -> bwb
mqt AND ssw -> rkw
y30 XOR x30 -> thb
bdc AND pvt -> chv
wrj AND njp -> kqf
jtk XOR nqr -> z04
gqf OR qtd -> njp
njc AND ngk -> z38
x39 AND y39 -> rds
x10 AND y10 -> hct
hch AND dmm -> bhs
dvj XOR bjg -> z40
y24 AND x24 -> pww
y03 XOR x03 -> dbv
y28 XOR x28 -> fhk
nmm XOR kwb -> gmh
vfv OR qpp -> pjk
gvt AND qpm -> rbf
rrt XOR cjs -> z20
pvt XOR bdc -> z05
y31 XOR x31 -> hrh
y40 XOR x40 -> dvj
y28 AND x28 -> ghp
y22 AND x22 -> stn
nwg XOR kkg -> z18
ptw AND pjk -> cpb
cbh OR bgc -> hfb
x18 XOR y18 -> kkg
x35 XOR y35 -> wrj
vmr OR mwp -> srh
tsh AND wbt -> dwn
mpv XOR wtp -> z39
y34 XOR x34 -> hvf
y19 AND x19 -> gqg
fcd OR bnt -> kwb
hdk AND rmc -> vwp
nbk OR knk -> chp
x30 AND y30 -> nbk
qmn OR kqf -> ggh
gts AND cvg -> mwp
tfn XOR qgq -> z19
x33 AND y33 -> rjp
nrs AND qdt -> mkc
y36 AND x36 -> bbb
wbt XOR tsh -> z11
kjv OR dfj -> whc
mvf OR mmm -> rmc
pnh AND jsp -> fjm
x11 AND y11 -> mfr
cvm OR sbj -> knp
jgt OR gqg -> cjs
x08 XOR y08 -> nvr
y39 XOR x39 -> mpv
tmm AND wqn -> wwt
qmd OR wtb -> tmm
fgr AND gmh -> ckd
wrj XOR njp -> z35
wdq OR hrf -> wtk
y42 XOR x42 -> hdk
jqh AND kng -> bnt
bvb OR rbf -> ssw
cgj XOR qvh -> z41
x13 XOR y13 -> nmm
ptj AND srh -> rjj
x13 AND y13 -> fjv
x43 AND y43 -> hnr
hvf XOR bkk -> z34
x15 XOR y15 -> hch
y14 AND x14 -> cqb
fmd OR jmq -> qsf
ngk XOR njc -> qrh
x41 XOR y41 -> cgj
x07 AND y07 -> sbj
nmm AND kwb -> gbd
gmh XOR fgr -> z14
gnj XOR bcv -> z29
y32 AND x32 -> wtb
x08 AND y08 -> swm
y29 AND x29 -> wdq
pqg XOR fns -> z43
ndr AND nsf -> jrg
bcm AND dbv -> qqv
jgk AND rvk -> qpp
gvt XOR qpm -> z23
x22 XOR y22 -> ptw
y02 AND x02 -> pbb
jpt OR qdp -> qgq
nsf XOR ndr -> z37
bhs OR msb -> cvg
y09 AND x09 -> kjv
dwn OR mfr -> jqh
x35 AND y35 -> qmn
jgf OR bwb -> bdc
y09 XOR x09 -> hjc
pjk XOR ptw -> z22
x19 XOR y19 -> tfn
bcv AND gnj -> hrf
x16 AND y16 -> vmr
srh XOR ptj -> z17
y40 AND x40 -> wgw
x04 XOR y04 -> jtk
jkn AND whc -> hmc
chp XOR hrh -> z31
cpb OR stn -> qpm
y42 AND x42 -> qqj
fhk AND bkq -> mtn
y37 XOR x37 -> ndr
fht XOR nqp -> z01
x25 AND y25 -> rqf
fns AND pqg -> fcb
tmm XOR wqn -> z33
cjf OR bch -> pnh
x23 XOR y23 -> gvt
mms XOR qsf -> z07
hvf AND bkk -> gqf
x33 XOR y33 -> wqn
y37 AND x37 -> kqm
y15 AND x15 -> msb
x20 AND y20 -> nmh
wtk AND thb -> knk
mtn OR ghp -> bcv
wvm OR dhs -> z45
wgw OR djv -> qvh
ckd OR cqb -> dmm
x41 AND y41 -> mvf
y05 AND x05 -> smt
hch XOR dmm -> z15
y44 AND x44 -> wvm
smt OR chv -> cjt
knp AND nvr -> wjb
x06 XOR y06 -> sfm
x26 XOR y26 -> tmh
wtp AND mpv -> kgw
y20 XOR x20 -> rrt
ssw XOR mqt -> z24
nqp AND fht -> ntf
y00 XOR x00 -> z00
jkn XOR whc -> z10
y16 XOR x16 -> gts"""