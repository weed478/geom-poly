function mktriangulate(orient)
    function triangulate(poly::Vector{Point2{T}}, triangles=missing)::Vector{Line{2,T}} where T
        n = length(poly)

        if n < 4
            return []
        end

        # modulo indexing
        modind(i) = mod(i - 1, length(poly)) + 1
        pmod(i) = poly[modind(i)]
        
        # sorted indices
        sorted = sort(1:n, by=(i -> poly[i][2]))
        
        # get vertex by sorted index
        v(i) = poly[sorted[i]]

        function pushtriangle!(i, j, k)
            if !ismissing(triangles)
                push!(triangles, Triangle{2,T}(v(i), v(j), v(k)))
            end
        end

        function getchain(i)
            ps = pmod.(sorted[i]-1:sorted[i]+1)
            y0, y1, y2 = getindex.(ps, 2)
            if y0 > y1 > y2
                -1
            elseif y0 < y1 < y2
                1
            else
                @assert y1 == v(1)[2] || y1 == v(n)[2]
                0
            end
        end

        function samechain(i, j)
            c1 = getchain(i)
            c2 = getchain(j)
            return c1 == 0 || c2 == 0 || c1 == c2
        end

        function goodtriangle(i, j, k)
            # weird
            # @assert (v(i)[2] > v(j)[2] > v(k)[2]) || (v(i)[2] < v(j)[2] < v(k)[2])
            if getchain(j) == -1
                orient(v.([i, j, k])...) > 0
            elseif getchain(j) == 1
                orient(v.([i, j, k])...) < 0
            else
                @error "This will not print"
            end
        end

        diags = Line{2,T}[]
        function pushdiag!(i, j)
            if (modind(sorted[i] + 1) != sorted[j]) &&
            (modind(sorted[i] - 1) != sorted[j])
                push!(diags, Line(v(i), v(j)))
            end
        end
        
        stack = [1, 2]
        
        for i = 3:n
            if !samechain(i, stack[end])
                k = missing
                for j = stack
                    pushdiag!(i, j)
                    if !ismissing(k)
                        pushtriangle!(i, j, k)
                    end
                    k = j
                end
                stack = [stack[end], i]
            else
                j = pop!(stack)
                while length(stack) > 0 && goodtriangle(i, j, stack[end])
                    pushdiag!(i, stack[end])
                    pushtriangle!(i, j, stack[end])
                    j = pop!(stack)
                end
                push!(stack, j)
                push!(stack, i)
            end
        end

        diags
    end
end # mktriangulate
