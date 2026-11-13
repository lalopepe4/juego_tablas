# Publicar «Chispita y las Tablas Mágicas» en F-Droid y Google Play

Investigación hecha el **2026-11-13** a partir de documentación oficial de F-Droid, Google Play, IARC/PEGI y del recetario real de F-Droid (`fdroiddata`) para juegos hechos con Godot. Al final hay una sección de **incertidumbres y cosas que hay que verificar en el Play Console**, porque algunas tablas (precios por país) solo se ven con la sesión iniciada.

---

## 0. Resumen ejecutivo

| Pregunta | Respuesta corta |
| --- | --- |
| ¿Se puede estar en F-Droid y Play a la vez? | **Sí.** No hay conflicto de políticas. Los roces son técnicos y comerciales: firma, `applicationId`, dependencias propietarias y que en F-Droid no puede haber pago ni anuncios. |
| ¿Requisitos para F-Droid? | Licencia **FLOSS**, código público, que F-Droid lo **compile desde fuente** con herramientas libres, sin SDK propietarios (ni Play Services, ni Firebase, ni AdMob), activos con licencia válida, app mantenida, metadatos `fastlane` y un *merge request* a `fdroiddata`. |
| ¿Requisitos para Play? | Cuenta de desarrollador (**25 USD** única), verificación de identidad, **AAB**, `targetSdk` 36, política de privacidad, *Data safety*, cuestionario IARC, declaración de anuncios y audiencia, y —si la cuenta es personal y nueva— **prueba cerrada con 12 testers durante 14 días**. |
| ¿Qué hace falta para PEGI 7? | Que el cuestionario IARC refleje fantasía caricaturesca con violencia muy leve y alguna escena/sonido que pueda asustar. Nada de sangre, armas realistas, muerte explícita, lenguaje soez, apuestas ni contenido adulto. **La clasificación la asigna IARC, no se elige.** |
| ¿Queda fuera un ranking? | **Un ranking local no, para nada.** Un ranking global **no está prohibido**, pero convierte el juego en un servicio que recoge datos de niños: COPPA, GDPR art. 8 y política de Familias de Play. Es mucho papeleo para poco valor. |
| ¿Se puede vender a 5 Bs? | **No como precio de app en Play.** Play fija mínimos por país; en USD el mínimo es **0,99 USD** (≈ 6,9 Bs). 5 Bs ≈ 0,72 USD queda por debajo. En F-Droid no hay apps de pago. |
| ¿Posibilidades reales de monetizar? | Pocas por volumen, pero reales por nicho: pago único, desbloqueo con compra integrada y donaciones. Anuncios en apps infantiles dan poco y complican el cumplimiento. |

---

## 1. Contexto del proyecto (lo que ya cumple y lo que falta)

Datos del repo (`Android_Notes.md`, `export_presets.cfg`):

| Dato | Valor | Impacto en las tiendas |
| --- | --- | --- |
| Paquete | `com.eduardo.juegochispita` | Sirve, aunque F-Droid recomienda un ID basado en un dominio propio. Cambiarlo después es doloroso. |
| Motor | Godot 4.7.2, GL Compatibility | Godot es MIT y **sí hay juegos Godot en F-Droid** (incluido Godot 4). |
| `targetSdk` | 36 (Android 16) | Cumple el requisito de Play vigente desde el 31-08-2026. |
| ABI | Solo `arm64-v8a` | Play lo acepta; para F-Droid conviene añadir `armeabi-v7a` y ordenar `versionCode`. |
| APK | ~47 MB, versionado en Git | Muy por debajo del límite de Play (200 MB). Para F-Droid, un `.git` de 139 MB se clona en cada build: mejor sacar artefactos del repo. |
| Red / analítica / anuncios | **Ninguno** | Es la mejor posición posible: Data safety limpio, sin anti-features en F-Droid. |
| Ranking | No existe | Si se añade, que sea local. |
| `LICENSE` | **No hay** | Bloqueante para F-Droid y mala idea en Play. |
| Procedencia de activos | Ilustraciones generadas con IA; sonidos de Pixabay | Hay que documentar licencia/procedencia. Pixabay prohíbe redistribuir el sonido «por separado»; dentro del juego suele permitirse, pero para F-Droid es más limpio CC0. |

