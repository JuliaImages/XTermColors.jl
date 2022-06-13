abstract type ImageEncoder end
struct BigBlocks <: ImageEncoder
    size::NTuple{2, Int}
end
struct SmallBlocks <: ImageEncoder
    size::NTuple{2, Int}
end

const RESET = Crayon(reset = true)
const alpha_chars = ('⋅', '░', '▒', '▓', '█')

function _charof(alpha)
    idx = round(Int, alpha * (length(alpha_chars) - 1))
    alpha_chars[clamp(idx + 1, 1, length(alpha_chars))]
end

# bypassing Crayons.print() to avoid getenv() calls
function _printc(io::IO, x::Crayon, args...)
    # print(io, x, args...)  # slower
    if Crayons.anyactive(x)
        print(io, Crayons.CSI)
        Crayons._print(io, x)
        print(io, Crayons.END_ANSI)
        print(io, args...)
    end
end

"""
    xterm_encode([io::IO], enc::ImageEncoder, colordepth::TermColorDepth, img, [maxheight], [maxwidth])

Transforms the pixel of the given image `img`, which has to be an
array of `Colorant`, into a string of unicode characters using
ansi terminal colors or directly writes into a i/o stream.

- The encoder `enc` specifies which kind of unicode represenation
  should be used.

- The `colordepth` can either be `TermColor8bit()` or `TermColor24bit()`
  and specifies which terminal color codes should be used.

It `ret` is set, the function returns a vector of strings containing the encoded image.
Each element represent one line. The lines do not contain newline characters.
"""
function xterm_encode(
    io::IO,
    ::SmallBlocks,
    colordepth::TermColorDepth,
    img::AbstractMatrix{<:Colorant};
    trail_nl::Bool = false,
    ret::Bool = false
)
    yinds, xinds = axes(img)
    for y in first(yinds):2:last(yinds)
        _printc(io, RESET)
        for x in xinds
            fgcol = _colorant2ansi(img[y, x], colordepth)
            bgcol = if y+1 <= last(yinds)
                _colorant2ansi(img[y+1, x], colordepth)
            else
                # if reached it means that the last character row
                # has only the upper pixel defined.
                nothing
            end
            _printc(io, Crayon(foreground=fgcol, background=bgcol), "▀")
        end
        _printc(io, RESET)
        (trail_nl || y < last(yinds)) && println(io)
    end
    ret ? readlines(io) : nothing
end

function xterm_encode(
    io::IO,
    ::BigBlocks,
    colordepth::TermColorDepth,
    img::AbstractMatrix{<:Colorant};
    trail_nl::Bool = false,
    ret::Bool = false,
)
    yinds, xinds = axes(img)
    for y in yinds
        _printc(io, RESET)
        for x in xinds
            color = img[y, x]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            _printc(io, Crayon(foreground = fgcol), chr, chr)
        end
        _printc(io, RESET)
        (trail_nl || y < last(yinds)) && println(io)
    end
    ret ? readlines(io) : nothing
end

function xterm_encode(
    io::IO,
    ::SmallBlocks,
    colordepth::TermColorDepth,
    img::AbstractVector{<:Colorant};
    trail_nl::Bool = false,
    ret::Bool = false
)
    _printc(io, RESET)
    for i in axes(img, 1)
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        _printc(io, Crayon(foreground = fgcol), chr)
    end
    _printc(io, RESET)
    trail_nl && println(io)
    ret ? readlines(io) : nothing
end

function xterm_encode(
    io::IO,
    enc::BigBlocks,
    colordepth::TermColorDepth,
    img::AbstractVector{<:Colorant};
    trail_nl::Bool = false,
    ret::Bool = false
)
    w = length(img)
    n = enc.size[2] ÷ 3 == w ? w : enc.size[2] ÷ 6
    # left or full
    _printc(io, RESET)
    for i in (0:n-1) .+ firstindex(img)
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        _printc(io, Crayon(foreground = fgcol), chr, chr, " ")
    end
    if n < w  # right part
        _printc(io, RESET, " … ")
        for i in (-n+1:0) .+ lastindex(img)
            color = img[i]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            _printc(io, Crayon(foreground = fgcol), chr, chr, " ")
        end
    end
    _printc(io, RESET)
    trail_nl && println(io)
    ret ? readlines(io) : nothing
end

xterm_24bit_encode(io::IO, enc::ImageEncoder, args...; kw...) =
    xterm_encode(io, enc, TermColor24bit(), args...; kw...)

xterm_8bit_encode(io::IO, enc::ImageEncoder, args...; kw...) =
    xterm_encode(io, enc, TermColor8bit(), args...; kw...)

# use a `PipeBuffer` as io and returns encoded data reading lines of this buffer (using `readlines(io)`)
xterm_24bit_encode(enc::ImageEncoder, args...; kw...) =
    xterm_encode(PipeBuffer(), enc, TermColor24bit(), args...; ret = true, kw...)

xterm_8bit_encode(enc::ImageEncoder, args...; kw...) =
    xterm_encode(PipeBuffer(), enc, TermColor8bit(), args...; ret = true, kw...)