# copied from ImageCore.jl for lighter dependency
clamp01(x) = _clamp01(x)
clamp01nan(x) = _clamp01nan(x)

# _clamp01(x::Union{N0f8,N0f16}) = x
_clamp01(x::Number) = clamp(x, zero(x), oneunit(x))
_clamp01(c::Colorant) = mapc(_clamp01, c)

_clamp01nan(x) = _clamp01(x)
_clamp01nan(x::AbstractFloat) = ifelse(isnan(x), zero(x), clamp01(x))
_clamp01nan(c::Colorant) = mapc(_clamp01nan, c)
