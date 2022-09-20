module BayesianImageAnalysis

#==============================
Required packages
and exports
===============================#

using Images                # Manipulation of images in general
using LinearAlgebra         # Matrix operations
using StatsBase: sample     # Only for random sampling
using GLMakie               # Plotting functionality

#==============================
Aliases
===============================#

tr = transpose

#==============================
Pixel and image operations
===============================#

"""
    pixelToVec(pixel)

Converts Julia's pixel format to a vector of Float64's to avoid overflow.

# Examples
```jldoctest
julia> p = RGB(0.5, 0.5, 0.5)
RGB{Float64}(0.5,0.5,0.5)

julia> pixelToVec(p)
3-element Vector{Float64}:
 0.5
 0.5
 0.5
```
"""
pixelToVec(pixel) = [red(pixel), green(pixel), blue(pixel)] .|> Float64

imgPixelCount(img) = reduce(*, size(img))

randomPixelSampling(n, img) = sample(img, n, replace=false)

uniquePixels(img) = unique(img)

function eigData(matrix)
    eig_data = LinearAlgebra.eigen(matrix)
    eig_vals = eig_data.values
    eig_vecs = eig_data.vectors
    
    # Check all eigenvectors for all negative entries, this means that
    # there is a global phase that inverts the vector towards the negative
    # direction and can be removed
    for i in 1:3
        if all(x -> x < 0, eig_vecs[:,i])
            eig_vecs[:,i] = -eig_vecs[:,i]
        end
    end
    return (values=eig_vals, vectors=eig_vecs)
end

function imageSave(path, img)
    save(path, img, px_per_unit=4)
end

#==============================
Functions (?)
===============================#

avgVector(img) = sum(pixelToVec(pixel) for pixel in img) / imgPixelCount(img)

function covarianceMatrix(img, avg_vec)
    num = sum(
            (pixelToVec(pixel) - avg_vec) * tr(pixelToVec(pixel) - avg_vec) 
            for pixel in img)
    den = (imgPixelCount(img) - 1)
    return num / den
end

# Correlation matrix elements
r(i, j, mat) = mat[i,j] / sqrt(mat[i,i] * mat[j,j])

function correlationMatrix(covMat)
	(nRows, nCols) = size(covMat)
	corMat = zeros(Float64, (nRows, nCols))
	
    for j in 1:nCols, i in 1:nRows
	   corMat[i,j] = r(i, j, covMat)
	end
	return corMat
end

function gaussianDist(pixel::RGB{N0f8}, avg_vec, cov_mat)
    # This matrix should have the number of rows and cols
    dim = size(cov_mat)[1]
    exp_arg = (- tr(pixelToVec(pixel) - avg_vec) 
                * inv(cov_mat) 
                * (pixelToVec(pixel) - avg_vec) / 2)
    num = exp(exp_arg)
    den = (2 * pi)^(dim / 2) * sqrt(det(cov_mat))
    return num / den
end

#==============================
Visualization
===============================#

function pixelCloud(img, avg_vec=nothing, eig_vecs=nothing; azimuth=0.2, elevation=0.2)
    pixel_set = uniquePixels(img)
    red_pixels = red.(pixel_set)
    green_pixels = green.(pixel_set)
    blue_pixels = blue.(pixel_set)
    
    # Adding some transparency to the points so the vector can be seen better
    pixel_set = map(x -> RGBA(x, 0.7), pixel_set)
    
    # Average vector origin and head positions
    dir = isnothing(avg_vec) ? nothing : [Point3f(avg_vec)]
    origin = [Point3f(0,0,0)]
    
    # Eigenvectors positions
    scale = isnothing(eig_vecs) ? nothing : 1/10 # scale eigenvectors
    eig_dir = isnothing(eig_vecs) ? nothing : [Point3f(vec)*scale for vec in eachcol(eig_vecs)]
    eig_origin = isnothing(eig_vecs) ? nothing : [Point3f(avg_vec) for i in 1:3]

    # Plot options
    arrow_head = 0.05
    arrow_width = 0.015

    dpi = 400
    fig = Figure(resolution=(4*dpi, 3*dpi), fontsize=35)
    ax = Axis3(fig[1,1], 
        xlabel=L"Red", ylabel=L"Green", zlabel=L"Blue",
        xlabeloffset=95,
        ylabeloffset=95,
        zlabeloffset=95,
        perspectiveness=0.0, # Nice orthographic view
        azimuth=azimuth*pi, elevation=elevation*pi,
    )
    xlims!(ax, 0, 1)
    ylims!(ax, 0, 1)
    zlims!(ax, 0, 1)

    # Only plot the average vector if it was defined
    if !isnothing(avg_vec)
        arrows!(origin, dir, fxaa=true,
            linecolor=:red, 
            arrowcolor=:red,
            linewidth=arrow_width,
            arrowsize=Vec3f(arrow_head, arrow_head, arrow_head),
        )
    end
    # Only plot the eigen vectors if they were defined
    if !isnothing(eig_vecs)
        factor = 0.55
        arrows!(eig_origin, eig_dir, fxaa=true,
            linecolor=:orange, arrowcolor=:orange,
            linewidth=arrow_width*factor, 
            arrowsize=Vec3f(arrow_head*factor, arrow_head*factor, arrow_head*factor),
        )
    end
    scatter!(ax, red_pixels, green_pixels, blue_pixels,
        markersize=3.0,
        color=pixel_set,
    )
    return fig
end

function gaussianCloud(avg_vec, cov_mat; tol=0.1, density=0.05, azimuth=0.2, elevation=0.2)
    step = density
    start = 0.0 + step
    stop = 1.0 - step
    int = start:step:stop
    
    # Create a dummy pixel set
    pixel_set = collect(RGB{N0f8}(r,g,b) for r in int for g in int for b in int)
    red_pixels = red.(pixel_set)
    green_pixels = green.(pixel_set)
    blue_pixels = blue.(pixel_set)
    
    # The values of the dummy pixel set are used to compute a gaussian 
    # cloud of probability
    gaussian_points = map(x -> gaussianDist(x, avg_vec, cov_mat), pixel_set)
    gaussian_points = gaussian_points / maximum(gaussian_points)
    
    # The values of the gaussian cloud are removed if smaller than a
    # tolerance value only for visualization purposes
    condition = gaussian_points .> tol
    red_pixels = red_pixels[condition]
    green_pixels = green_pixels[condition]
    blue_pixels = blue_pixels[condition]
    gaussian_points = gaussian_points[condition]
    
    # Transparency of the points depend depend on its probability value
    # from the gaussian cloud
    trans = map(x -> RGBA(0,0,0,x), gaussian_points)
    
    dpi = 400
    fig = Figure(resolution=(4*dpi, 3*dpi), fontsize=35)
    ax = Axis3(fig[1,1], 
        xlabel=L"Red", ylabel=L"Green", zlabel=L"Blue",
        xlabeloffset=95,
        ylabeloffset=95,
        zlabeloffset=95,
        perspectiveness=0.0, # Nice orthographic view
        azimuth=azimuth*pi, elevation=elevation*pi,
    )
    xlims!(ax, 0, 1)
    ylims!(ax, 0, 1)
    zlims!(ax, 0, 1)

    scatter!(ax, 
        red_pixels, blue_pixels, green_pixels, 
        markersize=20,
        color=trans,
    )
    return fig
end

end # module BayesianImageAnalysis
