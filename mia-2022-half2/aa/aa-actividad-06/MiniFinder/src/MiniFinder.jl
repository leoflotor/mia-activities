module MiniFinder

using OffsetArrays    # To create arrays with first index equal to zero.

#=
Important notes

Link to Horspool algorithm explanation
- http://www.cs.emory.edu/~cheung/Courses/253/Syllabus/Text/Matching-Boyer-Moore2.html

Link of available ascii characters:
- https://www.rapidtables.com/code/text/ascii-table.html

How to 0-base index in Julia?
- https://medium.com/analytics-vidhya/0-based-indexing-a-julia-how-to-43578c780c37

Normalize entry lines
julia> Base.Unicode.normalize("día?= ~", stripmark=true, stripcc=true)

How to not use OffsetVectors?
How to use a dictionary for the ocurrence table?
=#

function occurrenceTable(textstring)
    # T -> textstring

    # textstring = isa(textstring, String) ? split(textstring, "") : textstring
    textstring = split(textstring, "")
    ascii = 256 # 128 # 256    # How many allowed ascii characters? There are 255 in total.

    T = OffsetVector(textstring, 0:(length(textstring)-1))
    lastocc = OffsetVector(ones(Int, ascii) .* -1, 0:(ascii-1))    # Initialize all to -1.

    for i in 0:(length(T)-1-1)    # Antes solo estana considerando un menos 1
        lastocc[Int(T[i][1])] = i
    end

    return lastocc
end

function horspool(textstring, pattern)
    # T -> textstring
    # P -> pattern
    
    # Dont even attempt it if the length of the textstring is smaller than
    # the length of the pattern.
    if length(textstring) < length(pattern)
        return -1
    end

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
                return i0    # Starts indexing at 0
            end
        end

        i0 = i0 + (m - 1) - lastocc[Int(T[i0 + (m - 1)][1])]
    end

    return -1
end

function occurrencesInLine(line, pattern)
    patternlength = length(pattern)
    linelength = length(line)

    line_ = line

    occurrencelist = []
    occurrence = 0
    currentpos = 1
    
    while length(line_) >= patternlength
    # while occurrence != -1
        occurrence = horspool(line_, pattern)

        if occurrence == -1
            break
        end
        
        append!(occurrencelist, occurrence + currentpos)
        currentpos = currentpos + occurrence + patternlength
        
        if currentpos + patternlength > linelength
            break
        end

        line_ = line[currentpos:end]
        # println(line_)
    end
    
    return occurrencelist
end

function occurrencesInFile(file, pattern)
    occurlist = []

    open(file, "r") do io
        for (index, line) in enumerate(eachline(io))
            line_ = lowercase(line)
            occurrences = occurrencesInLine(lowercase(line_), pattern)

            if !isempty(occurrences)
                # push!(occurlist, (index, occurrences))
                occurrencesintuples = map(x -> (index, x), occurrences)
                append!(occurlist, occurrencesintuples)
            end
        end
    end

    if isempty(occurlist)
        println("No occurrences of \"$(pattern)\" where detected in \"$(file)\".")
    end
    return occurlist
end

function occurrencesInDirectory(directory, pattern)
    files = readdir(directory)
    occurdict = Dict()

    for file in files
        filename = findlast('.', file) |> x -> file[begin:x-1]    # remove extension from file name
        occurrences = occurrencesInFile(directory * file, pattern)

        occurdict[filename] = occurrences
    end
    return occurdict
end

function wordCountInFile(io)
    countbyword = Dict{String,Int}()
    totalwordcount = 0
    punctuationmarks = " .,:;-'!?"
    
    for line in eachline(io), word in split(line, in(punctuationmarks))    # Add punctuation symbols as needed
        lword = lowercase(word)
        countbyword[lword] = get(countbyword, lword, 0) + 1
        totalwordcount += 1
    end

    countbyword, totalwordcount
end

function wordCountInFile_(io, counter=Dict{String,Int}())
    for line in eachline(io), word in split(lowercase(line), !in('a':'z'))    # Add punctuation symbols as needed
        counter[word] = get(counter, word, 0) + 1
    end

    counter
end

function wordCountInDirectory(directory, pattern)
    files = readdir(directory)
    collection = []

    for file in files
        filename = findlast('.', file) |> x -> file[begin:x-1]    # remove extension from file name
        countbyword, totalwordcount = wordCountInFile(directory * file)
        patterncount = get(countbyword, pattern, -1)
        # density = !isequal(patterncount, -1) ? patterncount / totalwordcount : -1
        
        if patterncount != -1
            density = patterncount / totalwordcount
            push!(collection, (patterncount, density, filename))
        end
    end

    return collection
end

"""
    sortCollection(collection, sortby)

Sorts a vector of (wordcount, density, book) by wordcount or density in
descending order.
"""
function sortCollection(collection, sortby)
    options = Dict("wordcount" => 1, "density" => 2)
    option = get(options, sortby, -1)

    if !isequal(option, -1)
        return sort(collection, by = x -> x[option], rev=true)
    end
end

function specialSort(collection)
    # Revome from collection elements without the pattern, i.e., word count and 
    # density equal to -1
    collection = filter(x -> (x[1] != -1 && x[2] != -2), collection)
    n = length(collection)

    wordcount = map(x -> x[1], collection)
    density = map(x -> x[2], collection)

    for i in 1:n
        for j in 1:n
            if wordcount[i] < wordcount[j]
                wordcount[i], wordcount[j] = wordcount[j], wordcount[i]
                density[i], density[j] = density[j], density[i]
                collection[i], collection[j] = collection[j], collection[i]
            end 
            if wordcount[i] == wordcount[j]
                newi, newj = density[i] < density[j] ? (j, i) : (i, j)   # index by density comparisson
                
                wordcount[i], wordcount[j] = wordcount[newj], wordcount[newi]
                density[i], density[j] = density[newj], density[newi]
                collection[i], collection[j] = collection[newj], collection[newi]
            end 
        end
    end

    return collection
end

# function occurrenceDict(textstr)
#     lastocc = Dict()

#     for (i, char) in enumerate(textstr[begin:end-1])
#         lastocc[char] = i
#     end

#     return lastocc
# end

end # module MiniFinder
