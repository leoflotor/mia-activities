module LR1Parser

"""
    TableEntry

Stores each entry of the parse table. Each entry corresponds to a usr defined value and its 
respective type which can be "shift", "redux" or "notype".

The first type corresponds to shift operations, the second type to reductions by
rewrite rules, and the third type is for entries that do not correspond to the first
two aforementioned types.
"""
struct TableEntry
    evalue    # Entry value
    etype    # Entry type
end

"""
    symbols(list_of_symbols)
    
From an ordered list of symbols create its respective dictionary to store their respective column indexes.
"""
symbols(list_of_symbols) = map(x -> [x[2], x[1]], enumerate(list_of_symbols)) |> Dict

"""
    table(number_of_nodes, number_of_symbols)

Creates an empty parse table to be filled by the usr.
"""
table(number_of_nodes, number_of_symbols) = Array{Any}(missing, number_of_nodes, number_of_symbols)

function parse_string(input_string, symbols, table)
    table = replace(x -> ismissing(x) ? TableEntry(missing, "notype") : x, table)

    string_ = split(input_string, "")
    
    # Early termination if a character in the input string is not part of the
    # alphabet of the grammar
    if !all(x -> x in keys(symbols), string_)
        error("One or more characters in the input string \"$(input_string)\" do not belong to the symbols $(keys(symbols)) of the grammar.")
    end

    append!(string_, ["eos"])
    stack = []
    
    token = 1
    pushfirst!(stack, token)
    symbol = popfirst!(string_)    # read first symbol and pop it out from string
    table_entry = table[token, symbols[symbol]]
    
    i = 2
    println("Iteration $(i-1): $(reverse(stack)) \n")
    println("Current symbol: $(symbol) \n")
    
    while !isequal(table_entry.evalue, "accept")
        if isequal(table_entry.evalue, missing)
            error("Value of current table entry [$(stack[begin]), \"$(symbol)\"] is missing/blank.")
        end
        if isequal(table_entry.etype, "shift")
            pushfirst!(stack, symbol)
            token = table_entry.evalue
            pushfirst!(stack, token)
            symbol = popfirst!(string_)

            println("Iteration $(i): $(reverse(stack)) \n")
            println("Current symbol: $(symbol) \n")
        end
        if isequal(table_entry.etype, "redux")
            rewrite_rule = table_entry.evalue
            left_side = rewrite_rule[1]    # The symbol to be substituted back into the stack
            right_side = rewrite_rule[2] |> x -> split(x, "")    # The symbols to be backtracked

            for rs_symbol in reverse(right_side)
                # This condition assumes that the right side of the rewrite rule is of 
                # the form A -> λ
                if !isequal(rs_symbol, "λ")
                    symbol_to_pop = stack[begin+1]    # First comes the node's number, and second is the symbol to pop

                    if !isequal(rs_symbol, symbol_to_pop)
                        error("A symbol from the current rewrite rule $(right_side) does not match the symbol \"$(symbol_to_pop)\" at the top of the stack.")
                    end

                    popfirst!(stack)    # To pop the table entry
                    popfirst!(stack)    # To pop the symbol
                end
            end

            token = stack[begin]    # Update token to the symbol at the top of the stack
            pushfirst!(stack, left_side)
            token = table[token, symbols[left_side]].evalue
            pushfirst!(stack, token)

            println("Iteration $(i): $(reverse(stack)) \n")
        end

        i += 1
        table_entry = table[token, symbols[symbol]]
    end

    if !isequal(symbol, "eos")
        return "Error, last symbol is \"$(symbol)\" but should be \"eos\"."
    end

    empty!(stack)
    println("The string \"$(input_string)\" was succesfully parsed.")
end

function grammar_two(input_string)
    # Test the grammar of the example seen in class:
    # S -> zMNz
    # M -> aMa
    # M -> z
    # N -> bNb
    # N -> z

    number_of_nodes = 14
    list_of_symbols = ["a", "b", "z", "eos", "S", "M", "N"]
    symbols_ = symbols(list_of_symbols)
    table_ = table(number_of_nodes, length(list_of_symbols))

    map_transitions!(symbol, symbol_transitions) = map(x -> table_[x[1], symbols_[symbol]] = TableEntry(x[2], x[3]) , symbol_transitions)

    a_transitions = [[2, 3, "shift"], 
                     [3, 3, "shift"], 
                     [7, ["M", "z"], "redux"], 
                     [8, 12, "shift"], 
                     [12, ["M", "aMa"], "redux"]]
   
    b_transitions = [[4, 5, "shift"], 
                     [5, 5, "shift"], 
                     [7, ["M", "z"], "redux"], 
                     [9, ["N", "z"], "redux"], 
                     [10, 13, "shift"], 
                     [12, ["M", "aMa"], "redux"], 
                     [13, ["N", "bNb"], "redux"]]

    z_transitions = [[1, 2, "shift"], 
                     [2, 7, "shift"], 
                     [3, 7, "shift"], 
                     [4, 9, "shift"], 
                     [5, 9, "shift"], 
                     [6, 11, "shift"], 
                     [7, ["M", "z"], "redux"], 
                     [9, ["N", "z"], "redux"], 
                     [12, ["M", "aMa"], "redux"], 
                     [13, ["N", "bNb"], "redux"]]

    eos_transitions = [[11, ["S", "zMNz"], "redux"], 
                       [14, "accept", "notype"]]

    S_transitions = [[1, 14, "notype"]]

    M_transitions = [[2, 4, "notype"], [3, 8, "notype"]]

    N_transitions = [[4, 6, "notype"], [5, 10, "notype"]]
    
    map_transitions!("a", a_transitions)
    map_transitions!("b", b_transitions)
    map_transitions!("z", z_transitions)
    map_transitions!("eos", eos_transitions)
    map_transitions!("S", S_transitions)
    map_transitions!("M", M_transitions)
    map_transitions!("N", N_transitions)

    parse_string(input_string, symbols_, table_)
end

function grammar_one(input_string)
    # Test the grammar corresponding to the project:
    # S -> xSz
    # S -> xyTyz
    # T -> λ

    number_of_nodes = 10
    list_of_symbols = ["x", "y", "z", "eos", "S", "T"]
    symbols_ = symbols(list_of_symbols)
    table_ = table(number_of_nodes, length(list_of_symbols))

    map_transitions!(symbol, symbol_transitions) = map(x -> table_[x[1], symbols_[symbol]] = TableEntry(x[2], x[3]) , symbol_transitions)

    x_transitions = [[1, 2, "shift"], 
                     [2, 2, "shift"]]
   
    y_transitions = [[2, 4, "shift"], 
                     [4, ["T", "λ"], "redux"],
                     [6, ["T", "λ"], "redux"], 
                     [7, 8, "shift"]]

    z_transitions = [[3, 5, "shift"], 
                     [5, ["S", "xSz"], "redux"], 
                     [8, 9, "shift"],
                     [9, ["S", "xyTyz"], "redux"]]

    eos_transitions = [[5, ["S", "xSz"], "redux"], 
                       [9, ["S", "xyTyz"], "redux"],
                       [10, "accept", "notype"]]

    S_transitions = [[1, 10, "notype"],
                     [2, 3, "notype"]]

    T_transitions = [[4, 7, "notype"]]
    
    map_transitions!("x", x_transitions)
    map_transitions!("y", y_transitions)
    map_transitions!("z", z_transitions)
    map_transitions!("eos", eos_transitions)
    map_transitions!("S", S_transitions)
    map_transitions!("T", T_transitions)

    parse_string(input_string, symbols_, table_)
end

end # module LR1Parser
