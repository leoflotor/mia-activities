module ApproxPie

# using Plots
using Random
# using Distributed

# Distance from the origin to a point
dist_from_origin(point) = point[1]^2 + point[2]^2
dist_from_origin(x, y) = x^2 + y^2

# Linear congruential generator
# https://aaronschlegel.me/linear-congruential-generator-r.html
"""
    rngLcg(nvals)

Returns a list of pseudo-random numbers using a linear congruential generator. This
implementation uses the default parameters as those from the ANSI C implementation from
the year 2000 by Saucier.
"""
function rngLcg(nvals)
    # Parameters
    m = 2^32
    a = 1103515245
    c = 12345
    # The power of the distributed computing 
    seed = time() * 1000 |> BigFloat   # current system's time in micro seconds times 1000

    numbers = zeros(nvals)
    for i in eachindex(numbers)
        seed = (a * seed + c) % m
        numbers[i] = seed / m
    end
    
    return numbers
end

# Halton sequence generator
"""
    rngHalton(nvals; base=2)

Returns a list of pseudo-random numbers generated using the Halton sequence. The
default `base` is 2.
"""
function rngHalton(nvals)
    base = rand(2:150)
    numbers = zeros(nvals)

    for i in eachindex(numbers)
        f = 1
        r = 0

        indx = i
        while indx > 0
            f = f / base
            r = r + f * (indx % base)
            indx = floor(indx / base)
        end

        numbers[i] = r
    end

    return numbers
end

# I dont want to choose the base every time! Imagine that `rand` is the action
# of a usr that chooses a different base, kind of.
# rngHalton(nvals) = rngHaltonHelper(nvals; base=rand(2:150))

# Julia's default random number generator
# rngJulia(nvals; seed=rand(2:150)) = rand(MersenneTwister(seed), Float64, nvals)
function rngJulia(nvals)
    seed = rand(2:150)

    return rand(MersenneTwister(seed), Float64, nvals)
end

function getPoints(npoints)
    # s = 2
    # rndgrid = s .* rand(Float64, (npoints, 2)) .- s / 2

    rndgrid = rand(Float64, (npoints, 2))
    points = map(x -> (x[1], x[2]), eachrow(rndgrid))
    
    return points
end

function classifyPoints(points)
    inside_circle = filter(x -> dist_from_origin(x) <= 1, points)
    outside_circle = filter(x -> dist_from_origin(x) > 1, points)

    return (in = inside_circle, out = outside_circle)
end

function classifyPoints(xvals, yvals)
    inside_circle = []
    outside_circle = []

    for (x, y) in zip(xvals, yvals)
        if dist_from_origin(x, y) > 1
            push!(outside_circle, (x, y))
        else
            push!(inside_circle, (x, y))
        end
    end

    return (in = inside_circle, out = outside_circle)
end

function pieApprox(classification)
    ps = classification
    count_circle = length(ps.in)
    count_square = count_circle + length(ps.out)

    return 4 * count_circle / count_square
end

function piesApprox(npoints; rng="julia")
    methods = Dict(
        "julia" => rngJulia, 
        "halton" => rngHalton,
        "lcg" => rngLcg
    )
    method = methods[rng]
    pies = []

    for i in 1:npoints
        xs = method(i)
        ys = method(i)

        classify = classifyPoints(xs, ys)
        pie = pieApprox(classify)
        push!(pies, (i, pie))
    end

    return pies
end

function plotFig(classification)
    ps = classification
    dx = 0.01    # extra space to not cut circles at the limits

    fig = plot(size=(600,600), 
        xlims=(-dx,1+dx), ylims=(-dx,1+dx), 
        xticks=nothing, yticks=nothing) 

    scatter!(ps.out, label="", ms=4, ma=0.5, msw=0.5)
    scatter!(ps.in, label="", ms=4, ma=0.5, msw=0.5)

    xaxis!(fig, bordercolor="white")
    yaxis!(fig, bordercolor="white")

    return fig
end

# julia> n = 5000; approximations = ap.piesApprox(n);
# julia> npoints = map(x -> x[1], approximations); pies = map(x -> x[2], approximations);
# julia> scatter(npoints, pies, label="", ms=2, ma=0.8); hline!([π], label="", lw=2.5)

end # module ApproxPie
