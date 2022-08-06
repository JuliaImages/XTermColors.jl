module XTermColors

using ImageBase
using Crayons

import OffsetArrays: Origin

export ascii_display

include("colorant2ansi.jl")
include("ascii.jl")

const COLORMODE = Ref{TermColorDepth}(TermColor8bit())

"""
    set_colormode(bit::Int)

Sets the terminal color depth to the given argument.
"""
function set_colormode(bit::Int)
    if bit == 8
        COLORMODE[] = TermColor8bit()
    elseif bit == 24
        COLORMODE[] = TermColor24bit()
    else
        error("Setting color depth to $bit-bit is not supported, valid modes are:
          - 8bit (256 colors)
          - 24bit")
    end
    COLORMODE[]
end

is_24bit_supported() = lowercase(get(ENV, "COLORTERM", "")) in ("24bit", "truecolor")

function __init__()
    # use 24bit if the terminal supports it
    is_24bit_supported() && set_colormode(24)
end

end
