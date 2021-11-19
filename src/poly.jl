module poly

using GLMakie

function main()
    fig = Figure()
    ax = Axis(fig[1, 1], title="Interactive area")
    deregister_interaction!(ax, :rectanglezoom)

    points = Node(Point2f[])
    scatter!(ax, points)

    poly = @lift begin
        if length($points) < 3
            $points
        else
            tmp = copy($points)
            push!(tmp, $points[1])
            tmp
        end
    end

    lines!(ax, poly)

    mouseevents = addmouseevents!(ax.scene)
    onmouseleftdown(mouseevents) do event
        dpos = event.data
        points[] = push!(points[], dpos)
    end

    on(events(fig).keyboardbutton) do event
        if event.action == Keyboard.press && event.key == Keyboard.r
            points[] = empty(points[])
        end
    end

    display(fig)
    nothing
end

end # module