---

## 2. ¿F-Droid y Google Play a la vez?

**Sí.** F-Droid es un repositorio de software libre, no una tienda con contrato de exclusividad; Google Play tampoco exige exclusividad. Publicar el código no rompe nada.

Los cuatro puntos donde sí se cruzan:

1. **Firma y `applicationId`.** F-Droid firma con **su** clave salvo que actives *reproducible builds* y declare `AllowedAPKSigningKeys`. Si Play y F-Droid firman el mismo `com.eduardo.juegochispita` con claves distintas, Android no deja instalar una encima de la otra: el usuario tiene que desinstalar. Dos salidas:
   - activar *reproducible builds* y que F-Droid use tu clave (lo ideal, pero hay que conseguir que el build sea idéntico bit a bit);
   - asumir dos instalaciones incompatibles y documentarlo.
2. **Dependencias propietarias.** Si algún día añades Play Billing, AdMob, Firebase o Crashlytics, la build de F-Droid debe ser un *flavor* sin nada de eso. F-Droid **prohíbe** explícitamente GMS, Firebase, Crashlytics y SDK de anuncios propietarios.
3. **Precio.** F-Droid no tiene apps de pago ni compras integradas. Puedes tener la app **gratis y completa en F-Droid** y **gratis con compra opcional en Play** (o de pago en Play), pero no puedes cobrar en F-Droid.
4. **Formato.** Play exige **AAB** para apps nuevas; F-Droid construye y publica **APK**. Ambos salen del mismo proyecto Godot, así que es solo configuración de CI.

Recomendación práctica: una sola base de código, dos presets/flavors (`play` y `foss`), y el `foss` sin ningún SDK propietario. La descripción de F-Droid no debe prometer funciones que solo existen en la versión de Play.

---

## 3. Requisitos de F-Droid

### 3.1 Licencia y código

- Licencia **FLOSS** reconocida (GPL, Apache, MIT, AGPL…). Debe haber archivo de licencia y avisos en el repo.
- Código fuente **público y actualizado**; no vale un repo con archivos de relleno.
- Cada release debe estar **etiquetada** (`v1.0.0`) y coincidir con `versionName`/`versionCode`.
- ID de aplicación único; se recomienda que derive de un dominio tuyo.

### 3.2 Compilación

- F-Droid **compila desde fuente** en su infraestructura, con **toolchain 100 % libre** empaquetado en Debian. Oracle JDK y toolchains en pre-release están prohibidos.
- Dependencias binarias precompiladas: solo desde fuentes permitidas (Debian *main*, Maven Central, Google Maven, OSS Sonatype, OSS JFrog, JitPack, Clojars; Android SDK/Flutter/Hermes oficiales mientras Debian no tenga alternativa; PyPI wheels, Nix cache, Rust, Go y Node actuales).
- **Godot entra por aquí**, y funciona: `fdroiddata` compila Godot con `scons` y el NDK, genera las plantillas de exportación y luego exporta el juego. Ejemplos reales:

  | App | Godot / NDK en el recetario |
  | --- | --- |
  | `org.revengate.revengate` | `Godot@4.1.1-stable`, NDK `25.1.8937393` |
  | `org.quentin_bettoum.librememorygame` | `Godot@b09f793…`, NDK `26.2.11394342` |
  | `org.sajeg.fallingblocks` | `Godot@6fed1ff…` (3.5.1), NDK `r23c` |

  Es decir: **Godot 4 es viable**. Habrá que añadir un bloque de build con `Godot@<tag>` (p. ej. `4.7.2-stable`), `scons`, `gradle` y las plantillas generadas.
- No se permiten binarios ejecutables añadidos ni autodescargas sin consentimiento explícito del usuario. El `.pck` de Godot va dentro del APK, así que no hay problema.

### 3.3 Activos (arte, sonido, fuentes)

- Todo activo debe tener licencia válida o ser dominio público, sin infringir derechos.
- **CC BY, CC BY-SA y CC0** son aceptables. Las licencias **NC (no comercial)** o **ND (sin derivadas)** se marcan como anti-feature *Non-Free Assets*.
- Las ilustraciones generadas con IA: guarda y documenta la procedencia y los términos del generador. Si el modelo o el servicio restringen el uso, puede haber problema.
- Los sonidos de Pixabay: su licencia permite usarlos dentro de un producto, pero prohíbe redistribuirlos «por separado». Es defendible, aunque para evitar preguntas del revisor lo más limpio es **CC0** (Kenney, Freesound filtrando CC0).

