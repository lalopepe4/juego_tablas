# assets

Aqui van las imagenes que usa el juego (Chispita, los secuaces, la nube, el
botiquin y los fondos).

Godot **no puede importar archivos de fuera de la carpeta del proyecto**, asi
que las ilustraciones que genera el pipeline en `../../Ilustraciones/` hay que
copiarlas aqui antes de usarlas en una escena.

Convencion de nombres: el mismo `nombre` del activo en `catalogo.toml`, sin el
sufijo de version. Por ejemplo:

```
Ilustraciones/Heroe_Chispita_v04.png  ->  assets/personajes/heroe_chispita.png
```

Cuando haya varias versiones de un activo, se copia la elegida con el nombre
sin `_vNN` para que las escenas no cambien cada vez que se regenera el arte.
