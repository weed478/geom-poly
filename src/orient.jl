function orient3x3(detfn, e::T, a::Point2{T}, b::Point2{T}, c::Point2{T})::Int where T
    M::Matrix{T} = [a[1] a[2] 1
                    b[1] b[2] 1
                    c[1] c[2] 1]

    d::T = detfn(M)

    if abs(d) < e
        0
    elseif d < 0
        -1
    else
        1
    end
end

function orient2x2(detfn, e::T, a::Point2{T}, b::Point2{T}, c::Point2{T})::Int where T
    M::Matrix{T} = [(a[1] - c[1]) (a[2] - c[2])
                    (b[1] - c[1]) (b[2] - c[2])]

    d::T = detfn(M)

    if abs(d) < e
        0
    elseif d < 0
        -1
    else
        1
    end
end