### 3.4 Anti-features (no bloquean siempre, pero se muestran)

`Ads`, `Tracking`, `Non-Free Assets`, `Non-Free Dependencies`, `Non-Free Network Services`, `Tethered Network Services`, `Non-Free Addons`, `No Source Since`, `Known Vulnerability`, `Disabled Algorithm`.

Para este juego, hoy: **ninguna**. Ese es un argumento fuerte de cara a la revisión.

### 3.5 Calidad y mantenimiento

- App funcional, que implemente lo que dice la descripción; no demos.
- Mantenimiento activo y compromiso de seguir publicando.
- Al menos **3 meses de desarrollo activo**, salvo que ya tenga usuarios, que el autor mantenga otras apps o que sea una app de un evento.
- Los *forks* necesitan ID, nombre, icono y textos propios.

### 3.6 Metadatos y envío

En el repo de la app:

```
fastlane/metadata/android/en-US/short_description.txt   (< 80 caracteres, sin punto final)
fastlane/metadata/android/en-US/full_description.txt
fastlane/metadata/android/en-US/images/icon.png
fastlane/metadata/android/en-US/images/phoneScreenshots/1.png
fastlane/metadata/android/en-US/images/phoneScreenshots/2.png
fastlane/metadata/android/en-US/changelogs/<versionCode>.txt   (máx. 500 caracteres)
```

Y en `fdroiddata`: un `metadata/<applicationId>.yml` con `License`, `SourceCode`, `RepoType`, `Repo`, `Builds` y reglas de autoactualización. Se prueba con `fdroid lint`, `fdroid rewritemeta` y `fdroid build` (o con la CI del fork) y se abre un *merge request*.

Tras aceptarlo, el build real puede tardar; F-Droid habla de **24–48 h** desde el merge hasta que aparece (la firma requiere intervención humana) y los ciclos de compilación no son diarios.

### 3.7 ABI y `versionCode`

F-Droid recomienda separar ABIs y ordenar los códigos:

```
armeabi-v7a < arm64-v8a < x86 < x86_64
VercodeOperation: 10 * %c + 1 … + 4
```

Con `arm64-v8a` + `armeabi-v7a` basta para móviles reales. Ojo: compilar Godot por ABI alarga el build; limitar ABIs es sensato.

### 3.8 Checklist concreto para este repo

- [ ] Añadir `LICENSE` (código) y un `LICENSES.md`/`ASSETS.md` con procedencia y licencia de cada imagen y sonido.
- [ ] Sacar `juego/JuegoChispita.apk` y `.idsig` del repositorio que se use para F-Droid (o usar un repo limpio solo de fuente).
- [ ] Etiquetar releases (`v1.0.0`) y subir `versionCode` en cada entrega.
- [ ] Crear el preset `foss` sin Play Billing ni SDK propietarios, con `armeabi-v7a` + `arm64-v8a`.
- [ ] Añadir metadatos `fastlane` (en español e inglés).
- [ ] Verificar que el build headless de Godot exporta desde línea de comandos (`godot --headless --export-release`).
- [ ] Abrir el *merge request* en `fdroiddata` con el bloque `Godot@<tag>`.
- [ ] Decidir firma: reproducible build con tu clave, o asumir que la versión de F-Droid no se puede instalar sobre la de Play.

---

## 4. Requisitos de Google Play

### 4.1 Cuenta

- Cuenta de Google, **18 años o más**.
- Aceptar el *Developer Distribution Agreement*.
- **25 USD** de alta, pago único (Mastercard/Visa/Amex/Discover; no tarjetas prepago).
- **Verificación de identidad**: documento oficial y, según el caso, dirección/teléfono. Si los datos no son válidos, no devuelven la tasa.
- **Tipo de cuenta**: personal u organización. La de organización pide **D-U-N-S** y verificación adicional.
- Cuentas **personales creadas después del 13-11-2023**: además hay que verificar acceso a un dispositivo Android con la app móvil de Play Console.

### 4.2 Prueba obligatoria (cuenta personal nueva)

