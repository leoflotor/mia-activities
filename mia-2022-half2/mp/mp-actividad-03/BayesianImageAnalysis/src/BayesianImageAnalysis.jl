module BayesianImageAnalysis

# ----------
# Required libraries
using Images                # Manipulation of images in general
using LinearAlgebra         # Matrix operations
using StatsBase: sample     # Only for random sampling
# using ImageInTerminal

# export avgVector, correlationMatrix, covarianceMatrix, gaussianDist, load

# ----------
# Aliases

tr = transpose


# ----------
# Dealing with pixel and images operations

pixelToVec(pixel) = [red(pixel), green(pixel), blue(pixel)] .|> Float64

imgPixels(img) = reduce(*, size(img))

randomPixelSampling(n, img) = sample(img, n, replace=false)


# -----------------
# Functions

avgVector(img) = sum(pixelToVec(pixel) for pixel in img) / imgPixels(img)

function covarianceMatrix(img, avg_vec)
    num = sum(
            (pixelToVec(pixel) - avg_vec) * tr(pixelToVec(pixel) - avg_vec) 
            for pixel in img)
    den = (imgPixels(img) - 1)
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

function gaussianDist(pixel, avg_vec, cov_mat)
    # This matrix should have the number of rows and cols
    dim = size(cov_mat)[1]
    exp_arg = (- tr(pixelToVec(pixel) - avg_vec) 
                * inv(cov_mat) 
                * (pixelToVec(pixel) - avg_vec) / 2)
    num = exp(exp_arg)
    den = (2 * pi)^(dim / 2) * sqrt(det(cov_mat))
    return num / den
end

function gaussianDist(pixel::Vector, avg_vec, cov_mat)
    # This matrix should have the number of rows and cols
    dim = size(cov_mat)[1]
    exp_arg = (- tr(pixel - avg_vec) 
                * inv(cov_mat) 
                * (pixel - avg_vec) / 2)
    num = exp(exp_arg)
    den = (2 * pi)^(dim / 2) * sqrt(det(cov_mat))
    return num / den
end

end # module
