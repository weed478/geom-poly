module poly

using GLMakie

function main()
    fig = Figure()
    ax = Axis(fig[2, 1], title="Interactive area")
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
        if event.action == Keyboard.press
            if event.key == Keyboard.r
                points[] = empty(points[])
            elseif event.key == Keyboard.a
                autolimits!(ax)
            end
        end
    end

    fig[1, 1] = controlsgrid = GridLayout(tellwidth=false)
    
    resetbtn = controlsgrid[1, 1] = Button(fig, label="Reset (R)")
    on(resetbtn.clicks) do n
        points[] = empty(points[])
    end

    autoscalebtn = controlsgrid[1, 2] = Button(fig, label="Autoscale (A)")
    on(autoscalebtn.clicks) do n
        autolimits!(ax)
    end

    display(fig)
    nothing
end

end # module
