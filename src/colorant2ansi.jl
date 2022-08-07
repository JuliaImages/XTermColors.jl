abstract type TermColorDepth end
struct TermColor8bit <: TermColorDepth end
struct TermColor24bit <: TermColorDepth end

clamped01_rgb(c::AbstractRGB) = clamp01nan.((red(c), green(c), blue(c)))
clamped01_rgb(c::Union{AbstractGray,Color{<:Any,1}}) = (r = clamp01nan(real(c)); (r, r, r))

"""
    colorant2ansi(color::Colorant) -> Int

Converts the given colorant into an integer index that corresponds
to the closest 256-colors ANSI code.

```julia
julia> colorant2ansi(RGB(1., 1., 0.))
226
```

This function also tries to make good use of the additional number
of available shades of gray (ANSI codes 232 to 255).

```julia
julia> colorant2ansi(RGB(.5, .5, .5))
244

julia> colorant2ansi(Gray(.5))
244
```
"""
colorant2ansi(color) = _colorant2ansi(color, TermColor8bit())

function _colorant2ansi(
    col::Union{AbstractRGB,AbstractGray,Color{<:Any,1}}, ::TermColor8bit
)
    r, g, b = rgb = clamped01_rgb(col)
    cube = 16 + 36trunc(Int, 5r) + 6trunc(Int, 5g) + trunc(Int, 5b)  # 216 colors levels: cube 6x6x6
    if r == g == b
        if r % 43 == 16  # prefer cube gray levels: 16, 59, 102, 145, 188, 231
            cube
        else
            232 + clamp(trunc(Int, (23 + 2)r), 0, 23)  # 24 gray levels + black + white = 26
        end
    else
        cube
    end
end
_colorant2ansi(col::Union{AbstractRGB,AbstractGray,Color{<:Any,1}}, ::TermColor24bit) =
    map(x -> round(Int, 255x), clamped01_rgb(col))

# Fallback for non-rgb and transparent colors (convert to rgb)
_colorant2ansi(col::Color, colordepth::TermColorDepth) =
    _colorant2ansi(convert(RGB, col), colordepth)
_colorant2ansi(col::TransparentColor, colordepth::TermColorDepth) =
    _colorant2ansi(color(col), colordepth)

(enc::TermColor8bit)(c::Union{Color,TransparentColor,AbstractRGB,AbstractGray}) =
    RGB(reinterpret(RGB24, TERMCOLOR256_LOOKUP[_colorant2ansi(c, enc)]))

(enc::TermColor24bit)(c::Union{Color,TransparentColor,AbstractRGB,AbstractGray}) = c

