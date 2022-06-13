using Test, TestImages, ReferenceTests
using ImageTransformations
using OffsetArrays
using XTermColors
using ImageBase

import XTermColors: TermColorDepth, TermColor256, TermColor24bit
import XTermColors: SmallBlocks, BigBlocks

# define some test images
gray_square = colorview(Gray, N0f8[0.0 0.3; 0.7 1])
gray_square_alpha = colorview(GrayA, N0f8[0.0 0.3; 0.7 1], N0f8[1 0.7; 0.3 0])
gray_line = colorview(Gray, N0f8[0.0, 0.3, 0.7, 1])
gray_line_alpha = colorview(GrayA, N0f8[0.0, 0.3, 0.7, 1], N0f8[1, 0.7, 0.3, 0])
rgb_line = colorview(
    RGB,
    range(0, stop = 1, length = 20),
    zeroarray,
    range(1, stop = 0, length = 20),
)
rgb_line_4d = repeat(repeat(rgb_line', 1, 1, 1, 1), 1, 1, 2, 2)

camera_man = testimage("camera")  # .tif
lighthouse = testimage("lighthouse")  # .png
toucan = testimage("toucan")  # .png
mandril = testimage("mandril_color")  # .tif

macro ensurecolor(ex)
    quote
        _ensure_color(old_color) = begin
            try
                @eval Base have_color = true
                return $(esc(ex))
            finally
                Core.eval(Base, :(have_color = $old_color))
            end
        end
        _ensure_color(Base.have_color)
    end
end

function check_encoded(res::Vector{String}, expected::Vector{String})
    @test length(res) === length(expected)
    @test all(res .== expected)
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
    h, w = map(length, axes(img))
    while ceil(h / 2) > maxheight || w > maxwidth
        img = restrict(img)
        h, w = map(length, axes(img))
    end
    img, SmallBlocks((length(1:2:h), w))
end

function _downscale_big(img::AbstractMatrix{<:Colorant}, maxsize::NTuple{2,Int})
    maxheight, maxwidth = max.(maxsize, 5)
    h, w = map(length, axes(img))
    while h > maxheight || 2w > maxwidth
        img = restrict(img)
        h, w = map(length, axes(img))
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

for t in ("tst_colors.jl", "tst_encoder.jl", "tst_decoder.jl")
    @testset "$t" begin
        include(t)
    end
end

@testset "Color depth" begin
    @test XTermColors.set_colormode(8) == TermColor256()
    @test XTermColors.set_colormode(24) == TermColor24bit()
    @test_throws ErrorException XTermColors.set_colormode(1)
end
