# Part 1 --------------------

using Pipe

const ROCK = 0
const PAPER = 1
const SCISSORS = 2

struct Round
    enemy_play::Int64
    own_play::Int64
end

function score_outcome(r::Round)
    diff = (r.own_play - r.enemy_play + 3) % 3
    new_diff = (diff + 1) % 3
    new_diff * 3
end

score_shape(r::Round) = r.own_play + 1
score(r::Round) = score_shape(r) + score_outcome(r)

r = Round(PAPER, SCISSORS)
@assert score(r) == 9

const d_enemy = Dict('A' => ROCK, 'B' => PAPER, 'C' => SCISSORS)
const d_player = Dict('X' => ROCK, 'Y' => PAPER, 'Z' => SCISSORS)
line_to_round(line) = Round(d_enemy[line[1]], d_player[line[3]])

sample = """A Y
B X
C Z"""

sample_rounds = split(sample, '\n') .|> line_to_round
@assert score.(sample_rounds) == [8, 1, 6]

rounds = (@pipe readchomp("src/inputs/day2.txt") |> split(_, '\n')) .|> line_to_round
sum(score.(rounds))

# Part #2 --------------------
const LOSE = -1
const DRAW = 0
const WIN = 1
const d_outcome = Dict('X' => LOSE, 'Y' => DRAW, 'Z' => WIN)

function line_to_round_p2(line)
    enemy_play = d_enemy[line[1]]
    own_play = (enemy_play + d_outcome[line[3]] + 3) % 3
    Round(enemy_play, own_play)
end

rounds = (@pipe readchomp("src/inputs/day2.txt") |> split(_, '\n')) .|> line_to_round_p2
sum(score.(rounds))