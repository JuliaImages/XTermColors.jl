# This file handles pixelwise conversion
abstract type TermColorDepth end

# ColorTypes is a "thin" packages that contains only the types definition. To support
# conversions between different color types, Colors.jl is required to be loaded.
@inline (enc::TermColorDepth)(c::Color) = enc(RGB(c))
@inline (enc::TermColorDepth)(c::TransparentColor) = enc(color(c))

"""
    TermColor256()

The RGB/Grayscale to/from xterm-256 color codes encoder. Other color types will be converted
to RGB first. The transparent alpha channel, if exists, will be dropped.

The `TermColor256` can be used as both an encoder and an decoder, depends on the input
types.

```jldoctest termcolor256; setup=:(using ImageCore; using XTermColors: TermColor256)
julia> enc = TermColor256()
TermColor256()

julia> enc(RGB(1.0, 1.0, 0.0)) # color -> xterm-256 color index
227

julia> enc(227) # xterm-256 color index -> color
RGB{N0f8}(1.0,1.0,0.0)
```

Note that decoder will always return RGB values:

```jldoctest termcolor256
julia> enc(Gray(0.5))
245

julia> enc(245)
RGB{N0f8}(0.502,0.502,0.502)
```
"""
struct TermColor256 <: TermColorDepth end
const TermColor8bit = TermColor256 # backward compat: it used to be TermColor8bit

# RGB -> xterm 256 color index
function (enc::TermColor256)(c::AbstractRGB)
    r, g, b = clamp01nan(red(c)), clamp01nan(green(c)), clamp01nan(blue(c))
    r24, g24, b24 = map(c -> round(Int, c * 23), (r, g, b))
    if r24 == g24 == b24
        # RGB scale color code
        r24 == 0 && return 17   # 0x000000
        r24 == 9 && return 60   # 0x5f5f5f
        r24 == 12 && return 103 # 0x878787
        r24 == 16 && return 146 # 0xafafaf
        r24 == 19 && return 189 # 0xd7d7d7
        r24 == 23 && return 232 # 0xffffff
        # gray scale color code
        232 + r24
    else
        r6, g6, b6 = map(c -> floor(Int, c * 5), (r, g, b))
        17 + 36 * r6 + 6 * g6 + b6
    end
end
# gray -> xterm 256 color index
function (enc::TermColor256)(c::AbstractGray)
    val = round(Int, clamp01nan(gray(c)) * 26)
    val == 0 && return 17   # 0x000000
    val > 24 && return 232  # 0xffffff
    return 232 + val
end
# xterm 256 color index -> RGB
@inline function (enc::TermColor256)(idx::Integer)
    return RGB(reinterpret(ARGB32, TERMCOLOR256_LOOKUP[idx]))
end

"""
    TermColor24bit()

The RGB/Grayscale to 24bit color (truecolor) codes encoder. Other color types will be
converted to RGB first. The transparent alpha channel, if exists, will be dropped.

The `TermColor24bit` can be used as both an encoder and an decoder, depends on the input
types.

```jldoctest termcolor24bit; setup=:(using ImageBase; using XTermColors: TermColor24bit)
julia> enc = TermColor24bit()
XTermColors.TermColor24bit()

julia> enc(RGB(1.0, 1.0, 0.0)) # color -> xterm-24bit color index
(255, 255, 0)

julia> enc(RGB(0.5, 0.5, 0.5)) # color -> xterm-24bit color index
(128, 128, 0)

julia> enc((255, 255, 0)) # xterm-24bit color index -> color
RGB{N0f8}(1.0,1.0,0.0)
```

Note that decoder will always return RGB values:

```jldoctest termcolor24bit
julia> enc(Gray(0.5))
(128, 128, 128)

julia> enc((128, 128, 128))
RGB{N0f8}(0.502,0.502,0.502)
```
"""
struct TermColor24bit <: TermColorDepth end

function (enc::TermColor24bit)(c::AbstractRGB)
    r, g, b = red(c), green(c), blue(c)
    map(c -> round(Int, clamp01nan(c) * 255), (r, g, b))
end

function (enc::TermColor24bit)(c::AbstractGray)
    r = round(Int, clamp01nan(real(c)) * 255)
    r, r, r
end

(enc::TermColor24bit)(c::NTuple{3,<:Integer}) = RGB(map(x -> N0f8(x / 255), c)...)
