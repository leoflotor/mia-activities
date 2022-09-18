## como cargar una imagen?

Se deben cargar los siguientes paquetes:
```julia
using Images
using ImageInTerminal
```

Y la imagen debe ser cargada de la siguiente manera:
```
img_path = "path/to/file"
img = load(img_path)
```

## como leer sus pixeles?

Los pixeles se pueden leer como si uno accediera a un array multidimensional
en Julia. Es el mismo procedimiento.

El numero de pixeles se encuentra de la misma manera en que se encuentran
el numero de elementos de una matriz $A_{n,m}$, multiplicando $n \times m$.

## Ya el juego con la matriz


Debe calcularse el vector promedio de color de la imagen:
$$
\vec{m} = \frac{}{\sum_{i=1}^{N} \vec{x}_i}
$$

## Paquetes

- Images.jl
- ImageInTerminal.jl
- Sixel.jl

Sixel is supposed to provide a better experience while showing images in terminal.

Apparently, Kitty does not support [Sixel](https://github.com/JuliaIO/Sixel.jl).
