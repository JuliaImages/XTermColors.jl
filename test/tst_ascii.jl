@test supertype(XTermColors.BigBlocks) <: XTermColors.ImageEncoder
@test supertype(XTermColors.SmallBlocks) <: XTermColors.ImageEncoder

@testset "_charof" begin
    @test @inferred(XTermColors._charof(0.0)) === '⋅'
    @test @inferred(XTermColors._charof(0.2)) === '░'
    @test @inferred(XTermColors._charof(0.5)) === '▒'
    @test @inferred(XTermColors._charof(0.8)) === '▓'
    @test @inferred(XTermColors._charof(1.0)) === '█'
end

@testset "ascii_encode 8bit small" begin
    @testset "gray square" begin
        img, enc = _downscale_small(gray_square, (2, 2))
        @test enc.size === (1, 2)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232;48;5;249m▀\e[38;5;239;48;5;255m▀\e[0m"]
        )
    end
    @testset "transparent gray square" begin
        # alpha is ignored for small block encoding: this yields the exact same results as above.
        img, enc = _downscale_small(gray_square_alpha, (2, 2))
        @test enc.size === (1, 2)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232;48;5;249m▀\e[38;5;239;48;5;255m▀\e[0m"]
        )
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        # this checks the correct use of restrict
        # we compare against a hand checked reference output
        img, enc = _downscale_small(camera_man, (20, 20))
        @test enc.size === (9, 17)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/camera_small_20x20_8bit.txt" res
        # too small size
        img, enc = _downscale_small(camera_man, (1, 1))
        @test enc.size === (3, 5)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/camera_small_1x1_8bit.txt" res
        # bigger version
        img, enc = _downscale_small(camera_man, (60, 60))
        @test enc.size === (17, 33)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/camera_small_60x60_8bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = _downscale_small(lighthouse, (60, 60))
        @test enc.size === (17, 49)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/lighthouse_small_60x60_8bit.txt" res
    end
    @testset "toucan" begin
        img, enc = _downscale_small(toucan, (60, 60))
        @test enc.size === (20, 42)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/toucan_small_60x60_8bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 8bit big" begin
    @testset "gray square" begin
        img, enc = _downscale_big(gray_square, (4, 4))
        @test enc.size === (2, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            [
                "\e[0m\e[38;5;232m██\e[38;5;239m██\e[0m",
                "\e[0m\e[38;5;249m██\e[38;5;255m██\e[0m"
            ]
        )
    end
    @testset "transparent gray square" begin
        img, enc = _downscale_big(gray_square_alpha, (4, 4))
        @test enc.size === (2, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            [
                "\e[0m\e[38;5;232m██\e[38;5;239m▓▓\e[0m",
                "\e[0m\e[38;5;249m░░\e[38;5;255m⋅⋅\e[0m"
            ]
        )
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        img, enc = _downscale_big(camera_man, (40, 40))
        @test enc.size === (17, 34)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/camera_big_20x20_8bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = _downscale_big(lighthouse, (50, 50))
        @test enc.size === (17, 50)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/lighthouse_big_50x50_8bit.txt" res
    end
    @testset "toucan" begin
        img, enc = _downscale_big(toucan, (60, 60))
        @test enc.size === (20, 44)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/toucan_big_60x60_8bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 24bit small" begin
    @testset "gray square" begin
        img, enc = _downscale_small(gray_square, (2, 2))
        @test enc.size === (1, 2)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0;48;2;178;178;178m▀\e[38;2;76;76;76;48;2;255;255;255m▀\e[0m"
            ]
        )
    end
    @testset "transparent gray square" begin
        # alpha is ignored for small block encoding.
        # So this yields the exact same results as above.
        img, enc = _downscale_small(gray_square_alpha, (2, 2))
        @test enc.size === (1, 2)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0;48;2;178;178;178m▀\e[38;2;76;76;76;48;2;255;255;255m▀\e[0m"
            ]
        )
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        # this checks the correct use of restrict
        # we compare against a hand checked reference output
        img, enc = _downscale_small(camera_man, (20, 20))
        @test enc.size === (9, 17)
        res = @ensurecolor ascii_encode(enc, TermColor24bit(), img)
        @test_reference "reference/camera_small_20x20_24bit.txt" res
        # bigger version
        img, enc = _downscale_small(camera_man, (60, 60))
        @test enc.size === (17, 33)
        res = @ensurecolor ascii_encode(enc, TermColor24bit(), img)
        @test_reference "reference/camera_small_60x60_24bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = _downscale_small(lighthouse, (60, 60))
        @test enc.size === (17, 49)
        res = @ensurecolor ascii_encode(enc, TermColor24bit(), img)
        @test_reference "reference/lighthouse_small_60x60_24bit.txt" res
    end
    @testset "toucan" begin
        img, enc = _downscale_small(toucan, (60, 60))
        @test enc.size === (20, 42)
        res = @ensurecolor ascii_encode(enc, TermColor24bit(), img)
        @test_reference "reference/toucan_small_60x60_24bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 24bit big" begin
    @testset "gray square" begin
        img, enc = _downscale_big(gray_square, (4, 4))
        @test enc.size === (2, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0m██\e[38;2;76;76;76m██\e[0m",
                "\e[0m\e[38;2;178;178;178m██\e[38;2;255;255;255m██\e[0m"
            ]
        )
    end
    @testset "transparent gray square" begin
        img, enc = _downscale_big(gray_square_alpha, (4, 4))
        @test enc.size === (2, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0m██\e[38;2;76;76;76m▓▓\e[0m",
                "\e[0m\e[38;2;178;178;178m░░\e[38;2;255;255;255m⋅⋅\e[0m"
            ]
        )
    end
    # the following tests checks the correct use of restrict
    # we compare against a hand checked reference output
    @testset "camera man" begin
        img, enc = _downscale_big(camera_man, (40, 40))
        @test enc.size === (17, 34)
        res = @ensurecolor ascii_encode(enc, TermColor24bit(), img)
        @test_reference "reference/camera_big_20x20_24bit.txt" res
    end
    @testset "lighthouse" begin
        img, enc = _downscale_big(lighthouse, (50, 50))
        @test enc.size === (17, 50)
        res = @ensurecolor ascii_encode(enc, TermColor24bit(), img)
        @test_reference "reference/lighthouse_big_50x50_24bit.txt" res
    end
    @testset "toucan" begin
        img, enc = _downscale_big(toucan, (60, 60))
        @test enc.size === (20, 44)
        res = @ensurecolor ascii_encode(enc, TermColor24bit(), img)
        @test_reference "reference/toucan_big_60x60_24bit.txt" res
    end
end

# ====================================================================

@testset "ascii_encode 8bit small" begin
    @testset "gray line" begin
        img, enc = _downscale_small(gray_line, 10)
        @test enc.size === (1, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232m█\e[38;5;239m█\e[38;5;249m█\e[38;5;255m█\e[0m"]
        )
    end
    @testset "transparent gray line" begin
        img, enc = _downscale_small(gray_line_alpha, 10)
        @test enc.size === (1, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232m█\e[38;5;239m▓\e[38;5;249m░\e[38;5;255m⋅\e[0m"]
        )
    end
    @testset "rgb line" begin
        img, enc = _downscale_small(rgb_line, 8)
        @test enc.size === (1, 6)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            [
                "\e[0m\e[38;5;18m█\e[38;5;20m█\e[38;5;55m█\e[38;5;125m█\e[38;5;160m█\e[38;5;88m█\e[0m"
            ]
        )
    end
end

# ====================================================================

@testset "ascii_encode 8bit big" begin
    @testset "gray line" begin
        img, enc = _downscale_big(gray_line, 9)
        @test enc.size === (1, 9)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232m██ \e[0m … \e[38;5;255m██ \e[0m"]
        )
        img, enc = _downscale_big(gray_line, 12)
        @test enc.size === (1, 12)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232m██ \e[38;5;239m██ \e[38;5;249m██ \e[38;5;255m██ \e[0m"]
        )
    end
    @testset "transparent gray line" begin
        img, enc = _downscale_big(gray_line_alpha, 10)
        @test enc.size === (1, 9)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232m██ \e[0m … \e[38;5;255m⋅⋅ \e[0m"]
        )
        img, enc = _downscale_big(gray_line_alpha, 12)
        @test enc.size === (1, 12)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;232m██ \e[38;5;239m▓▓ \e[38;5;249m░░ \e[38;5;255m⋅⋅ \e[0m"]
        )
    end
    @testset "rgb line" begin
        img, enc = _downscale_big(rgb_line, 9)
        @test enc.size === (1, 9)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;21m██ \e[0m … \e[38;5;196m██ \e[0m"]
        )
        img, enc = _downscale_big(rgb_line, 22)
        @test enc.size === (1, 21)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            [
                "\e[0m\e[38;5;21m██ \e[38;5;20m██ \e[38;5;20m██ \e[0m … \e[38;5;160m██ \e[38;5;160m██ \e[38;5;196m██ \e[0m"
            ]
        )
    end
end

# ====================================================================

@testset "ascii_encode 24bit small" begin
    @testset "gray line" begin
        img, enc = _downscale_small(gray_line, 10)
        @test enc.size === (1, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0m█\e[38;2;76;76;76m█\e[38;2;178;178;178m█\e[38;2;255;255;255m█\e[0m"
            ]
        )
    end
    @testset "transparent gray line" begin
        img, enc = _downscale_small(gray_line_alpha, 10)
        @test enc.size === (1, 4)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0m█\e[38;2;76;76;76m▓\e[38;2;178;178;178m░\e[38;2;255;255;255m⋅\e[0m"
            ]
        )
    end
    @testset "rgb line" begin
        img, enc = _downscale_small(rgb_line, 8)
        @test enc.size === (1, 6)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;6;0;122m█\e[38;2;47;0;208m█\e[38;2;101;0;154m█\e[38;2;154;0;101m█\e[38;2;208;0;47m█\e[38;2;122;0;6m█\e[0m"
            ]
        )
    end
end

# ====================================================================

@testset "ascii_encode 24bit big" begin
    @testset "gray line" begin
        img, enc = _downscale_big(gray_line, 9)
        @test enc.size === (1, 9)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            ["\e[0m\e[38;2;0;0;0m██ \e[0m … \e[38;2;255;255;255m██ \e[0m"]
        )
        img, enc = _downscale_big(gray_line, 12)
        @test enc.size === (1, 12)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0m██ \e[38;2;76;76;76m██ \e[38;2;178;178;178m██ \e[38;2;255;255;255m██ \e[0m"
            ]
        )
    end
    @testset "transparent gray line" begin
        img, enc = _downscale_big(gray_line_alpha, 10)
        @test enc.size === (1, 9)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            ["\e[0m\e[38;2;0;0;0m██ \e[0m … \e[38;2;255;255;255m⋅⋅ \e[0m"]
        )
        img, enc = _downscale_big(gray_line_alpha, 12)
        @test enc.size === (1, 12)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;0m██ \e[38;2;76;76;76m▓▓ \e[38;2;178;178;178m░░ \e[38;2;255;255;255m⋅⋅ \e[0m"
            ]
        )
    end
    @testset "rgb line" begin
        img, enc = _downscale_big(rgb_line, 9)
        @test enc.size === (1, 9)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            ["\e[0m\e[38;2;0;0;255m██ \e[0m … \e[38;2;255;0;0m██ \e[0m"]
        )
        img, enc = _downscale_big(rgb_line, 22)
        @test enc.size === (1, 21)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor24bit(), img)),
            [
                "\e[0m\e[38;2;0;0;255m██ \e[38;2;13;0;242m██ \e[38;2;27;0;228m██ \e[0m … \e[38;2;228;0;27m██ \e[38;2;242;0;13m██ \e[38;2;255;0;0m██ \e[0m"
            ]
        )
    end
end

@testset "non 1 based indexing (OffsetArray)" begin
    @testset "rgb line" begin
        img, enc = _downscale_small(OffsetArray(rgb_line, (-1,)), 8)
        @test enc.size === (1, 6)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            [
                "\e[0m\e[38;5;18m█\e[38;5;20m█\e[38;5;55m█\e[38;5;125m█\e[38;5;160m█\e[38;5;88m█\e[0m"
            ]
        )
    end
    @testset "rgb line2" begin
        img, enc = _downscale_big(OffsetArray(rgb_line, (2,)), 9)
        @test enc.size === (1, 9)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            ["\e[0m\e[38;5;21m██ \e[0m … \e[38;5;196m██ \e[0m"]
        )
        img, enc = _downscale_big(OffsetArray(rgb_line, (-2,)), 22)
        @test enc.size === (1, 21)
        @check_enc(
            @ensurecolor(ascii_encode(enc, TermColor8bit(), img)),
            [
                "\e[0m\e[38;5;21m██ \e[38;5;20m██ \e[38;5;20m██ \e[0m … \e[38;5;160m██ \e[38;5;160m██ \e[38;5;196m██ \e[0m"
            ]
        )
    end
    @testset "lighthouse" begin
        img, enc = _downscale_small(OffsetArray(lighthouse, (2, -10)), (60, 60))
        @test enc.size === (17, 49)
        res = @ensurecolor ascii_encode(enc, TermColor8bit(), img)
        @test_reference "reference/lighthouse_small_60x60_8bit.txt" res
    end
end

@testset "ascii_show (frontend interface)" begin
    @testset "lighthouse 8bit" begin
        img = imresize(lighthouse, (30, 30))
        for sz in [(20, 20), (80, 80)], enc in (:small, :big, :auto)
            res = @ensurecolor ascii_show(img, TermColor8bit(), enc, sz)
            @test_reference "reference/show_lighthouse_$(sz[1])x$(sz[2])_$(enc)_8bit.txt" res
            res = @ensurecolor ascii_show(img[1, :], TermColor8bit(), enc, sz)
            @test_reference "reference/show_lighthouse_$(sz[2])_$(enc)_8bit.txt" res
        end
    end
    @testset "mandril 24bit" begin
        img = imresize(mandril, (30, 30))
        for sz in [(20, 20), (80, 80)], enc in (:small, :big, :auto)
            suffix = "mandril_$(sz[1])x$(sz[2])_$(enc)_24bit"
            res = @ensurecolor ascii_show(img, TermColor24bit(), enc, sz)
            @test_reference "reference/show_mandril_$(sz[1])x$(sz[2])_$(enc)_24bit.txt" res
            res = @ensurecolor ascii_show(img[1, :], TermColor24bit(), enc, sz)
            @test_reference "reference/show_mandril_$(sz[2])_$(enc)_24bit.txt" res
        end
    end
end

@testset "RGB wheel" begin
    wheel = OffsetArrays.centered(fill(ARGB(0, 0, 0, 0), (64, 64)))

    for I in CartesianIndices(wheel)
        x, y = I.I ./ (size(wheel) .÷ 2)
        if (r = sqrt(x^2 + y^2)) < 1
            h = atand(x, y) + 90
            wheel[I] = RGB(HSV(h, r, 1))
        end
    end

    for depth in (8, 24)
        colordepth = depth == 8 ? TermColor8bit() : TermColor24bit()
        res = @ensurecolor ascii_show(wheel, colordepth, :auto, (80, 80))
        @test_reference "reference/show_wheel_80x80_$(depth)bit.txt" res
    end
end

@testset "Gray bar" begin
    bar = Gray{N0f8}.(repeat(range(0; stop=1, length=64), 1, 2)')

    for depth in (8, 24)
        colordepth = depth == 8 ? TermColor8bit() : TermColor24bit()
        res = @ensurecolor ascii_show(bar, colordepth, :auto, (80, 80))
        @test_reference "reference/show_bar_80x80_$(depth)bit.txt" res
    end
end