- Prueba **cerrada** con **mínimo 12 testers** aceptados de forma **continua durante 14 días**.
- Después se solicita acceso a producción desde el *Dashboard* y se responde un formulario (prueba, app, madurez).
- La revisión suele tardar ≤ 7 días.
- Los testers deben usar la app de verdad; si no hay uso, pueden pedir más pruebas.

### 4.3 Técnico

- **AAB** (Android App Bundle) para apps nuevas y actualizaciones; Play App Signing.
- **`targetSdk` 36** (Android 16) desde el 31-08-2026 para apps nuevas y actualizaciones. Este proyecto ya compila contra 36.
- Soporte de 64 bits (ya lo tiene).
- El APK de 47 MB está holgado frente al límite de Play.
- Permisos declarados y justificados si son sensibles (aquí no hay).

### 4.4 «App content» (obligatorio antes de publicar)

| Sección | Qué hay que hacer en este juego |
| --- | --- |
| Política de privacidad | URL pública, accesible sin login, en HTML. **Obligatoria aunque no se recojan datos.** |
| Anuncios | Declarar «No contiene anuncios». |
| Acceso a la app | No hay login; indicarlo. |
| Audiencia objetivo | Declarar edades. Si incluyes niños, entras en política de Familias. |
| Permisos | Formulario solo si hay permisos sensibles; no es el caso. |
| Clasificación de contenido | Cuestionario **IARC** obligatorio. Sin él, la app figura como «Unrated» y puede retirarse. |
| Seguridad de los datos | Formulario *Data safety*. Con este juego: **no se recogen ni comparten datos**; el procesamiento local no se declara. |

### 4.5 Política de Familias (si la audiencia incluye niños)

- Contenido accesible a niños debe ser apropiado.
- Nada de webview como única función ni de tráfico de afiliación.
- Respuestas exactas en Play Console (audiencia, Data safety, IARC).
- Divulgar cualquier recogida de información personal o sensible de niños (autenticación, micrófono, cámara, datos de dispositivo, Android ID, datos de uso de anuncios).
- **Prohibido transmitir** AAID, SIM Serial, Build Serial, BSSID, MAC, SSID, IMEI o IMSI de niños o de usuarios de edad desconocida. En apps solo para niños, no pedir el permiso `AD_ID` con API 33+.
- Apps solo para niños: sin permiso de ubicación.
- Anuncios: solo **SDK certificados** por Play para Familias, **sin publicidad personalizada ni remarketing**, contenido apropiado y formatos permitidos (nada de pantalla completa sin cierre claro, nada que no se pueda cerrar a los 5 s, nada de intersticial al arrancar, nada de varios anuncios por pantalla, nada engañoso).
- Funciones sociales: recordatorio de seguridad, control adulto para activarlas y **acción adulta** (PIN, contraseña, fecha de nacimiento, email, documento, tarjeta…) antes de que un niño comparta información personal.
- Cumplimiento legal: **COPPA** (EE. UU.) y **GDPR** (UE), entre otras.

### 4.6 Comisiones y pagos

- **15 %** de los primeros **1 M USD** anuales y **30 %** por encima (mercados «restantes»).
- Suscripciones: 15 %.
- Hay una estructura nueva anunciada para EE. UU., EEE, Reino Unido, Japón y Australia (10 % + 5 % de pasarela en instalaciones nuevas, con tipos distintos para instalaciones existentes). Si vendes, confirma el tipo aplicable en tu cuenta.
- Para cobrar hace falta **perfil de pagos**, datos fiscales y método de cobro. **Bolivia admite registro de desarrollador y de comerciante**, con **USD** como moneda por defecto.

### 4.7 Reglas de precio que importan

- Play usa una moneda base y convierte al resto; en países sin moneda local soportada se usa **USD/EUR**.
- **Bolivia no tiene moneda local en Play**: los precios se expresan en **USD**.
- Se puede pasar de **pago a gratis**, pero **nunca de gratis a pago**. Si te equivocas, hay que crear otra app con otro paquete.
- Se pueden hacer precios por país y rebajas, pero **no por debajo del mínimo del país**.
- Los productos integrados también tienen bandas de precio por país.

---

## 5. PEGI 7: qué significa y cómo se consigue

