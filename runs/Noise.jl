# ~/~ begin <<md/paper.md#runs/Noise.jl>>[init]
module Noise
using FFTW

"""
    make_noise(box::Box, n, s, σ)

Make some Gaussian Random Noise with a power spectrum of

``P(k) = (s k)^n \\exp(-2 π^2 k^2 σ^2)``

The `box` should have periodic boundaries, `n` be a unitless
number (usually between -2.0 and 2.0), `s` is a scaling in meters
which only affects the amplitude and is needed to make `s * k` unitless,
and `σ` is the standard deviation of the Gaussian filter to reduce
small scale noise.

The noise is first generated as Gaussian white noise, then convolved in
Fourier space by multiplying with the square root of the power spectrum.

Example:

    box = Box{Periodic{2}}(grid_size=(100, 100), phys_scale=300.0u"m")
	cnoise = make_noise(box, -1.5, 50.0u"m", 500.0u"m")

"""
function make_noise(box, n, s, σ)
    white_noise = randn(box.grid_size...)
    P(k) = (k * s)^n * exp(-π^2 * k^2 * 2 * σ^2)
    kx = FFTW.rfftfreq(box.grid_size[1], 1/box.phys_scale)
    ky = FFTW.fftfreq(box.grid_size[2], 1/box.phys_scale)
    kabs = sqrt.(kx.^2 .+ ky'.^2)

    fy = FFTW.rfft(white_noise)
    p  = P.(kabs)
    p[1] = 0.0
    fy .*= sqrt.(p)
    FFTW.irfft(fy, box.grid_size[1])
end
end
# ~/~ end
