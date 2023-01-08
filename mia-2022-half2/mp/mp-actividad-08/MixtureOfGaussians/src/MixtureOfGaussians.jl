module MixtureOfGaussians

using Plots
using StatsBase

"""
    normal_dist(x::Real, μ, σ)

Computes the corresponding probability of a single point `x` using a 
normal distribution with a given mean `μ` and the squared root of the 
variance `σ`.
"""
function normal_dist(x::Real, μ, σ)
    exparg = - (x - μ)^2 / (2 * σ^2)
    den = sqrt(2 * π * σ^2)
    return exp(exparg) / den
end

"""
    normal_dist(xpts::Array, μ, σ)

Computes the corresponding probability from a list of points `xpts` using a 
normal distribution with a given mean `μ` and the squared root of the 
variance `σ`.
"""
function normal_dist(xpts::Union{Array, StepRangeLen}, μ, σ)
    return normal_dist.(xpts, μ, σ)
end

function mixture_dist(xs, λs, μs, σs)
    return sum(λs .* normal_dist.(Ref(xs), μs, σs))
end

function random_sample(xs, ws, n)
    return sample(xs, Weights(ws), n; replace=false)
end

function mix_sample(xs, μs, σs, points_per_dist)
    xs = xs |> collect
    ws_per_dist = normal_dist.(Ref(xs), μs, σs)
    xs_per_dist = map(x -> random_sample(xs, x, points_per_dist), ws_per_dist)
    return vcat(xs_per_dist...)
end

function likelihood(xs, λs, μs, σs, I=missing, K=missing)
    return prod(sum(λ * normal_dist(x, μ, σ) for (λ, μ, σ) in zip(λs, μs, σs)) for x in xs)
end

function random(s, n=1)
    # s is the range [-s,s]
    # n is number of desired random values in that range
    return s .* rand(n) .- s / 2
end

function responsibility(i, k, xs, λs, μs, σs)
    # i -> [x1, x2, ..., xn] is the set of data points
    # k -> [θ1, θ2, ..., θk] where θk is the set {λk, μk, σk}
    num = λs[k] * normal_dist(xs[i], μs[k], σs[k])
    if !isequal(num, 0)
        den = sum(λ * normal_dist(xs[i], μ, σ) for (λ, μ, σ) in zip(λs, μs, σs))
        return num / den
    end
    return 0
end

function responsibility_matrix(xs, λs, μs, σs, I=missing, K=missing)
    I = ismissing(I) ? length(xs) : I
    K = ismissing(K) ? length(λs) : K
    # mat = zeros(I, K)
    mat = Array{Union{Missing,Float64}}(missing, I, K)
    for row in 1:I, col in 1:K
        mat[row, col] = responsibility(row, col, xs, λs, μs, σs)
    end
    return mat
end

function em_algorithm!(xs, λs, μs, σs; 
        steps=10, 
        # abstol=1E-6,
    )
    I = length(xs) 
    K = length(λs)
    rs = missing
    θs = []
    for _ in 1:steps
        # E-step
        rs = responsibility_matrix(xs, λs, μs, σs, I, K)
        # M-step
        for k in 1:K
            rsksum = sum(rs[:,k])
            λs[k] = rsksum / sum(rs)
            μs[k] = sum(rs[:,k] .* xs) / rsksum
            σs[k] = sum(rs[:,k] .* (xs .- μs[k]).^2) / rsksum |> sqrt
        end
        θi = likelihood(xs, λs, μs, σs, I, K)
        push!(θs, θi)
    end
    return θs
end

function em_algorithm(xs, λs, μs, σs; 
        steps=10, 
        abstol=missing,
    )
    I = length(xs) 
    K = length(λs)
    λt = [λs]
    μt = [μs]
    σt = [σs]
    rs = missing
    θt = [likelihood(xs, λs, μs, σs, I, K)]
    for _ in 1:steps
        λ = λt[end] |> deepcopy
        μ = μt[end] |> deepcopy
        σ = σt[end] |> deepcopy
        # E-step
        rs = responsibility_matrix(xs, λ, μ, σ, I, K)
        # M-step
        for k in 1:K
            rsksum = sum(rs[:,k])
            λ[k] = rsksum / sum(rs)
            μ[k] = sum(rs[:,k] .* xs) / rsksum
            σ[k] = sum(rs[:,k] .* (xs .- μ[k]).^2) / rsksum |> sqrt
        end
        θ = likelihood(xs, λ, μ, σ, I, K)
        push!(λt, λ)
        push!(μt, μ)
        push!(σt, σ)
        push!(θt, θ)

        # Lo que se debe maximizar es el log10(θ) no θ. 
        # Este criterio de terminacion temprana ayuda a prevenir computar iteraciones inecesarias.
        if !ismissing(abstol) && abs(log10(θt[end]) - log10(θt[end-1])) < abstol
            return λt, μt, σt, θt
        end
    end
    return λt, μt, σt, θt
end


# function plotNormal(x, w)
#     fig = plot(
#         tickfont=(12, "Computer Modern"),
#         xlim = (x[begin], x[end]),
#         ylim = (-0.05, 0.45),
#         dpi = 400,
#         size = (600, 400),
#     )
#     
#     plot!(x, w, 
#         linecolor = :red,
#         lw = 2.5, 
#         label = "", 
#         xlabel = L"x",
#         ylabel = L"Norm_{x}[\mu, \sigma^2]",
#         xtickfontsize = 13, 
#         ytickfontsize = 13, 
#         xguidefontsize = 15, 
#         yguidefontsize = 15,
#         titlefontsize = 13,
#     )

#     return fig
# end

end # module MixtureOfGaussians