### 5.1 La nomenclatura

Lo que en el README llamáis «PEGI 7» es **PEGI 7** (Europa). En América el sistema equivalente es **ESRB**: «Everyone» o «Everyone 10+». En Google Play **no se elige la clasificación**: se responde el cuestionario **IARC** y la autoridad de cada territorio asigna.

Definiciones oficiales que usa Play:

- **PEGI 3**: apto para todos. Violencia cómica tipo dibujos animados, personajes claramente fantásticos, sin sonidos ni imágenes que asusten a niños pequeños, sin lenguaje soez.
- **PEGI 7**: lo que sería PEGI 3 pero con **alguna escena o sonido que puede asustar**; solo violencia **muy leve**, implícita o no realista.
- **PEGI 12**: violencia algo más gráfica contra personajes fantásticos, o no gráfica contra humanos/animales; desnudos algo más explícitos; apuestas simuladas; lenguaje soez leve.
- **ESRB Everyone**: violencia mínima de dibujos animados, fantasía o leve.
- **ESRB Everyone 10+**: más violencia de dibujos animados, fantasía o leve.

### 5.2 Lo que hay que cuidar en Chispita

Para que el resultado sea **PEGI 7** (y no 12 ni «Unrated» por ocultar información):

- **Sí** puede haber: monstruos de sombra caricaturescos, rayos mágicos, golpes sin contacto explícito, derrota que se resuelve con una animación cómica, música tensa suave.
- **Evita**: sangre, heridas, muerte explícita o personajes que quedan «muertos» en pantalla, armas realistas, humanos como enemigos, gritos o sustos fuertes (jump scares), lenguaje soez, apuestas, contenido sexual o sugerente, enlaces a contenido adulto, chat o texto libre.
- Si hay alguna escena o sonido que asusta (un rugido, un fundido a negro con música), eso empuja de PEGI 3 a **PEGI 7**, que es justo lo que buscáis.
- El cuestionario IARC pregunta por violencia, miedo/terror, sexo/desnudos, lenguaje, drogas, apuestas, discriminación, contenido generado por usuarios, compras y compartición de datos. **Responde con exactitud**: la misrepresentación puede provocar retirada o suspensión.

### 5.3 Audiencia objetivo en Play

Play agrupa la audiencia en: **5 años o menos, 6–8, 9–12, 13–15, 16–17, 18+**. Un PEGI 7 encaja de forma natural en **6–8** (y quizá 9–12 si el juego está pensado para repaso escolar). Ojo: marcar un grupo infantil activa la política de Familias y sus requisitos.

### 5.4 Nota sobre el término «PG-7»

«PG-7» no existe como clasificación. PG es de la MPAA (cine) y PEGI es el sistema europeo de videojuegos. En la documentación conviene usar «PEGI 7» y, si se habla de Play, «clasificación IARC equivalente».

---

## 6. Ranking de mejores puntajes y datos de niños

### 6.1 Ranking local: adelante

Guardar las mejores puntuaciones en `user://progreso.cfg` no saca ningún dato del dispositivo. Para Play, el procesamiento **solo local** no se declara en *Data safety*; para F-Droid no hay red ni anti-features. **Es la opción recomendada**, y encaja con el control de tiempo y el reset de progreso que ya existen.

### 6.2 Ranking global: posible, pero caro en cumplimiento

En cuanto la puntuación viaja fuera del dispositivo, hay «recogida» de datos. Aunque sea un apodo y un identificador aleatorio, es **dato personal pseudónimo**. Se activan:

- **COPPA** (EE. UU., menores de 13): consentimiento parental verificable antes de recoger datos personales de un servicio dirigido a niños.
- **GDPR art. 8** (UE): para servicios de la sociedad de la información ofrecidos directamente a un niño, la edad de consentimiento es **16 años**, aunque los Estados pueden bajarla **hasta 13**; por debajo, consiente quien tiene la patria potestad y hay que hacer «esfuerzos razonables» para verificarlo.
- **Política de Familias de Play**: no transmitir AAID/IMEI/MAC/SSID/etc. de niños o de edad desconocida; si hay funciones sociales, recordatorio de seguridad, control adulto y **acción adulta**; además hay que declararlo en el cuestionario IARC y en *Data safety*.
- **F-Droid**: si el ranking depende de un servidor, el servicio debe ser libre o se marca como *Non-Free Network Services* / *Tethered Network Services*.

