abstract type ImageEncoder end
struct BigBlocks <: ImageEncoder
    size::NTuple{2,Int}
end
struct SmallBlocks <: ImageEncoder
    size::NTuple{2,Int}
end

const ALPHA_CHARS = Ref(('⋅', '░', '▒', '▓', '█'))
const RESET = Crayon(; reset=true)

function _charof(alpha)
    alpha_chars = ALPHA_CHARS[]
    nc = length(alpha_chars)
    idx = round(Int, alpha * (nc - 1))
    alpha_chars[clamp(idx + 1, 1, nc)]
end

function _downscale_small(img::AbstractMatrix{<:Colorant}, maxsize::NTuple{2,Int})
    #=
    larger images are downscaled automatically using `restrict`.
    `maxheight` and `maxwidth` specify the maximum numbers of string characters
    that should be used for the resulting image.
    Returns
        1. Downscaled image
        2. Selected encoder (big or small blocks) with `size` containing:
            a. number of lines in the Vector{String}.
            b. number of visible characters per line (the remaining are colorcodes).
    =#
    maxheight, maxwidth = max.(maxsize, 5)
    h, w = size(img)
    while ceil(h / 2) > maxheight || w > maxwidth
        img = restrict(img)
        h, w = size(img)
    end
    img, SmallBlocks((length(1:2:h), w))
end

function _downscale_big(img::AbstractMatrix{<:Colorant}, maxsize::NTuple{2,Int})
    maxheight, maxwidth = max.(maxsize, 5)
    h, w = size(img)
    while h > maxheight || 2w > maxwidth
        img = restrict(img)
        h, w = size(img)
    end
    img, BigBlocks((h, 2w))
end

function _downscale_small(img::AbstractVector{<:Colorant}, maxwidth::Int)
    maxwidth = max(maxwidth, 5)
    while length(img) > maxwidth
        img = restrict(img)
    end
    img, SmallBlocks((1, length(img)))
end

function _downscale_big(img::AbstractVector{<:Colorant}, maxwidth::Int)
    maxwidth = max(maxwidth, 5)
    w = length(img)
    n = 3w > maxwidth ? maxwidth ÷ 6 : w
    img, BigBlocks((1, n < w ? 3(2n + 1) : 3w))  # downscaling of img here is 'fake'
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
    ascii_encode(io::IO, enc::ImageEncoder, colordepth::TermColorDepth, img; trail_nl::Bool=false, ret::Bool=false, callback=nothing)

Transforms the pixel of the given image `img`, which has to be an
array of `Colorant`, into a string of unicode characters using
ansi terminal colors or directly writes into a i/o stream.

- The encoder `enc` specifies which kind of unicode represenation should be used.

- The `colordepth` can either be `TermColor8bit()` or `TermColor24bit()`
  and specifies which terminal color codes should be used.

# Arguments

It `ret` is set, the function returns a vector of strings containing the encoded image.
Each element represent one line. The lines do not contain newline characters.

If `trail_nl` is given, a final trailing newline is appended.

