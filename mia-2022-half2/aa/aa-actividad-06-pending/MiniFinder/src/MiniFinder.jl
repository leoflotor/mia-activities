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

Eros in cursus turpis massa. Dui faucibus in ornare quam viverra orci sagittis eu volutpat. Lacus sed viverra tellus in hac habitasse platea dictumst vestibulum. Platea dictumst quisque sagittis purus sit. Id ornare arcu odio ut sem nulla pharetra diam sit. Ultrices vitae auctor eu augue ut lectus arcu bibendum at. Amet commodo nulla facilisi nullam vehicula ipsum a arcu cursus. Consequat interdum varius sit amet mattis vulputate enim. Pellentesque dignissim enim sit amet venenatis. Libero enim sed faucibus turpis in eu mi. Mi tempus imperdiet nulla malesuada pellentesque.

Sem fringilla ut morbi tincidunt augue. Eu tincidunt tortor aliquam nulla facilisi cras fermentum odio. Commodo elit at imperdiet dui accumsan. Auctor augue mauris augue neque. Faucibus scelerisque eleifend donec pretium. Vitae aliquet nec ullamcorper sit amet risus nullam eget felis. Eget gravida cum sociis natoque penatibus et. Aliquam ultrices sagittis orci a scelerisque purus semper eget duis. Lectus mauris ultrices eros in cursus turpis massa. Fringilla ut morbi tincidunt augue interdum velit euismod in pellentesque. Morbi tincidunt augue interdum velit euismod in pellentesque massa placerat. Facilisis sed odio morbi quis commodo odio aenean. Eget nunc scelerisque viverra mauris in aliquam sem fringilla. Est pellentesque elit ullamcorper dignissim cras tincidunt lobortis. Scelerisque mauris pellentesque pulvinar pellentesque habitant morbi tristique.

Massa placerat duis ultricies lacus sed turpis tincidunt. Sit amet nisl purus in mollis nunc sed. Viverra accumsan in nisl nisi scelerisque eu ultrices vitae auctor. Malesuada pellentesque elit eget gravida cum sociis. Quis imperdiet massa tincidunt nunc pulvinar. Sapien faucibus et molestie ac. Gravida in fermentum et sollicitudin ac orci phasellus egestas tellus. Ac turpis egestas sed tempus urna et pharetra pharetra massa. Tellus mauris a diam maecenas sed enim ut sem viverra. Amet cursus sit amet dictum sit amet justo. Vitae semper quis lectus nulla at volutpat diam ut. Molestie nunc non blandit massa enim nec dui nunc. Quis hendrerit dolor magna eget. Ornare arcu dui vivamus arcu felis. Mattis nunc sed blandit libero. Mauris a diam maecenas sed enim ut sem viverra aliquet. Duis convallis convallis tellus id interdum velit laoreet id. Enim sed faucibus turpis in eu mi bibendum neque. Rutrum tellus pellentesque eu tincidunt tortor aliquam nulla facilisi.

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
    # occurlist = Vector{Tuple}[]

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

# function occurrencesInLine(line, pattern)
#     patternlength = length(pattern)

#     occurlist = [0]
#     # findit = 0
#     occurrence = 0

#     while occurrence != -1 # && patternlength <= length(line)
#         # findit = horspool(line, pattern)
#         # occurrence = findit + 1
#         occurrence = horspool(line, pattern)
#         
#         if occurrence == -1
#             break
#         end

#         append!(occurlist, occurrence + occurlist[end])
#         
#         if occurrence + patternlength > length(line)
#             break
#         end

#         line = line[begin+occurrence+patternlength:end]
#         println(line)
#     end

#     return occurlist
# end

# function occurrenceDict(textstr)
#     lastocc = Dict()

#     for (i, char) in enumerate(textstr[begin:end-1])
#         lastocc[char] = i
#     end

#     return lastocc
# end

# function horspool2(textstring, pattern)
#     lastocc = occurrenceDict(pattern)
#     
#     # Falta implementar
#     return lastocc
# end

end # module MiniFinder
