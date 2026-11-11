# Guía de estilo común para las ilustraciones

Esta guía sirve como referencia para todas las imágenes de **Chispita y el Reino Unicornio**. Se incluye junto con cada descripción al pedir una ilustración a una IA generativa.

## Identidad visual

- Juego infantil 2D de aventuras y aprendizaje de las tablas de multiplicar, con un mundo fantástico, cálido y optimista.
- Ilustración 2D caricaturesca de aspecto dibujado a mano, inspirada en cuentos infantiles ilustrados y juegos clásicos de plataformas 2D.
- Formas redondeadas, proporciones expresivas y siluetas muy claras a primera vista.
- Contornos oscuros, limpios, gruesos y completamente cerrados alrededor de personajes y objetos; sombreado suave (_cel shading_ amable), sin texturas fotorrealistas ni exceso de detalles diminutos.
- Colores vivos y alegres para el reino; tonos carbón, azul noche y violeta luminoso para la magia de sombra.
- La oscuridad debe parecer mágica, traviesa y reversible, nunca terrorífica, agresiva ni violenta.
- Diseños 100 % originales: no imitar personajes, escenarios ni estilos identificables de franquicias existentes.

## Coherencia entre imágenes

- **Chispita**: unicornio joven de cuerpo pequeño y robusto, pelaje blanco cálido, crin y cola abundantes con mechones de los colores del arcoíris, cuerno mágico dorado, ojos grandes y amables y collar con dije de estrella.
- **Familia de sombras**: los secuaces comparten paleta (carbón, azul noche y acentos violeta brillante) con el Monstruo de la Sombra, pero son pequeños, redondos, sin orejas ni corona. El **Monstruo de la Sombra** se distingue claramente como jefe final por su mayor tamaño, porte teatral y corona dorada.
- Mantener el mismo grosor de contorno, paleta cromática y nivel de detalle entre personajes, interfaz, objetos, escenarios y mapas.
- En los dos mapas del Reino Unicornio, conservar exactamente la misma distribución geográfica de los diez pueblos y el trazado del camino; la versión invadida solo añade las sombras mágicas, los nueve secuaces y el jefe final.

## Legibilidad para el juego

- Cada archivo de personaje u objeto debe producir **una única figura u objeto completo**, bien centrado y con margen libre alrededor (sin cortar orejas, cuernos, colas ni bordes).
- Diseñar formas que sigan reconociéndose con claridad cuando se escalen a tamaño pequeño en pantalla.
- Mantener despejadas las zonas destinadas a personajes, preguntas, botones o barras de vida según indique cada escena.
- **Cero texto**: no incluir letras, palabras, números, signos matemáticos, interrogaciones, logotipos ni marcas de agua. Todos los textos y cifras se dibujarán mediante código dentro del juego.
- Usar fondo limpio y uniforme para recortar con transparencia los personajes y objetos de interfaz; para escenarios y mapas, cubrir el lienzo completo en formato panorámico `16:9`.

## Bloque breve para añadir a cada solicitud

> Mantén el estilo visual del Reino Unicornio: ilustración 2D caricaturesca de cuento infantil y videojuego clásico, de aspecto dibujado a mano, con formas redondeadas, contornos oscuros gruesos, limpios y bien cerrados, colores vivos y sombreado suave sin texturas realistas. Usa diseños 100 % originales, tiernos y muy legibles a tamaño pequeño. Cuando aparezca magia de sombra, debe verse fantástica, misteriosa y juguetona, nunca terrorífica ni violenta. No incluyas ningún texto, letras, números, signos matemáticos, logotipos ni marcas de agua. Sigue fielmente la composición indicada en esta descripción.

## Organización de archivos

- Guardar las descripciones y prompts en `Docu/Ilustraciones/Descripciones/`.
- Guardar las imágenes generadas en `Ilustraciones/`.
- Usar nombres de imagen correspondientes al archivo de descripción (con sufijos de versión como `_v01`, `_v02` cuando se iteren variantes).
