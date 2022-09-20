module MandelbrotFractal

#==============================
Required libraries
===============================#

using Images
using Plots

#==============================
Image operations
===============================#

function imageSave(path, img)
    save(path, img)
end

function visualize(rgbmap)
    return plot(rgbmap, ticks=false)
end

#==============================
Fractal genereration
===============================#

function mandelbrot(c, maxiter)
    z = 0
    n = 0
    while abs(z) <= 2 && n < maxiter
        z = z*z + c
        n += 1
    end
    return n
end

function canvasRGB(height, width)
    return zeros(RGB, height, width)
end

function canvasHSV(height, width)
    return zeros(HSV, height, width)
end

xc(i, lx, nx) = lx * (2*i - 1) / nx

function fractalGrays(nx, ny; lx=2, ly=2, maxiter=80)
    cv = canvasRGB(ny, nx)

    for row in 1:ny
        y = xc(row, ly, ny) - ly

        for col in 1:nx
            x = xc(col, lx, nx) - lx
            c = x + y * 1im
            m = mandelbrot(c, maxiter) / maxiter

            pixel = 1 - m |> RGB
            cv[row, col] = pixel
        end
    end
    return cv
end

function fractalColors(nx, ny; lx=2, ly=2, maxiter=80)
    cv = canvasHSV(ny, nx)

    for row in 1:ny
        y = xc(row, ly, ny) - ly

        for col in 1:nx
            x = xc(col, lx, nx) - lx
            c = x + y * 1im
            m = mandelbrot(c, maxiter) / maxiter

            hue = 360 * m           # H between 0 and 360 (color wheel)
            sat = 0.85              # S between 0 and 1 (saturation)
            val = m < 1 ? 1 : 0     # V between 0 and 1 (brightness)
            cv[row, col] = HSV(hue, sat, val)
        end
    end
    return cv
end

function fractalCMap(nx, ny; lx=2, ly=2, maxiter=80, cname="Oranges")
    cv = canvasRGB(ny, nx)

    cmap_divs = 200
    cmap = colormap(cname, cmap_divs, logscale=true) |> reverse

    for row in 1:ny
        y = xc(row, ly, ny) - ly

        for col in 1:nx
            x = xc(col, lx, nx) - lx
            c = x + y * 1im
            m = mandelbrot(c, maxiter) / maxiter

            # To select a color of the colormap 
            cv[row, col] = cmap[ ceil(m * cmap_divs) |> Int ]
        end
    end
    return cv
end

end # module MandelbrotFractal
