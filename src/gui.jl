module GUI

using GLMakie
import ..Geometry
import LinearAlgebra

const orient = Geometry.mkorient(Geometry.Orient3x3, LinearAlgebra.det, 1f-10)
const verttypes = Geometry.mkverttypes(orient)

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


    display(fig)
    nothing
end

end # module
