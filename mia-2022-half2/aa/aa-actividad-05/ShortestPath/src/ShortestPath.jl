module ShortestPath

# NOTE: There are strange cases where findAll does not work.

#==============================
Required libraries
===============================#

using Images
using Plots
using StatsBase: sample


#==============================
Image operations
===============================#


function visualize(neighborhood)
    fig = plot(neighborhood, 
        ticks=false, 
        xaxis=false, yaxis=false,
        background_color=:transparent,
        foreground_color=:black,
    )
    return fig
end

#==============================
Map generation and operations
===============================#

id(row, col, ncols) = col + ncols * (row - 1)


function posbyid(id::Int, ncols::Int)
    col = iszero(id % ncols) ? ncols : id % ncols
    row = 1 + (id - col) / ncols |> Int
    return row, col
end


function neighborhood(nrows::Int, ncols::Int; 
    start=nothing, finish=nothing, obsdensity=0
)
    obsdensity = obsdensity * nrows * ncols |> round |> Int
    obscolor = RGB(0.70196, 0.18039, 0.41568)
    canvas = zeros(RGB, nrows, ncols)
    
    start = !isnothing(start) ? CartesianIndex(start[1], start[2]) : []
    finish = !isnothing(finish) ? CartesianIndex(finish[1], finish[2]) : []

    available = setdiff(CartesianIndices(canvas), [start, finish])
    obstacles = sample(available, obsdensity, replace=false)

    canvas[[obstacles...]] .= obscolor
    
    obstacles = obstacles .|> x -> id(x[1], x[2], ncols)
    sort!(obstacles)

    return canvas, obstacles
end


function updateneighborhood!(neighborhood, path)
    ncols = size(neighborhood)[2]
    pathcoordinates = posbyid.(path, ncols) .|> x -> CartesianIndex(x)

    neighborhood[pathcoordinates[1]] = RGB(169/255, 182/255, 101/255)
    neighborhood[pathcoordinates[end]] = RGB(234/255, 105/255, 98/255)
    neighborhood[pathcoordinates[begin+1:end-1]] .= RGB(247/255, 199/255, 154/255)
end


#==============================
Neighbors and path finding
===============================#

function adjacencyMatrix(nrows, ncols; 
    obstacles=nothing, allowdiags=false
)
    ns = nrows * ncols          # neighborhood size
    ids = 1:ns                  # neighbors ids
    adjmat = zeros(ns, ns)
    diagstepsize = sqrt(2)      # diagonal step size
    
    for id in ids
        # neighbor to the right
        if !iszero(id % ncols)
            # adjmat[id, id + 1] = adjmat[id + 1, id] = 1
            adjmat[id, id + 1] = 1
        end
        # neighbor to the left
        if !iszero((id - 1) % ncols)
            adjmat[id, id - 1] = 1
        end
        # neighbor above
        if id > ncols
            adjmat[id, id - ncols] = 1
        end
        # neighbor below
        if id <= ncols * (nrows - 1)
            # adjmat[id, id + ncols] = adjmat[id + ncols, id] = 1
            adjmat[id, id + ncols] = 1
        end
            
        if allowdiags
            #neighbor up-right
            if !iszero(id % ncols) && id > ncols
                adjmat[id, id - ncols + 1] = diagstepsize
            end
            # neighbor up-left
            if !iszero((id - 1) % ncols) && id > ncols
                adjmat[id, id - ncols - 1] = diagstepsize
            end
            # neighbor down-right
            if !iszero(id % ncols) && id <= ncols * (nrows - 1)
                # adjmat[id, id + ncols + 1] = adjmat[id + ncols + 1, id] = diagstepsize
                adjmat[id, id + ncols + 1] = diagstepsize
            end
            # neighbor down-left
            if !iszero((id - 1) % ncols) && id <= ncols * (nrows - 1)
                # adjmat[id, id + ncols - 1] = adjmat[id + ncols - 1, id] = diagstepsize
                adjmat[id, id + ncols - 1] = diagstepsize
            end
        end
    end
    
    # Removing obstacles from being part of the neighborhood
    for id in obstacles
        adjmat[:, id] .= 0.0
        adjmat[id, :] .= 0.0
    end

    return adjmat
end


function findAll(adjmat; 
    start::Int=start, finish=nothing
)
    n = size(adjmat)[1]            # number of nodes

    dist = ones(n) * Inf            # all distances are initialized to inf
    dist[start] = adjmat[start, start]
    
    visited = BitArray(undef, n)    # bitarray to represent visited nodes initialized all as false
    # visited = [false for _ in 1:n]
    parent = ones(n) * (-1)
    path = fill(Int[], n)
    # path = [[] for _ in 1:n]

    for _ in 1:n-1
        minix = Inf
        u = 1
        
        for v in 1:n
            if iszero(visited[v]) && dist[v] <= minix
                minix = dist[v]
                u = v
            end
        end

        visited[u] = true

        for v in 1:n
            if (iszero(visited[v]) && !iszero(adjmat[u,v]) 
                && dist[u] + adjmat[u,v] < dist[v])
                parent[v] = u
                dist[v] = dist[u] + adjmat[u,v]
            end
        end
    end

    for i in 1:n
        j = i
        s = []

        while parent[j] != -1
            append!(s, j)
            j = parent[j] |> Int
        end

        append!(s, start)
        path[i] = s |> reverse
    end

    if !isnothing(finish)
        return dist[finish], path[finish]
    end

    return dist, path
end


function doit(nrows, ncols, start, finish, density, diags)
    # nrows = 7
    # ncols = 11

    # start = [6,1]
    # finish = [2,10]

    startid = id(start[1], start[2], ncols)
    finishid = id(finish[1], finish[2], ncols)

    idmat = [i for i in 1:(ncols*nrows)] |> x -> reshape(x, ncols, nrows) |> transpose
    nh, obs = neighborhood(nrows, ncols; start=start, finish=finish, obsdensity=density)

    adjmat = adjacencyMatrix(nrows, ncols; obstacles=obs, allowdiags=diags)
    dist, path = findAll(adjmat; start=startid, finish=finishid)

    updateneighborhood!(nh, path)
    visualize(nh)

    return dist, path, nh, idmat, adjmat, startid, finishid
end

# julia> dist, path, nh, idmat, adjmat, sid, fid 
# = sp.doit(40, 40, [4,1], [35,37], 0.1, false); sp.plot(nh)
    
end # module ShortestPath