### 6.3 Tres diseños, de menos a más riesgo

1. **Solo local** (recomendado): «Mejores puntajes de este dispositivo». Cero datos, cero fricción, cero riesgo.
2. **Compartir puntuación**: botón que abre el *share sheet* de Android con un texto/imagen. Es una acción iniciada por el usuario, no hay servidor propio ni recogida por tu parte. Sigue siendo la opción simple y segura.
3. **Ranking global anónimo**: sin texto libre, ID aleatorio por instalación, *opt-in* detrás de una **barrera parental**, sin nombre ni email, retención limitada, política de privacidad que lo explique, y consentimiento parental verificable si hay menores de 13/16. Es viable, pero multiplica el trabajo legal y de soporte.

Conclusión: **el ranking no queda fuera**, pero un ranking global convierte un juego sin datos en un servicio con datos de menores. Para la primera versión, local; si más adelante hay tracción, se estudia el global con las precauciones anteriores.

---

## 7. Monetización

### 7.1 Qué permite cada canal

| Modelo | Google Play | F-Droid |
| --- | --- | --- |
| App de pago | Sí (mínimo por país) | **No** |
| Compras integradas | Sí, con Play Billing | **No** |
| Anuncios | Sí, con límites de Familias | **No** (anti-feature y, si el SDK es propietario, rechazo) |
| Donaciones | Sí (enlace externo según política) | **Sí**: Liberapay, Open Collective, Bitcoin, enlace verificado |
| Venta a colegios / licencia | Fuera de tienda | Fuera de tienda |

### 7.2 Los 5 Bs

- Play trabaja en **USD** para Bolivia, no en bolivianos.
- El mínimo de app en USD es **0,99 USD** (≈ **6,9 Bs** al cambio oficial ~6,96).
- **5 Bs ≈ 0,72 USD**: por debajo del mínimo, así que **no se puede fijar como precio**.
- Google redujo mínimos en 20 mercados con moneda local en 2021, pero Bolivia no usa moneda local en Play, así que no aplica.
- Alternativa si el precio es un problema: app **gratis** con desbloqueo opcional (compra integrada) o donación. También puedes poner 0,99 USD y hacer rebajas por país, pero nunca por debajo del mínimo.

> Verifica la tabla vigente en **Play Console → Precios** antes de decidir: los mínimos por país cambian y la tabla pública no se pudo leer completa en esta sesión.

### 7.3 Modelo realista (con supuestos, no predicciones)

Supongamos una app de pago a 0,99 USD con comisión del 15 %:

| Descargas/mes | Conversión a pago | Ingreso bruto | Neto aprox. (15 %) |
| --- | --- | --- | --- |
| 1.000 | 2 % | ~20 USD | ~17 USD |
| 5.000 | 2 % | ~99 USD | ~84 USD |
| 10.000 | 3 % | ~297 USD | ~252 USD |

Son cifras **ilustrativas**: dependen de país, estacionalidad, calidad de la ficha y del boca a boca. Lo importante es la escala: con un juego educativo de nicho, el pago único no da para mucho, y los anuncios en apps infantiles tienen eCPM bajo porque no se permite publicidad personalizada.

### 7.4 Recomendación de monetización

1. **Primera versión: gratis y sin anuncios** en ambas tiendas. Maximiza instalaciones, evita el riesgo de cumplimiento y encaja con F-Droid.
2. **Donaciones** visibles (Liberapay/Open Collective) y mención en la ficha. En F-Droid son el único modelo posible.
3. Si más adelante quieres cobrar: **desbloqueo único** con Play Billing, detrás de una **barrera parental**, sin monedas virtuales, sin suscripción y sin anuncios. O una versión «de pago» en Play y la gratuita en F-Droid.
4. **No** empieces con app de pago: no podrás volver a gratis si el experimento falla.

---

## 8. Plan recomendado por fases

**Fase 0 — Cumplimiento (1–2 semanas)**
- `LICENSE` + `ASSETS.md` con procedencia de ilustraciones y sonidos.
- Sacar APK/`.idsig` del repo de fuente.
- Política de privacidad publicada (aunque diga «no se recogen datos»).
- Revisar el cuestionario IARC con calma y decidir audiencia (6–8).

