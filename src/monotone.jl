function ismonotone(poly::Vector{Point2{T}})::Bool where T
    if length(poly) < 3
        return false
    end
    
    foundbot = false
    foundtop = false

    y(i) = poly[mod(i - 1, length(poly)) + 1][2]

    for i=eachindex(poly)
        if y(i - 1) < y(i) > y(i + 1)
            if foundtop
                return false
            else
                foundtop = true
            end
        elseif y(i - 1) > y(i) < y(i + 1)
            if foundbot
                return false
            else
                foundbot = true
            end
        end
    end

    true
end
