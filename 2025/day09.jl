coords = map(eachline("2025/inputs/day09.txt")) do line
    map(split(line, ",") |> Tuple) do x
        parse(Int, x)
    end
end

begin
    area = 0
    for (i, c) in enumerate(coords)
        for (j, d) in enumerate(coords[(i+1):end])
            w = abs(c[1] - d[1]) + 1
            h = abs(c[2] - d[2]) + 1
            area = max(area, w * h)
        end
    end
    area
end

const CI = CartesianIndex
const CIs = CartesianIndices

function isvalidrectandle(coords, c1, c2)
    x_min = min(c1[1], c2[1])
    x_max = max(c1[1], c2[1])
    y_min = min(c1[2], c2[2])
    y_max = max(c1[2], c2[2])
    for c in coords
        if x_min < c[1] < x_max && y_min < c[2] < y_max
            return false
        end
    end
    for segment in zip(coords, circshift(coords, 1))
        a, b = segment
        if a[1] == b[1]
            x = a[1]
            yl, yh = minmax(a[2], b[2])
            if !(x_min < x < x_max) # Segment outside rectangle
                continue
            end
            if (yh ≤ y_min) || (yl ≥ y_max) # Segment outside rectangle
                continue
            end
            return false
        elseif a[2] == b[2]
            y = a[2]
            xl, xh = minmax(a[1], b[1])
            if !(y_min < y < y_max) # Segment outside rectangle
                continue
            end
            if (xh ≤ x_min) || (xl ≥ x_max) # Segment outside rectangle
                continue
            end
            return false
        end
    end
    return true
end


begin
    area = 0
    for (i, c) in enumerate(coords)
        for (j, d) in enumerate(coords[(i+1):end])
            if isvalidrectandle(coords, c, d)
                w = abs(c[1] - d[1]) + 1
                h = abs(c[2] - d[2]) + 1
                area = max(area, w * h)
            end
        end
    end
    area
end