The keyword argument `callback` can be used to save encoded colors and characters.
"""
function ascii_encode(
    io::IO,
    ::SmallBlocks,
    colordepth::TermColorDepth,
    img::AbstractMatrix{<:Colorant};
    trail_nl::Bool=false,
    ret::Bool=false,
    callback=nothing
)
    yinds, xinds = axes(img)
    for (n, y) in enumerate(first(yinds):2:last(yinds))
        _printc(io, RESET)
        for x in xinds
            fgcol = _colorant2ansi(img[y, x], colordepth)
            bgcol = if y + 1 ≤ last(yinds)
                _colorant2ansi(img[y + 1, x], colordepth)
            else
                # if reached it means that the last character row
                # has only the upper pixel defined.
                nothing
            end
            callback ≡ nothing || callback((n, x), fgcol, bgcol, '▀')
            _printc(io, Crayon(; foreground=fgcol, background=bgcol), '▀')
        end
        _printc(io, RESET)
        (trail_nl || y < last(yinds)) && println(io)
    end
    ret ? readlines(io) : nothing
end

function ascii_encode(
    io::IO,
    ::BigBlocks,
    colordepth::TermColorDepth,
    img::AbstractMatrix{<:Colorant};
    trail_nl::Bool=false,
    ret::Bool=false,
    callback=nothing
)
    yinds, xinds = axes(img)
    for y in yinds
        _printc(io, RESET)
        for x in xinds
            color = img[y, x]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            callback ≡ nothing || callback((y, x), fgcol, missing, chr, chr)
            _printc(io, Crayon(; foreground=fgcol), chr, chr)
        end
        _printc(io, RESET)
        (trail_nl || y < last(yinds)) && println(io)
    end
    ret ? readlines(io) : nothing
end

function ascii_encode(
    io::IO,
    ::SmallBlocks,
    colordepth::TermColorDepth,
    img::AbstractVector{<:Colorant};
    trail_nl::Bool=false,
    ret::Bool=false,
    callback=nothing
)
    _printc(io, RESET)
    for i in axes(img, 1)
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        callback ≡ nothing || callback((i,), fgcol, missing, chr)
        _printc(io, Crayon(; foreground=fgcol), chr)
    end
    _printc(io, RESET)
    trail_nl && println(io)
    ret ? readlines(io) : nothing
end

function ascii_encode(
    io::IO,
    enc::BigBlocks,
    colordepth::TermColorDepth,
    img::AbstractVector{<:Colorant};
    trail_nl::Bool=false,
    ret::Bool=false,
    callback=nothing
)
    w = length(img)
    n = enc.size[2] ÷ 3 == w ? w : enc.size[2] ÷ 6
    # left or full
    _printc(io, RESET)
    for i in (0:(n - 1)) .+ firstindex(img)
        color = img[i]
        fgcol = _colorant2ansi(color, colordepth)
        chr = _charof(alpha(color))
        callback ≡ nothing || callback((i,), fgcol, missing, chr, chr, ' ')
        _printc(io, Crayon(; foreground=fgcol), chr, chr, ' ')
    end
    if n < w  # right part
        _printc(io, RESET, " … ")
        for i in ((-n + 1):0) .+ lastindex(img)
            color = img[i]
            fgcol = _colorant2ansi(color, colordepth)
            chr = _charof(alpha(color))
            callback ≡ nothing || callback((i,), fgcol, missing, chr, chr, ' ')
            _printc(io, Crayon(; foreground=fgcol), chr, chr, ' ')
        end
    end
    _printc(io, RESET)
    trail_nl && println(io)
    ret ? readlines(io) : nothing
end

color_buffer() = IOContext(PipeBuffer(), :color => Base.get_have_color())

# use a `PipeBuffer` as io and returns encoded data reading lines of this buffer (using `readlines(io)`)
ascii_encode(enc::SmallBlocks, args...; kws...) =
    ascii_encode(color_buffer(), enc, args...; ret=true, kws...)
ascii_encode(enc::BigBlocks, args...; kws...) =
    ascii_encode(color_buffer(), enc, args...; ret=true, kws...)

"""
    ascii_show(stream, img, colordepth::TermColorDepth, encoder::Symbol=:auto, maxsize::Tuple=displaysize(io))

Displays the given image `img` using unicode characters and terminal colors.
`img` has to be an array of `Colorant`.

- `maxsize` specifies the maximum numbers of string characters (lines, columns)
  that should be used for the resulting image.
  Larger images are downscaled automatically using `restrict`.

If working in the REPL, the function tries to choose the encoding based on the current display size.
The image will also be downsampled to fit into the display (using `restrict`).
"""
function ascii_show(
    io::IO,
    img::AbstractMatrix{<:Colorant},
    colordepth::TermColorDepth,
    encoder::Symbol=:auto,
    maxsize::Tuple=displaysize(io);
    kws...
)
    io_h, io_w = maxsize
    downscale = if encoder ≡ :auto
        img_h, img_w = size(img)
        img_h ≤ io_h && 2img_w ≤ io_w ? _downscale_big : _downscale_small
    elseif encoder ≡ :small
        _downscale_small
    elseif encoder ≡ :big
        _downscale_big
    end
    img, enc = downscale(img, (io_h, io_w))
    ascii_encode(io, enc, colordepth, img; kws...)
end

function ascii_show(
    io::IO,
    img::AbstractVector{<:Colorant},
    colordepth::TermColorDepth,
    encoder::Symbol=:auto,
    maxsize::Tuple=displaysize(io);
    kws...
)
    _, io_w = maxsize
    downscale = if encoder ≡ :auto
        img_w = length(img)
        3img_w ≤ io_w ? _downscale_big : _downscale_small
    elseif encoder ≡ :small
        _downscale_small
    elseif encoder ≡ :big
        _downscale_big
    end
    img, enc = downscale(img, io_w)
    ascii_encode(io, enc, colordepth, img; kws...)
end

ascii_show(img::AbstractArray{<:Colorant}, args...; kws...) =
    ascii_show(color_buffer(), img, args...; ret=true, kws...)
