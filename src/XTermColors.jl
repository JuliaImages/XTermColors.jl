module XTermColors

using ColorTypes
using ColorTypes: N0f8 # from FixedPointNumbers
using Crayons

export xterm_8bit_encode, xterm_24bit_encode
# export xterm_8bit_decode, xterm_24bit_decode

include("colors.jl")
include("encoder.jl")
include("decoder.jl")
include("utils.jl")
include("lookups.jl")

end  # module
