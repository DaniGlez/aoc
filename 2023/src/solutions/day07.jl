@enum HandType begin
    HighCard
    OnePair
    TwoPair
    ThreeOfAKind
    FullHouse
    FourOfAKind
    FiveOfAKind
end

const CARDS = "123456789TJQKA"

function _compute_hand(counts)
    counts[1] == 5 && return FiveOfAKind
    counts[1] == 4 && return FourOfAKind
    counts[1] == 1 && return HighCard
    counts[1] == 3 && return (counts[2] == 2 ? FullHouse : ThreeOfAKind)
    counts[2] == 2 && return TwoPair
    OnePair
end

function compute_hand(cards::NTuple{5,Char})
    c = Tuple(unique(cards) .|> c -> count(==(c), cards)) |> sort |> reverse
    _compute_hand(c)
end

struct Hand
    cards::NTuple{5,Char}
    hand_type::HandType
end

Hand(cards) = Hand(cards, compute_hand(cards))
Base.show(io::IO, p::Hand) = Base.show(io, "$(p.hand_type)[$(join(p.cards))]")

function Base.isless(a::Hand, b::Hand)
    a.hand_type == b.hand_type && return isless_cards(a.cards, b.cards)
    isless(a.hand_type, b.hand_type)
end

function isless_cards(a, b)
    a₁, b₁ = first(a), first(b)
    a₁ == b₁ && return isless_cards(Base.tail(a), Base.tail(b))
    isless(findfirst(a₁, CARDS), findfirst(b₁, CARDS))
end

function fetch_input(path="2023/inputs/input07.txt")
    map(eachline(path)) do line
        cards = Tuple(line[1:5])
        bid = parse(Int64, line[7:end])
        Hand(cards), bid
    end
end

begin
    pairs = fetch_input("2023/inputs/input07.txt")
    sort!(pairs; by=p -> p[1])
    sum(((i, p),) -> i * p[2], enumerate(pairs)) |> println
end

# ------ Part 2 ------

const FIXED_CARDS = "23456789TQKA"

function jokerify(h::Hand)
    @show h
    c = Tuple(
            unique(h.cards) |> filter(c -> c != 'J') .|> c -> count(==(c), h.cards)
        ) |> sort |> reverse
    J = count(==('J'), h.cards)
    # Need to handle the JJJJJ hand, damn you Evil Elf Eric
    counts = J == 5 ? (5,) : (c[1] + J, Base.tail(c)...)
    Hand(replace(h.cards, 'J' => '1'), _compute_hand(counts))
end

begin
    pairs = fetch_input("2023/inputs/input07.txt")
    sort!(pairs; by=p -> jokerify(p[1]))
    sum(((i, p),) -> i * p[2], enumerate(pairs)) |> println
end