**Fase 1 — Google Play**
- Alta (25 USD), verificación de identidad, tipo de cuenta.
- AAB firmado, `targetSdk` 36, ficha y capturas.
- *App content* completo: privacidad, anuncios = no, audiencia, IARC, Data safety.
- Prueba interna → prueba cerrada con 12 testers durante 14 días → acceso a producción.

**Fase 2 — F-Droid**
- Preset `foss` sin SDK propietarios, `armeabi-v7a` + `arm64-v8a`.
- Metadatos `fastlane`, etiqueta `v1.0.0`, `versionCode` correcto.
- `metadata/<appid>.yml` con `Godot@<tag>` y *merge request* a `fdroiddata`.

**Fase 3 — Monetización (solo si hay tracción)**
- Decidir donaciones vs desbloqueo único.
- Si hay compras, barrera parental y revisión de la política de Familias.
- Si hay ranking global, rediseñar privacidad y consentimiento antes de programarlo.

---

## 9. Fuentes

**F-Droid**
- Política de inclusión: <https://f-droid.org/docs/Inclusion_Policy/>
- Guía de envío: <https://f-droid.org/docs/Inclusion_How-To/>
- Anti-features: <https://f-droid.org/docs/Anti-Features/>
- Recetario y ejemplos Godot: <https://gitlab.com/fdroid/fdroiddata> (`metadata/org.revengate.revengate.yml`, `metadata/org.quentin_bettoum.librememorygame.yml`, `metadata/org.sajeg.fallingblocks.yml`)

**Google Play**
- Empezar en Play Console (alta, 25 USD, identidad): <https://support.google.com/googleplay/android-developer/answer/6112435>
- Requisitos de prueba (12 testers / 14 días): <https://support.google.com/googleplay/android-developer/answer/14151465>
- Niveles de API objetivo: <https://support.google.com/googleplay/android-developer/answer/11926878>
- Clasificaciones de contenido (IARC, PEGI, ESRB): <https://support.google.com/googleplay/android-developer/answer/9859455>
- Política de Familias: <https://support.google.com/googleplay/android-developer/answer/9893335>
- Seguridad de los datos: <https://support.google.com/googleplay/android-developer/answer/10787469>
- Precios de la app: <https://support.google.com/googleplay/android-developer/answer/6334373>
- Ubicaciones admitidas para desarrollador y comerciante: <https://support.google.com/googleplay/android-developer/answer/9306917>
- Comisiones de servicio: <https://support.google.com/googleplay/android-developer/answer/112622>

**Protección de datos**
- GDPR art. 8: <https://gdpr-info.eu/art-8-gdpr/>
- COPPA (regla de la FTC): <https://www.ftc.gov/legal-library/browse/rules/childrens-online-privacy-protection-rule-coppa>

---

## 10. Incertidumbres y cosas que verificar

- **Mínimo de precio por país**: la tabla oficial se consulta en Play Console → Precios y no se pudo leer completa aquí. La afirmación «0,99 USD en Bolivia» se basa en que Play usa USD para Bolivia; confírmalo antes de fijar precios.
- **Godot 4.7.2 en F-Droid**: hay precedente con Godot 4.1.1 (`org.revengate.revengate`). Habrá que comprobar que el tag `4.7.2-stable` y el recetario de plantillas funcionan con la versión exacta del proyecto; puede requerir ajustes de `scons`/NDK.
- **Firma compartida**: si no se consigue un build reproducible, la versión de F-Droid y la de Play no serán intercambiables en el mismo dispositivo. Decidirlo antes de publicar.
- **Pixabay**: su licencia permite el uso dentro del juego pero no la redistribución aislada; si el revisor de F-Droid lo cuestiona, sustituir por CC0.
- **Comisiones**: hay una estructura nueva en rodaje para EE. UU., EEE, Reino Unido, Japón y Australia. El 15 %/30 % sigue siendo la referencia en el resto.
- **Clasificación**: el resultado real de IARC puede ser PEGI 3 si el tono es totalmente cómico, o PEGI 12 si alguna animación resulta más agresiva de lo previsto. No se puede garantizar PEGI 7 de antemano; se puede diseñar para ello.
