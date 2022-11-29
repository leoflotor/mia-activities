module ShortestPath

# NOTE: There are strange cases where findAll does not work.

#==============================
Required libraries
===============================#

using Images
using Plots
using StatsBase: sample
using Graphs: dijkstra_shortest_paths
using SimpleWeightedGraphs: SimpleWeightedGraph


#==============================
Image operations
===============================#


function visualize(neighborhood; size=(600,600))
    fig = plot(neighborhood, 
        ticks = false, 
        axis = false,
        background_color = :transparent,
        foreground_color = :black,
        size = size,
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


function findPath(adjmat, ncols; start=start, finish=finish)
    startid = start |> x -> id(x[1], x[2], ncols)
    finishid = finish |> x -> id(x[1], x[2], ncols)

    graph = SimpleWeightedGraph(adjmat) # A weighted graph is needed
    dijkstra = dijkstra_shortest_paths(graph, startid)
    
    path_nodes = []
    node = finishid
    distance = dijkstra.dists[finishid]
    while node != 0
        append!(path_nodes, node)
        node = dijkstra.parents[node]
    end
    
    return path_nodes, distance
end


end # module ShortestPath
