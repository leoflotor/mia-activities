branch(si, [cielo=soleado, _, humedad=normal, _]).
branch(no, [cielo=soleado, _, humedad=alta, _]).
branch(si, [cielo=nublado, _, _, _]).
branch(no, [cielo=lluvia, _, _, viento=fuerte]).
branch(si, [cielo=lluvia, _, _, viento=debil]).
