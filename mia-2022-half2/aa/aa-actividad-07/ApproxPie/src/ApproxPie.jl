module ApproxPie

using Random
using Plots
using LaTeXStrings

# Distance from the origin to a point
dist_from_origin(x, y) = x^2 + y^2

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

rng = MersenneTwister(rand(100:185112384089))
rngJulia(nvals) = rand(rng, Float64, nvals)

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

function piesApprox(npoints; rng="julia")
    methods = Dict(
        "julia" => rngJulia, 
        "halton" => rngHalton,
        "lcg" => rngLcg)
    method = methods[rng]

    xvalues = method(npoints)
    yvalues = method(npoints)
    pies = Array{BigFloat}(undef, npoints)

    points_inside_circle = BigFloat(0)
    for i in 1:npoints
        xi = xvalues[i]
        yi = yvalues[i]
        disti = xi^2 + yi^2

        if disti <= 1
            points_inside_circle += 1
        end

        pie = 4 * points_inside_circle / i
        pies[i] = pie
    end

    return (pies=pies, xvalues=xvalues, yvalues=yvalues)
end

function plotClassification(classification, pieval)
    theme(:ggplot2)
    dx = 0.01    # extra space to not cut circles at the limits
    x_in = map(x -> x[1], classification.in)
    y_in = map(x -> x[2], classification.in)
    x_out = map(x -> x[1], classification.out)
    y_out = map(x -> x[2], classification.out) 

    fig = plot(
        size=(375,400),
        xlabel=L"x",
        ylabel=L"y",
        title=raw"$\pi \approx" * "$(pieval)"[begin:7] * raw"$",
        xlims=(-dx,1+dx), ylims=(-dx,1+dx), 
        xticks=(0:0.2:1), yticks=(0:0.2:1),
        aspect_ratio=:equal,
        dpi=600) 

    scatter!(x_in, y_in, label="", ms=1, ma=0.5, msw=0.1)
    scatter!(x_out, y_out, label="", ms=1, ma=0.5, msw=0.1)

    return fig
end

function pieNaive(npoints)
    point = 1
    inside_circle = 0

    while point < npoints
        x = rand()
        y = rand()
        if dist_from_origin(x, y) <= 1
            inside_circle += 1
        end
        point += 1
    end

    return 4 * inside_circle / npoints
end

function piesNaive(npoints)
    pies = zeros(npoints)
    for i in 1:npoints
        pies[i] = pieNaive(i)
    end
    return pies
end

# function piesNaive(npoints)
#     pies = zeros(npoints)
#     return map(i -> pies[i] = pieNaive(i), eachindex(pies))
# end

end # module ApproxPie
