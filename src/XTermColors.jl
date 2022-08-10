module XTermColors

using ImageBase
using Crayons

import OffsetArrays: Origin

export ascii_show

include("colorant2ansi.jl")
include("ascii.jl")

end
