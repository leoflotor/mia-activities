module MiniFinder

function computeLastOcc(textstring)
   lastOcc = ones(Int, 128) .* -1    # all to -1

   for i in 1:(length(textstring) - 1)
       lastOcc[Int(textstring[i]) + 1] = i
   end

   return lastOcc
end

function horspool(textstring, pattern)
    # T -> textstring
    # P -> pattern
    
    n = length(textstring)
    m = length(pattern)
    lastOcc = computeLastOcc(pattern)
    
    i0 = 1
    while i0 <= n - m
        j = m - 0   # Start at the last char in the pattern
    
        # When the last char in the pattern is found, iterate over all chars and
        # compare to see if all match.
        while Int(pattern[j]) == Int(textstring[i0 + j])
            j = j - 1

            if j < 1
                return i0
            end
        end

        i0 = i0 + (m - 0) - lastOcc[Int(textstring[i0 + (m - 0)])]
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

# function horspool(textstr, pattern)
#     lastocc = computeLastOccurrence(pattern)
#     
#     n = length(textstr)
#     m = length(pattern)
#     r = []

#     k = m - 1
#     j = m - 1
#     while k < n
#         if j < 1
#             append!(r, k - m + 1)
#             j = m - 1
#             k += 1

#             if k >= n
#                 break
#             end
#         end
#         
#         if textstr[k - (m-1-j)] == pattern[j]
#             j = j - 1
#         else
#             k = k + (m - 1 - lastocc[textstr[k]])
#             j = m - 1
#         end
#     end

#     return r
# end

end # module MiniFinder
