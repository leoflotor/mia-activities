module SkinDetection

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

pixelToVec(pixel) = [red(pixel), green(pixel), blue(pixel)] .|> Float64

imgPixelCount(img) = reduce(*, size(img))

randomPixelSampling(img, n) = sample(img, n, replace=false)

uniquePixels(img) = unique(img)


function rawPixelIndexes(img)
    skin = []
    bg = []

    dims = size(img)
    scene = Scene(camera=campixel!, raw=true, resolution=(dims[2], dims[1]))
    image!(scene, rotr90(img))
    display(scene)
    
    println("Select several pixels from skin and the background.")
    println("Left-click for skin.")
    println("Right-cligk for not-skin.")

    # get coordinates on demand
    on(events(scene).mousebutton, priority=0) do event
        if event.button == Mouse.left
            skinxy = scene.events.mouseposition[]
            skinrow = - skinxy[2] + dims[1] + 1
            skincol = skinxy[1]
            push!(skin, [skinrow, skincol])
            println("Skin ", [skinrow, skincol])
        end

        if event.button == Mouse.right
            bgxy = scene.events.mouseposition[]
            bgrow = - bgxy[2] + dims[1] + 1
            bgcol = bgxy[1]
            push!(bg, [bgrow, bgcol])
            println("BG ", [bgrow, bgcol])
        end
    end

    return (skin = skin, bg = bg)
end


function filterPixelIndexes(rawcoordinates, npixels)
    skin = rawcoordinates.skin
    bg = rawcoordinates.bg

    unique!(skin)
    unique!(bg)

    skin = skin .|> x -> [Int(x[1]), Int(x[2])]
    bg = bg .|> x -> [Int(x[1]), Int(x[2])]

    return (
        skin = randomPixelSampling(skin, npixels), 
        bg = randomPixelSampling(bg, npixels))
end


function pixelSet(coordinates, img)
    skin = coordinates.skin .|> x -> img[x[1], x[2]]
    bg = coordinates.bg .|> x -> img[x[1], x[2]]

    return (skin = skin, bg = bg)
end


function heatMaps(skindist, bgdist; rev=true)
    cmap = :RdPu # :PuRd
    cmap = rev ? Reverse(cmap) : cmap # :RdYlBu :PuRd
    skin, ax1 = heatmap(skindist |> x -> rotr90(x), colormap=cmap)
    bg, ax2 = heatmap(bgdist |> x -> rotr90(x), colormap=cmap)

    hidedecorations!(ax1)
    hidedecorations!(ax2)

    return (skin=skin, bg=bg)
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


end # module SkinDetection
