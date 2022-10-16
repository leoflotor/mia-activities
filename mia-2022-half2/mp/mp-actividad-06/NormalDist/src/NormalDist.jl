module NormalDist

using StatsBase
using Plots
using LaTeXStrings
using LazyGrids # To generate lazy grids with low memory allocation


"""
    normalDist(x::Real, μ, σ)

Computes the corresponding probability of a single point `x` using a 
normal distribution with a given mean `μ` and the squared root of the 
variance `σ`.
"""
function normalDist(x::Real, μ, σ)
    exparg = - (x - μ)^2 / (2 * σ^2)
    den = sqrt(2 * π * σ^2)
    return exp(exparg) / den
end


"""
    normalDist(xpts::Array, μ, σ)

Computes the corresponding probability from a list of points `xpts` using a 
normal distribution with a given mean `μ` and the squared root of the 
variance `σ`.
"""
function normalDist(xpts::Union{Array, StepRangeLen}, μ, σ)
    return normalDist.(xpts, μ, σ)
end


"""
    likelihood(xpts, μ, σ)

Computes the likelihood of a given array of points `xpts` with respect of
a normal distribution with parameters `μ` and `σ`.
"""
function likelihood(xpts, μ, σ)
    npts = length(xpts) 
    exparg = - sum((xpts .- μ).^2) / (2 * σ^2)
    den = (2 * π * σ^2)^(npts / 2)
    return exp(exparg) / den
end


"""
    maxμ(xpts)

Computes the mean value `μ` that maximizes the likelihood.
"""
function maxμ(xpts)
    npts = length(xpts)
    return sum(xpts) / npts
end


"""
    maxσ(xpts)

Computes the squared-root of the variance `σ` that maximizes 
the likelihood.
"""
function maxσ(xpts)
    npts = length(xpts)
    return (sum((xpts .- maxμ(xpts)).^2) / npts) |> sqrt
end


"""
    randomSample(xpts, weights, npts)
    
Returns the desired number of points `npts` from a list of points `xpts`, 
taking into account a list of their weights `weights` from any given 
distribution.
"""
function randomSample(xpts, weights, npts)
    return sample(xpts, Weights(weights), npts)
end

function plotNormal(x, w)
    fig = plot(
        tickfont=(12, "Computer Modern"),
        xlim = (x[begin], x[end]),
        ylim = (-0.05, 0.45),
        dpi = 400,
        size = (600, 400),
    )

    plot!(x, w, 
        linecolor = :red,
        lw = 2.5, 
        label = "", 
        xlabel = L"x",
        ylabel = L"Norm_{x}[\mu, \sigma^2]",
        xtickfontsize = 13, 
        ytickfontsize = 13, 
        xguidefontsize = 15, 
        yguidefontsize = 15,
        titlefontsize = 13,
    )

    return fig
end

function plotGuess(xsample, wsample, x, w, lh, μi, σi; maxlh = false)
    npts = length(xsample)

    roundμ = round(μi, sigdigits=4)
    roundσ = round(σi, sigdigits=4)
    roundlh = round(lh, sigdigits=1)

    # theme(:ggplot2)
    fig = plot(
        tickfont=(12, "Computer Modern"),
        xlim = (x[begin], x[end]),
        ylim = (-0.05, 0.45),
        dpi = 400,
        size = (600, 400),
    )

    for i in 1:npts
        plot!(
            [xsample[i], xsample[i]], 
            [0, wsample[i]], 
            label = "",
            linecolor = :blue,
            linealpha = 0.6,
        )
    end
    
    # Just some formatting depending on if the maximum likelihood is
    # ploted or not
    μstr = maxlh == false ? "μ" : raw"\hat{μ}"
    σstr = maxlh == false ? "σ" : raw"\hat{σ}"
    title = raw"Pr(x_{1 \ldots" * "$(npts)" * raw"} |" * μstr * raw", " *
        σstr * raw"^2) = " * "$(roundlh)" * raw"; " * μstr * " = " * 
        "$(roundμ); " * σstr * raw" = " * "$(roundσ)"
    ylabel = raw"Pr(x | " * "$(μstr)" * ", " * "$(σstr)" * raw"^2)"
    plot!(x, w, 
        linecolor = :red,
        lw = 2.5, 
        label = "", 
        xlabel = L"x",
        ylabel = latexstring(ylabel),
        title = latexstring(title),
        xtickfontsize = 13, 
        ytickfontsize = 13, 
        xguidefontsize = 15, 
        yguidefontsize = 15,
        titlefontsize = 13,
    )

    scatter!(xsample, zeros(npts),
        label = "", 
        mc = :blue,     # marker color
        msc = :white,   # marker stroke color
        msw = 2,        # marker stroke width
    )

    return fig
end


function plotHeat(μi, σi, μmax, σmax, μrange, σrange, lhmesh, npts)
    title = raw"Pr(x_{1\ldots" * "$(npts)" * raw"} | μ, σ^2)"
    fig = plot(
        xlim = (σrange[begin], σrange[end]),
        ylim = (μrange[begin], μrange[end]),
        dpi = 400,
        size = (600, 400),
        xlabel = L"\sigma", 
        ylabel = L"\mu",
        title = latexstring(title),
        xguidefontsize = 17, 
        yguidefontsize = 17,
        tickfont = (12, "Computer Modern"),
        grid = :dash,
        gridlinewidth = 0.6,
        gridalpha = 0.95,
        minorgrid = :dash,
        minorgridlinewidth = 0.4,
        minorticks = 2,
        minorgridalpha = 0.95,
        legend = :topleft,
    )

    heatmap!(σrange, μrange, lhmesh, 
        c = cgrad(:thermal, rev = false, alpha=0.9), # colormap
        colorbar = :none,
    )
    
    scatter!(σi, μi, 
        label = L"\{μ_{i}\ ,\ σ_{i}\}",
        mc = :magenta,
        ms = 5,
        msw = 1,
        msc = :black,
    )

    scatter!([σmax], [μmax], 
        label = L"\{\hat{μ}\ ,\ \hat{σ}\}",
        mc = :cyan,
        ms = 5,
        shape = :star5,
        msw = 1,
        msc = :black
    )
    
    return fig
end


end # module NormalDist
