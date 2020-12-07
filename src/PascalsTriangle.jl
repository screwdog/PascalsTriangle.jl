module PascalsTriangle

# Exceptions
export OutOfBoundsError, NonAdjacentError

# Types
export Entry, Row, Column
export Centre, Center, LazyCentre, LazyCenter

# Accessors
export rownumber, rowposition, colnumber, value

# Checks
export isfirst, isatleft, isatright, isadjacent, areadjacent
export isinterior, issubtractable, aresubtractable, isvalid

# Conversion
export toarray

# Modifiers
export up, down, left, right, prev, next
export up!, down!, left!, right!, prev!, next!

include("docstrings.jl")
include("exceptions.jl")
include("entries.jl")
include("rows.jl")
include("columns.jl")
include("centres.jl")
include("movement.jl")

end # of module