# https://www.ditig.com/256-colors-cheat-sheet
const TERMCOLOR256_LOOKUP = Origin(0)(
    [
        0x000000  # ↓ primary 3-bit (8 colors)
        0x800000
        0x008000
        0x808000
        0x000080
        0x800080
        0x008080
        0xc0c0c0
        0x808080  # ↓ equivalent "bright" versions of original 8 colors
        0xff0000
        0x00ff00
        0xffff00
        0x0000ff
        0xff00ff
        0x00ffff
        0xffffff
        0x000000  # ↓ strictly ascending - 6x6x6 cube = 216 colors
        0x00005f
        0x000087
        0x0000af
        0x0000d7
        0x0000ff
        0x005f00
        0x005f5f
        0x005f87
        0x005faf
        0x005fd7
        0x005fff
        0x008700
        0x00875f
        0x008787
        0x0087af
        0x0087d7
        0x0087ff
        0x00af00
        0x00af5f
        0x00af87
        0x00afaf
        0x00afd7
        0x00afff
        0x00d700
        0x00d75f
        0x00d787
        0x00d7af
        0x00d7d7
        0x00d7ff
        0x00ff00
        0x00ff5f
        0x00ff87
        0x00ffaf
        0x00ffd7
        0x00ffff
        0x5f0000
        0x5f005f
        0x5f0087
        0x5f00af
        0x5f00d7
        0x5f00ff
        0x5f5f00
        0x5f5f5f
        0x5f5f87
        0x5f5faf
        0x5f5fd7
        0x5f5fff
        0x5f8700
        0x5f875f
        0x5f8787
        0x5f87af
        0x5f87d7
        0x5f87ff
        0x5faf00
        0x5faf5f
        0x5faf87
        0x5fafaf
        0x5fafd7
        0x5fafff
        0x5fd700
        0x5fd75f
        0x5fd787
        0x5fd7af
        0x5fd7d7
        0x5fd7ff
        0x5fff00
        0x5fff5f
        0x5fff87
        0x5fffaf
        0x5fffd7
        0x5fffff
        0x870000
        0x87005f
        0x870087
        0x8700af
        0x8700d7
        0x8700ff
        0x875f00
        0x875f5f
        0x875f87
        0x875faf
        0x875fd7
        0x875fff
        0x878700
        0x87875f
        0x878787
        0x8787af
        0x8787d7
        0x8787ff
        0x87af00
        0x87af5f
        0x87af87
        0x87afaf
        0x87afd7
        0x87afff
        0x87d700
        0x87d75f
        0x87d787
        0x87d7af
        0x87d7d7
        0x87d7ff
        0x87ff00
        0x87ff5f
        0x87ff87
        0x87ffaf
        0x87ffd7
        0x87ffff
        0xaf0000
        0xaf005f
        0xaf0087
        0xaf00af
        0xaf00d7
        0xaf00ff
        0xaf5f00
        0xaf5f5f
        0xaf5f87
        0xaf5faf
        0xaf5fd7
        0xaf5fff
        0xaf8700
        0xaf875f
        0xaf8787
        0xaf87af
        0xaf87d7
        0xaf87ff
        0xafaf00
        0xafaf5f
        0xafaf87
        0xafafaf
        0xafafd7
        0xafafff
        0xafd700
        0xafd75f
        0xafd787
        0xafd7af
        0xafd7d7
        0xafd7ff
        0xafff00
        0xafff5f
        0xafff87
        0xafffaf
        0xafffd7
        0xafffff
        0xd70000
        0xd7005f
        0xd70087
        0xd700af
        0xd700d7
        0xd700ff
        0xd75f00
        0xd75f5f
        0xd75f87
        0xd75faf
        0xd75fd7
        0xd75fff
        0xd78700
        0xd7875f
        0xd78787
        0xd787af
        0xd787d7
        0xd787ff
        0xd7af00
        0xd7af5f
        0xd7af87
        0xd7afaf
        0xd7afd7
        0xd7afff
        0xd7d700
        0xd7d75f
        0xd7d787
        0xd7d7af
        0xd7d7d7
        0xd7d7ff
        0xd7ff00
        0xd7ff5f
        0xd7ff87
        0xd7ffaf
        0xd7ffd7
        0xd7ffff
        0xff0000
        0xff005f
        0xff0087
        0xff00af
        0xff00d7
        0xff00ff
        0xff5f00
        0xff5f5f
        0xff5f87
        0xff5faf
        0xff5fd7
        0xff5fff
        0xff8700
        0xff875f
        0xff8787
        0xff87af
        0xff87d7
        0xff87ff
        0xffaf00
        0xffaf5f
        0xffaf87
        0xffafaf
        0xffafd7
        0xffafff
        0xffd700
        0xffd75f
        0xffd787
        0xffd7af
        0xffd7d7
        0xffd7ff
        0xffff00
        0xffff5f
        0xffff87
        0xffffaf
        0xffffd7
        0xffffff
        0x080808  # ↓ gray-scale range
        0x121212
        0x1c1c1c
        0x262626
        0x303030
        0x3a3a3a
        0x444444
        0x4e4e4e
        0x585858
        0x626262
        0x6c6c6c
        0x767676
        0x808080
        0x8a8a8a
        0x949494
        0x9e9e9e
        0xa8a8a8
        0xb2b2b2
        0xbcbcbc
        0xc6c6c6
        0xd0d0d0
        0xdadada
        0xe4e4e4
        0xeeeeee
    ],
)
