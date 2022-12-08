module MiniFinder

using OffsetArrays    # To create arrays with first index equal to zero.

#=
Important notes

Link of available ascii characters:
- https://www.rapidtables.com/code/text/ascii-table.html

How to 0-base index in Julia?
- https://medium.com/analytics-vidhya/0-based-indexing-a-julia-how-to-43578c780c37

How to not use OffsetVectors?
How to use a dictionary for the ocurrence table?
=#

function occurrenceTable(textstring)
    # T -> textstring

    # textstring = isa(textstring, String) ? split(textstring, "") : textstring
    textstring = split(textstring, "")
    ascii = 256    # How many allowed ascii characters? There are 255 in total.

    T = OffsetVector(textstring, 0:(length(textstring)-1))
    lastocc = OffsetVector(ones(Int, ascii) .* -1, 0:(ascii-1))    # Initialize all to -1.

    for i in 0:(length(T) - 1)
        lastocc[Int(T[i][1])] = i
    end

    return lastocc
end

function horspool(textstring, pattern)
    # T -> textstring
    # P -> pattern

    lastocc = occurrenceTable(pattern)
    textstring = split(textstring, "")
    pattern = split(pattern, "")

    T = OffsetVector(textstring, 0:length(textstring)-1)
    P = OffsetVector(pattern, 0:length(pattern)-1)
    
    n = length(T)
    m = length(P)
    
    i0 = 0

    while i0 <= n - m
        j = m - 1   # Start at the last char in the pattern

        # When the last char in the pattern is found, iterate over all chars and
        # compare to see if all match.
        while Int(P[j][1]) == Int(T[i0 + j][1])
            j = j - 1

            if j < 0
                return i0
            end
        end

        i0 = i0 + (m - 1) - lastocc[Int(T[i0 + (m - 1)][1])]
    end

    return -1
end

# function computeLastOccurrence(textstr)
#     lastocc = Dict()

#     for (i, char) in enumerate(textstr[begin:end-1])
#         lastocc[char] = i
#     end

#     return lastocc
# end

end # module MiniFinder
