# Assets del juego

Godot solo importa recursos dentro de `juego/`. Las ilustraciones aprobadas se
copian desde `Ilustraciones/recortes/` y se guardan aquí sin el sufijo `_vNN`,
para que la escena no dependa de una versión concreta del catálogo.

## Personajes de batalla

Las texturas de Chispita y de ambos tipos de monstruo usan el mismo conjunto de
estados. Se mantiene también `heroe_chispita_asustado.png` para el estado de vida
baja de Chispita.

| Personaje           | Archivos (sin `.png`)                                                                                                                                                                                                                                                                          |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Chispita            | `heroe_chispita`, `heroe_chispita_asustado`, `heroe_chispita_concentrado`, `heroe_chispita_satisfecho`, `heroe_chispita_atacando`, `heroe_chispita_sorprendido`, `heroe_chispita_herido`, `heroe_chispita_celebrando`, `heroe_chispita_derrotado`                                              |
| Monstruo de Sombras | `monstruo_de_sombras`, `monstruo_de_sombras_asustado`, `monstruo_de_sombras_concentrado`, `monstruo_de_sombras_satisfecho`, `monstruo_de_sombras_atacando`, `monstruo_de_sombras_sorprendido`, `monstruo_de_sombras_herido`, `monstruo_de_sombras_celebrando`, `monstruo_de_sombras_derrotado` |
| Monstruo Secuaz     | `monstruo_secuaz`, `monstruo_secuaz_asustado`, `monstruo_secuaz_concentrado`, `monstruo_secuaz_satisfecho`, `monstruo_secuaz_atacando`, `monstruo_secuaz_sorprendido`, `monstruo_secuaz_herido`, `monstruo_secuaz_celebrando`, `monstruo_secuaz_derrotado`                                     |

Los retratos `*_frente` se usan como iconos en el mapa de los pueblos; no se
usan en la batalla.

## Objetos y escenarios

- `objetos/ataque_chispita.png`, `objetos/ataque_sombra.png` y
  `objetos/impacto.png`: efectos de batalla.
- `objetos/botiquin_de_ayuda.png` y `objetos/nube_de_multiplicar.png`.
- `escenarios/fondo_del_modo_batalla.png` y
  `escenarios/mapa_reino_unicornio_sin_monstruos.png`.

Ejemplo de origen y destino:

```text
Ilustraciones/recortes/Heroe_Chispita_atacando_v01.png
  -> juego/assets/personajes/heroe_chispita_atacando.png
```
