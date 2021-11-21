module GUI

using GLMakie
using GeometryBasics
import ..Geometry
import LinearAlgebra

const orient = Geometry.mkorient(Geometry.Orient3x3, LinearAlgebra.det, 1f-10)
const verttypes = Geometry.mkverttypes(orient)
const triangulate = Geometry.mktriangulate(orient)

function run()
    fig = Figure()
    fig[1, 1] = controlsgrid = GridLayout(tellwidth=false)
    fig[2, 1] = textgrid = GridLayout(tellwidth=false)
    ax = Axis(fig[3, 1], title="Interactive area")
    deregister_interaction!(ax, :rectanglezoom)


    points = Node(Point2f[])
    closedloop = @lift begin
        if length($points) < 3
            $points
        else
            tmp = copy($points)
            push!(tmp, $points[1])
            tmp
        end
    end

    ismonotone = @lift Geometry.ismonotone($points)
    
    monotonetext = @lift begin
        if length($points) < 3
            "Nie ma wielokąta to nie ma monotoniczności"
        else
            "Wielokąt $($ismonotone ? "jest" : "nie jest") y-monotoniczny" 
        end
    end
    Label(textgrid[1, 1], monotonetext)

    linecolor = @lift($ismonotone ? :green : :red)
    lines!(ax, closedloop, color=linecolor)

    markers = @lift begin
        map(verttypes($points)) do t
            if t == Geometry.StartVertex
                :utriangle
            elseif t == Geometry.EndVertex
                :rect
            elseif t == Geometry.MergeVertex
                :star5
            elseif t == Geometry.SplitVertex
                :xcross
            else
                :circle
            end
        end
    end

    scatter!(
        ax,
        points,
        marker=markers,
        markersize=15,
        color=:black,
    )

    Legend(fig[3, 2],
        [
            MarkerElement(
                marker=:utriangle,
                markersize=15,
                color=:black,
            ),
            MarkerElement(
                marker=:rect,
                markersize=15,
                color=:black,
            ),
            MarkerElement(
                marker=:star5,
                markersize=15,
                color=:black,
            ),
            MarkerElement(
                marker=:xcross,
                markersize=15,
                color=:black,
            ),
            MarkerElement(
                marker=:circle,
                markersize=15,
                color=:black,
            ),
        ],
        [
            "Początkowe",
            "Końcowe",
            "Łączące",
            "Dzielące",
            "Prawidłowe",
        ],
    )


    triangles = Node{Vector{Triangle{2,Float32}}}([])
    visibletriangles = Node{Vector{Triangle{2,Float32}}}([])

    triang = @lift begin
        triangles[] = []

        segments = Point2f[]
        
        if !$ismonotone
            return segments
        end

        lines = triangulate($points, triangles[])
        triangles[] = triangles[]

        for l in lines
            push!(segments, l[1])
            push!(segments, l[2])
        end
        
        segments
    end

    linesegments!(ax, triang)
    
    animstep = Node(0)

    function stepanimation!()
        animstep[] = animstep[] + 1
    end

    on(animstep) do animstep
        visibletriangles[] = collect(Iterators.take(triangles[], animstep))
    end

    on(points) do p
        animstep[] = 0
    end

    emptypoly = [Point2f(0, 0), Point2f(0, 0), Point2f(0, 0)]
    polys = Node{Vector{Vector{Point2f}}}([emptypoly])

    on(visibletriangles) do triangles
        polys.val = []
        if length(triangles) == 0
            push!(polys.val, emptypoly)
        else
            for t in triangles
                push!(polys.val, [t[1], t[2], t[3]])
            end
        end
        polys[] = polys[]
    end

    poly!(ax, polys)


    function pushpoint!(p)
        points[] = push!(points[], p)
    end

    function poppoint!()
        length(points[]) > 0 && pop!(points[])
        points[] = points[]
    end

    function clearpoints!()
        points[] = empty(points[])
    end


    mouseevents = addmouseevents!(ax.scene)
    onmouseleftdown(mouseevents) do event
        dpos = event.data
        pushpoint!(dpos)
    end

    on(events(fig).keyboardbutton) do event
        if event.action == Keyboard.press
            if event.key == Keyboard.r
                clearpoints!()
            elseif event.key == Keyboard.a
                autolimits!(ax)
            elseif event.key == Keyboard.p
                poppoint!()
            elseif event.key == Keyboard.s
                stepanimation!()
            end
        end
    end

    
    resetbtn = controlsgrid[1, 1] = Button(fig, label="Reset (R)")
    on(resetbtn.clicks) do n
        clearpoints!()
    end

    autoscalebtn = controlsgrid[1, 2] = Button(fig, label="Autoscale (A)")
    on(autoscalebtn.clicks) do n
        autolimits!(ax)
    end

    popbtn = controlsgrid[1, 3] = Button(fig, label="Remove last (P)")
    on(popbtn.clicks) do n
        poppoint!()
    end

    animbtn = controlsgrid[1, 4] = Button(fig, label="Step animation (S)")
    on(animbtn.clicks) do n
        stepanimation!()
    end


    display(fig)
    nothing
end

end # module
