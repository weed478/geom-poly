@enum OrientType Orient2x2 Orient3x3

# funkcja orient zwraca -1, 0, 1
# porównywanie z epsilon odbywa się w funkcji

function mkorient(type::OrientType, det, e::T) where T
    if type == Orient2x2
        function orient2x2(a::Point2{T}, b::Point2{T}, c::Point2{T})::Int
            M::Matrix{T} = [(a[1] - c[1]) (a[2] - c[2])
                            (b[1] - c[1]) (b[2] - c[2])]
        
            d::T = det(M)
        
            if abs(d) < e
                0
            elseif d < 0
                -1
            else
                1
            end
        end
    elseif type == Orient3x3
        function orient3x3(a::Point2{T}, b::Point2{T}, c::Point2{T})::Int
            M::Matrix{T} = [a[1] a[2] 1
                            b[1] b[2] 1
                            c[1] c[2] 1]
        
            d::T = det(M)
        
            if abs(d) < e
                0
            elseif d < 0
                -1
            else
                1
            end
        end
    else
        @error "Invalid orient type $type"
    end
end
