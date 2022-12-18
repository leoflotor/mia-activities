module TravellingSalesman

using Random
using Plots

# export Plots

# cities_xvals = [0.0 1.0 2.0 3.0 3.0 3.0 3.0 2.0 1.0 0.0 0.0 0.0]
# cities_yvals = [0.0 0.0 0.0 0.0 1.0 2.0 3.0 3.0 3.0 3.0 2.0 1.0]

mutable struct Coordinate
    x
    y
end

# Generate an initial visiting path order
initial_guess(number_of_cities) = Random.randcycle(number_of_cities)

# Distance between two points -> ΔEnergy
get_distance(pointa, pointb) = sqrt((pointa.x - pointb.x)^2 + (pointa.y - pointb.y)^2)

# Total distance of current path -> Path's Total Energy
function get_total_distance(coords)
    dist = 0

    for (first, second) in zip(coords[begin:end-1], coords[begin+1:end])
        dist += get_distance(first, second)
    end

    dist += get_distance(coords[begin], coords[end])

    return dist
end

# Simple simulated annealing algorithm
function simulated_annealing(coords, init_temp, temp_factor)
    count_coords = length(coords)
    coords_ = coords

    # Initial cost
    cost0 = get_total_distance(coords_)

    # Current temperature
    T = init_temp

    for i in 1:1000
        T = T * temp_factor
        for j in 1:500
            # Choose randomly which coordinates to swap
            r1, r2 = Random.rand(1:count_coords, 2)
            # Swap coordinates
            coords_[r1], coords_[r2] = coords_[r2], coords_[r1]
            # Get new cost
            cost1 = get_total_distance(coords_)
            if cost1 < cost0
                cost0 = cost1
            else
                # If current cost is not better then gamble! The system can still 
                # change with some probability
                probability = rand()
                if probability < exp((cost0 - cost1) / T)
                    cost0 = cost1
                else
                    # If still probability doesnt play into our favor, then undo 
                    # the swap
                    coords_[r1], coords_[r2] = coords_[r2], coords_[r1]
                end
            end
        end
    end
    return coords_
end

end # module TravellingSalesman
