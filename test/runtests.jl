using Test, TestImages, ReferenceTests
using ImageTransformations
using OffsetArrays
using XTermColors
using ImageBase  # for `N0f8`

import XTermColors: TermColorDepth, TermColor8bit, TermColor24bit
import XTermColors: ascii_encode, _downscale_small, _downscale_big
import XTermColors: colorant2ansi, _colorant2ansi

include("common.jl")

macro check_enc(res, expected)
    esc(
        quote
            @test length($res) === length($expected)
            all($res .== $expected) || @show $res
            @test all($res .== $expected)
        end,
    )
end

for t in ("tst_colorant2ansi.jl", "tst_ascii.jl")
    @testset "$t" begin
        include(t)
    end
end
