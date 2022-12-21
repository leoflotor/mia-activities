module TravellingSalesman

using Random
using Plots
using Combinatorics
using StatsBase


# Generate an initial visiting path order
# initial_guess(number_of_coords) = randcycle(number_of_coords)

function initial_guess()
    number_of_cities = 32
    cities = available_cities()
    visiting_order = randcycle(number_of_cities)
    return cities[visiting_order]
end

function sample_cities(n)
    cities = available_cities()
    return sample(cities, n, replace=false) 
end

function available_cities()
    # Coordinates from google maps
    cdmx = CoordCity("cdmx", 19.428262942477954, -99.13307482405206)
    puebla = CoordCity("puebla", 19.040822115386852, -98.20780804508925)
    guadalajara = CoordCity("guadalajara", 20.677308952193865, -103.34688257066186)
    monterrey = CoordCity("monterrey", 25.67766375433872, -100.31367653134096)
    chihuahua = CoordCity("chihuahua", 28.63688593294732, -106.07575156035638)
    merida = CoordCity("merida", 20.96767146389577, -89.62498156651586)
    saltillo = CoordCity("saltillo", 25.425170167352245, -101.00211644466016) 
    aguascalientes = CoordCity("aguascalientes", 21.882693391576726, -102.29651596173771)
    hermosillo = CoordCity("hermosillo", 29.081318106282477, -110.95317265344214)
    mexicali = CoordCity("mexicali", 32.62488966123241, -115.45331540638338)
    sanluispotosi = CoordCity("sanluispotosi", 22.152044624927726, -100.97754422094879)
    culiacan = CoordCity("culiacan", 24.808687010506628, -107.39416360809479)
    queretaro = CoordCity("queretaro", 20.592088731107133, -100.3918227421049)
    morelia = CoordCity("morelia", 19.702363913872365, -101.1923888816009)
    durango = CoordCity("durango", 24.024759761413552, -104.670261814078)
    tuxtla = CoordCity("tuxtla", 16.753312818180827, -93.11533318357856)
    xalapa = CoordCity("xalapa", 19.529942056424204, -96.92278227330834) 
    tepic = CoordCity("tepic", 21.51212649382402, -104.89139966235507)
    cuernavaca = CoordCity("cuernavaca", 18.92283171215841, -99.2354742591368)
    villahermosa = CoordCity("villahermosa", 17.989794162861205, -92.92869544177128)
    ciudadvictoria = CoordCity("ciudadvictoria", 23.73259400240757, -99.14904253088494)
    pachuca = CoordCity("pachuca", 20.124500636694673, -98.73481509992108)
    oaxaca = CoordCity("oaxaca", 17.062183511066106, -96.72572385123796)
    lapaz = CoordCity("lapaz", 24.161166099496494, -110.3129218770756)
    campeche = CoordCity("campeche", 19.844307251272554, -90.5362438879075)
    chilpancingo = CoordCity("chilpancingo", 17.55248920554459, -99.50078061701078)
    toluca = CoordCity("toluca", 19.29364749241578, -99.65372258157308)
    chetumal = CoordCity("chetumal", 18.50429901233981, -88.29533434224632)
    colima = CoordCity("colima", 19.24297973037111, -103.72824357123301)
    zacatecas = CoordCity("zacatecas", 22.772858479171045, -102.57341087527752)
    guanajuato = CoordCity("guanajuato", 21.016604105805193, -101.25401186103295)
    tlaxcala = CoordCity("tlaxcala", 19.314544474512967, -98.23851540921879)

    cities = [cdmx, puebla, guadalajara, monterrey, chihuahua, merida, saltillo, 
        aguascalientes, hermosillo, mexicali, sanluispotosi, culiacan, queretaro, 
        morelia, durango, tuxtla, xalapa, tepic, cuernavaca, villahermosa, 
        ciudadvictoria, pachuca, oaxaca, lapaz, campeche, chilpancingo, toluca, 
        chetumal, colima, zacatecas, guanajuato, tlaxcala]

    return cities
end

# Cartesian coordinates
mutable struct CoordCartesian
    x
    y
end

# Spherical coordinates using latitude and longitude
mutable struct CoordCity
    name    # city name
    lat     # [-π/2, π/2]
    lon     # [-π, π]
end

function distance_function(coordsystem) 
    f = Dict("cartesian" => cartesian_distance, "spherical" => spherical_distance)
    return f[coordsystem]
end

# Distance between two points -> ΔEnergy
cartesian_distance(pointa, pointb) = sqrt((pointb.x - pointa.x)^2 + (pointb.y - pointa.y)^2)

# Distance between two points
function spherical_distance(pointa, pointb)
    earth_radius = 6371    # Approx. radius in kilometres
    degtorad = π / 180

    φa, φb = pointa.lat, pointb.lat
    λa, λb = pointa.lon, pointb.lon
    (φa, φb, λa, λb) = (φa, φb, λa, λb) .* degtorad
    
    # Latitude and longitude differences
    Δφ = (φb - φa)
    Δλ = (λb - λa)

    # Haversine formula
    a = sin(Δφ / 2)^2 + cos(φa) * cos(φb) * sin(Δλ / 2)^2
    c = 2 * atan(sqrt(a), sqrt(1 - a))
    distance = earth_radius * c

    return distance
end

# Total distance of current path -> Path's Total Energy
function total_distance(coords, coordsystem)
    distfun = distance_function(coordsystem)

    dist = 0
    for (from, to) in zip(coords[begin:end-1], coords[begin+1:end])
        dist += distfun(from, to)
    end

    dist += distfun(coords[begin], coords[end])

    return dist
end

# Simple simulated annealing algorithm
function simulated_annealing(coords, coordsystem; init_temp=30, temp_factor=0.99)
    count_coords = length(coords)
    coords_ = deepcopy(coords)

    iterations = 1000
    inner_iter = 500

    cost0 = total_distance(coords_, coordsystem)    # Initial cost
    cost_per_iter = zeros(iterations+1)
    cost_per_iter[1] = cost0

    # Current temperature
    T = init_temp

    for iter = 1:iterations    # Why 1000?
        T = T * temp_factor

        for _ = 1:inner_iter    # Why 500?
            # Choose randomly which coordinates to swap
            r1, r2 = rand(1:count_coords, 2)
            # Swap coordinates
            coords_[r1], coords_[r2] = coords_[r2], coords_[r1]
            # Get new cost
            cost1 = total_distance(coords_, coordsystem)

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
        cost_per_iter[iter+1] = cost0
    end
    return coords_, cost_per_iter
end

function brute_force_1(coords, coordsystem)
    count_coords = length(coords)
    indexes_perms = permutations(1:count_coords, count_coords)
    coords_perms = map(x -> coords[x], indexes_perms)
    distances = total_distance.(coords_perms, coordsystem)
    min_distance = argmin(distances)
    return coords_perms[min_distance]
end

function brute_force_2(coords, coordsystem)
    count_coords = length(coords)
    perms_available = prod(1:count_coords)    # Equivalent to factorial
    perms = []
    for i in 1:perms_available
        perm = nthperm(coords, i)
        push!(perms, perm)
    end
    return perms
end

function brute_force_3(coords, coordsystem)
    count_coords = length(coords)
    perms_available = prod(1:count_coords)    # Equivalent to factorial
    perms = map(x -> nthperm(coords, x), 1:perms_available)    # Get all permutations
    return perms
end

end # module TravellingSalesman
