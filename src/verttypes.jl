@enum VertType begin
    StartVertex
    EndVertex
    MergeVertex
    SplitVertex
    RegularVertex
end

function mkverttypes(orient)
    function verttypes(poly::Vector{Point2{T}})::Vector{VertType} where T
        if length(poly) < 3
            return fill(RegularVertex, length(poly))
        end
        
        types = similar(poly, VertType)

        p(i) = poly[mod(i - 1, length(poly)) + 1]
        y(i) = p(i)[2]

        for i=eachindex(poly)
            y1, y2, y3 = y.([i-1,i,i+1])
            types[i] = begin
                if orient(p.([i-1,i,i+1])...) > 0
                    if y1 < y2 > y3
                        StartVertex
                    elseif y1 > y2 < y3
                        EndVertex
                    else
                        RegularVertex
                    end
                else
                    if y1 < y2 > y3
                        SplitVertex
                    elseif y1 > y2 < y3
                        MergeVertex
                    else
                        RegularVertex
                    end
                end
            end
        end

        types
    end
end
