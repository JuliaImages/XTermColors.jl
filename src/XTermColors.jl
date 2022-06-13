module XTermColors

using ImageBase
using Crayons

export xterm_8bit_encode, xterm_24bit_encode
# export xterm_8bit_decode, xterm_24bit_decode

include("colorant2ansi.jl")
include("encoder.jl")
include("decoder.jl")

const colormode = Ref{TermColorDepth}(TermColor8bit())

"""
    set_colormode(bit::Int)

Sets the terminal color depth to the given argument.
"""
function set_colormode(bit::Int)
    if bit == 8
        colormode[] = TermColor8bit()
    elseif bit == 24
        colormode[] = TermColor24bit()
    else
        error("Setting color depth to $bit-bit is not supported, valid modes are:
          - 8bit (256 colors)
          - 24bit")
    end
    colormode[]
end

is_24bit_supported() = lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor")

function __init__()
    # use 24bit if the terminal supports it
    is_24bit_supported() && set_colormode(24)
end

end  # module
