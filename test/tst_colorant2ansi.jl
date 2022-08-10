@test supertype(TermColor8bit) <: TermColorDepth
@test supertype(TermColor24bit) <: TermColorDepth

# This tests if the mapping from RGB to the
# 8bit (256) ansi color codes is correct
@testset "8bit colors" begin
    enc = TermColor8bit()

    @testset "RGB - Gray" begin
        for idx in 16:255
            hex = XTermColors.TERMCOLOR256_LOOKUP[idx]
            col = RGB(reinterpret(RGB24, hex))
            ansi = _colorant2ansi(col, enc)
            if idx % 43 == 16  # gray levels values mapping to cube levels
                @test ansi > 231
            else
                @test ansi == idx
            end
        end
    end

    @testset "Decoder - Gray scale" begin
        for idx in 232:255
            hex = XTermColors.TERMCOLOR256_LOOKUP[idx]
            c = RGB(reinterpret(RGB24, hex))
            @test enc(Gray(red(c))) == c
        end
    end

    @testset "Decoder - RGB scale" begin
        for idx in 16:231
            idx % 43 == 16 && continue  # skip values mapping to cube levels
            hex = XTermColors.TERMCOLOR256_LOOKUP[idx]
            c = RGB(reinterpret(RGB24, hex))
            @test enc(c) == c
        end
    end
end

# This tests if the mapping from RGB to the 24 bit r g b tuples
# (which are in the set {0,1,...,255}) is correct.
@testset "24 bit colors" begin
    enc = TermColor24bit()

    @testset "RGB" begin
        for col in rand(RGB, 10)
            @test enc(col) == col
            r, g, b = red(col), green(col), blue(col)
            ri, gi, bi = map(c -> round(Int, 255c), (r, g, b))
            @test _colorant2ansi(col, enc) === (ri, gi, bi)
        end
    end

    @testset "Gray" begin
        for col in rand(Gray, 10)
            @test enc(col) == col
            r = round(Int, 255real(col))
            @test _colorant2ansi(col, enc) === (r, r, r)
        end
    end
end

# Internally non RGB Colors should be converted to RGB
# This tests if the result reflects that assumption.
@testset "Non RGB" begin
    for col_rgb in rand(RGB, 10)
        col_hsv = convert(HSV, col_rgb)
        @test _colorant2ansi(col_rgb, TermColor24bit()) ===
            _colorant2ansi(col_hsv, TermColor24bit())
    end
end

# Internally all Alpha Colors should be stripped of their alpha channel.
# This tests if the result reflects that assumption.
@testset "TransparentColor" begin
    for col in (rand(RGB, 10)..., rand(HSV, 10)...)
        acol = alphacolor(col, rand())
        @test _colorant2ansi(col, TermColor24bit()) ===
            _colorant2ansi(acol, TermColor24bit())
    end
end

# Compare functionality against the functions tested above
@testset "Validate exported interface boundaries" begin
    @test_throws MethodError colorant2ansi(RGB(1.0, 1.0, 1.0), TermColor8bit())
    @test_throws MethodError colorant2ansi(RGB(1.0, 1.0, 1.0), TermColor24bit())
end

@testset "8bit colors" begin
    for col in (rand(RGB, 10)..., rand(Gray, 10)...)
        # compare against non-exported interface, which we already tested above
        @test colorant2ansi(col) === _colorant2ansi(col, TermColor8bit())
    end
end

# Check if exported interface propagates conversions
@testset "Non RGB" begin
    for col_rgb in rand(RGB, 10)
        @test colorant2ansi(col_rgb) === colorant2ansi(convert(HSV, col_rgb))
    end
end

# Check if exported interface propagates conversions
@testset "TransparentColor" begin
    for col in (rand(RGB, 10)..., rand(HSV, 10)...)
        @test colorant2ansi(col) === colorant2ansi(alphacolor(col, rand()))
    end
end
