module NormalDist

using StatsBase
using Plots
using LaTeXStrings


"""
    normalDist(x, μ, σ)

Computes the corresponding probability of a single point `x` using a
normal distribution with a given mean `μ` and the squared root of the
variance `σ`.
"""
function normalDist(x, μ, σ)
    exparg = - (x - μ)^2 / (2 * σ^2)
    den = sqrt(2 * π * σ^2)
    return exp(exparg) / den
end


"""
 likelihood(dataset, μ, σ)

Computes the likelihood of the parameters `μ` and `σ` for a given `dataset`, 
{x1, x2, ..., xn}.
"""
function likelihood(dataset, μ, σ)
    npts = length(dataset) 
    exparg = - sum((dataset .- μ).^2) / (2 * σ^2)
    den = sqrt(2 * π * σ^2)^npts

    return exp(exparg) / den
end


"""
    maxμ(xvals)

Computes the mean value `μ` that maximizes the likelihood.
"""
function maxμ(xvals)
    return sum(xvals) / length(xvals)
end


"""
    maxσ(xvals)

Computes the squared-root of the variance `σ` that maximizes 
the likelihood.
"""
function maxσ(xvals)
    return sum((xvals .- maxμ(xvals)).^2) / length(xvals) |> sqrt
end


"""
    randomSample(xvals, weights, npts)
    
Returns the desired number of points `npts` from a data set `xvals` {xi}, 
taking into account the weights from any given distribution. This function 
will call itself recursively until all points are unique.

Maybe there is a better way to ensure no-repeated points, though.
"""
function randomSample(xvals, weights, npts)
    indexes = sample(1:length(weights), Weights(weights), npts)

    if allunique(indexes)
        return xvals[indexes]
    end
    
    randomSample(xvals, weights, npts)
end


function originalDist(μ0, σ0)
    inflim = μ0 - 3.5 * σ0
    suplim = μ0 + 3.5 * σ0
    xvals = range(inflim, suplim, 1000)
    weights = normalDist.(xvals, μ0, σ0)

    return Dict(
        :μ => μ0, 
        :σ => σ0, 
        :inflim => inflim,
        :suplim => suplim,
        :xvals => xvals,
        :weights => weights
    )
end


function guessedDist(μi, σi, data; samplepoints = 10)
    # Compute sample data from original distribution
    xs = randomSample(data[:xvals], data[:weights], samplepoints)
    ws = normalDist.(xs, μi, σi)

    # Compute the likelihood of the sample data with respect of the 
    # guessed distribution
    lh = likelihood(xs, μi, σi)
    
    # Compute the weights of the guessed distribution
    weights = normalDist.(data[:xvals], μi, σi)

    return Dict(
        :μ => μi,
        :σ => σi,
        :inflim => data[:inflim],
        :suplim => data[:suplim],
        :xvals => data[:xvals],
        :weights => weights,
        :xsample => xs,
        :wsample => ws,
        :lh => lh,
        :npts => samplepoints
    )
end


function maxDist(data; samplepoints = 10) 
    # Compute sample data from original distribution
    xs = randomSample(data[:xvals], data[:weights], samplepoints)
    μi = maxμ(xs)
    σi = maxσ(xs)
    ws = normalDist.(xs, μi, σi)

    # Compute the likelihood of the sample data with respect of the 
    # maximized distribution
    lh = likelihood(xs, μi, σi)

    # Compute the weights of the maximized distribution
    weights = normalDist.(data[:xvals], μi, σi)
    return Dict(
        :μ => μi,
        :σ => σi,
        :inflim => data[:inflim],
        :suplim => data[:suplim],
        :xvals => data[:xvals],
        :weights => weights,
        :xsample => xs,
        :wsample => ws,
        :lh => lh,
        :npts => samplepoints
    )
end


function plotGuess(guess; max = false)
    theme(:dao)
    
    roundμ = round(guess[:μ], sigdigits=4)
    roundσ = round(guess[:σ], sigdigits=4)
    roundlh = round(guess[:lh], sigdigits=2)

    myplot = plot()

    xs = guess[:xsample]
    ws = guess[:wsample]

    for i in 1:guess[:npts]
        plot!(
            [xs[i], xs[i]], 
            [0, ws[i]], 
            label = "",
            linecolor = :blue
        )
    end

    plot!(guess[:xvals], guess[:weights], 
        xlim = (guess[:inflim], guess[:suplim]), 
        ylim = (-0.05, 1),
        linecolor = :red,
        lw = 2.5, 
        label = "", 
        xlabel = L"x",
        ylabel = L"Pr(x | μ, σ^2)", 
        title = max == false ? 
            L"Pr(x_{1 \ldots N} | μ, σ^2) = " * "$(roundlh); " * 
            L"μ = " * "$(roundμ); " * 
            L"σ = " * "$(roundσ)" : 
            L"Pr(x_{1 \ldots N} | \hat{μ}, \hat{σ}^2) = " * "$(roundlh); " * 
            L"μ = " * "$(roundμ); " * 
            L"σ = " * "$(roundσ)",
        xtickfontsize = 13, 
        ytickfontsize = 13, 
        xguidefontsize = 15, 
        yguidefontsize = 15,
        titlefontsize = 13
    )
    
    scatter!(xs, zeros(guess[:npts]), label="", 
        mc = :blue,
        msc = :white,
        msw = 2
    )

    return myplot
end


end # module NormalDist
