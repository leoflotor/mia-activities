module ShortestPath

#==============================
Required libraries
===============================#

using Images
using Plots


function canvasRGB(nrows, ncols)
    cv = ones(RGB, nrows, ncols)

    return plot(cv)
end


function adjacencyMatrix(nrows, ncols; obstacles=nothing, allowdiags=false)
    ns = nrows * ncols          # neighborhood size
    ids = 1:ns                  # neighbors ids
    adjmat = zeros(ns, ns)
    diagstepsize = sqrt(2)      # diagonal step size
    
    # remove obstacles from ids if obstacles are given
    available = isnothing(obstacles) || isempty(obstacles) ? 
                ids : setdiff(ids, obstacles)

    for id in available
        # neighbor right = left = 1
        if !iszero(id % ncols)
            adjmat[id, id + 1] = adjmat[id + 1, id] = 1
            # adjmat[id, id + 1] = 1
        end

        # neighbor below = above = 1
        if id <= ncols * (nrows - 1)
            adjmat[id, id + ncols] = adjmat[id + ncols, id] = 1
            # adjmat[id, id + ncols] = 1
        end
            
        if allowdiags
            # neighbor down-right = up-left = √2
            if !iszero(id % ncols) && id <= ncols * (nrows - 1)
                adjmat[id, id + ncols + 1] = adjmat[id + ncols + 1, id] = diagstepsize
                # adjmat[id, id + ncols + 1] = diagstepsize
            end

            # neighbor down-left = up-right = √2
            if !iszero((id - 1) % ncols) && id <= ncols * (nrows - 1)
                adjmat[id, id + ncols - 1] = adjmat[id + ncols - 1, id] = diagstepsize
                # adjmat[id, id + ncols - 1] = diagstepsize
            end
        end
    end

    return adjmat
end


function findAll(adjmat; start=start, finish=nothing)
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


end # module ShortestPath
