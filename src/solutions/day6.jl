using Pipe

datastream = readchomp("src/inputs/day6.txt") |> collect
findndiff(msg, n) = findfirst(i -> length(Set(msg[i:i+n-1])) == n, 1:length(msg)) + n - 1
findndiff(datastream, 4) |> println
findndiff(datastream, 14) |> println

