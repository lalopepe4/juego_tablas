# Notas de Android: exportar y probar el APK

Guía de referencia para compilar `JuegoChispita.apk` desde Linux, configurar
Godot y enviar el juego a un dispositivo Android de prueba.

Datos del proyecto (verificados con Godot 4.7.2 y el SDK de esta máquina):

| Dato                | Valor                                              |
| ------------------- | -------------------------------------------------- |
| Paquete             | `com.eduardo.juegochispita`                        |
| Nombre visible      | `Chispita`                                         |
| Versión             | `1.0.0` (versionCode `1`)                          |
| Arquitectura        | `arm64-v8a` (solo 64 bits ARM)                     |
| targetSdk / compile | `36` (Android 16)                                  |
| Renderizador        | GL Compatibility                                   |
| APK resultante      | ~47 MB                                             |
| Preset de export    | `Android` en `juego/export_presets.cfg`            |

---

## a) Checklist de instalación en Linux

Marca cada punto antes de intentar exportar. Los comandos de verificación se
pueden ejecutar tal cual en una terminal.

### Motor y plantillas

- [ ] **Godot 4.7.x** instalado y en el `PATH`.
  ```bash
  godot --version   # debe imprimir 4.7.x
  ```
- [ ] **Plantillas de exportación de la misma versión** que el editor.
  Se instalan desde el editor: *Editor → Gestionar plantillas de exportación →
  Descargar e instalar*. Si la versión no coincide exactamente, el export falla
  con un error de plantilla no encontrada.
  ```bash
  ls ~/.local/share/godot/export_templates/
  ```

### Java

- [ ] **OpenJDK 17** (Godot 4.x espera JDK 17; versiones más nuevas pueden
  fallar al firmar o al compilar con Gradle).
  ```bash
  ls /usr/lib/jvm/ | grep 17
  ```
  Instalación en Debian/Ubuntu:
  ```bash
  sudo apt install openjdk-17-jdk
  ```
  > En esta máquina el `java` del sistema es la 25, pero Godot apunta a
  > `/usr/lib/jvm/java-17-openjdk-amd64`. No cambies el `default-java` global:
  > basta con fijar la ruta en la configuración del editor (sección b).

### Android SDK

- [ ] **cmdline-tools** (para `sdkmanager` y `avdmanager`).
- [ ] **platform-tools** (incluye `adb`).
- [ ] **build-tools** (esta máquina usa `36.0.0`).
- [ ] **platforms;android-36** (el preset compila contra API 36).
- [ ] **Licencias aceptadas**.

Instalación con `sdkmanager` (asumiendo el SDK en `~/Android/Sdk`):

```bash
mkdir -p ~/Android/Sdk/cmdline-tools
# Descargar "Command line tools only" desde developer.android.com y descomprimir en:
#   ~/Android/Sdk/cmdline-tools/latest/

~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root="$HOME/Android/Sdk" \
  "platform-tools" "build-tools;36.0.0" "platforms;android-36"

~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root="$HOME/Android/Sdk" --licenses
```

Verificación:

```bash
ls ~/Android/Sdk/{platform-tools,build-tools,platforms}
~/Android/Sdk/platform-tools/adb version
```

### Firma

- [ ] **Debug keystore** generado. Godot lo crea automáticamente la primera vez
  que se configura el export de Android, o se puede generar a mano:
  ```bash
  keytool -keyalg RSA -genkeypair -alias androiddebugkey \
    -keypass android -keystore ~/.local/share/godot/keystores/debug.keystore \
    -storepass android -dname "CN=Android Debug,O=Android,C=US" \
    -validity 9999 -deststoretype pkcs12
  ```
  Contraseña y alias estándar: `android` / `androiddebugkey`.

### Opcionales pero recomendados

- [ ] **Reglas udev** para que `adb` acceda al dispositivo sin `sudo`.
  ```bash
  sudo apt install android-sdk-platform-tools-common
  ```
  Si el paquete no existe en tu distro, crea
  `/etc/udev/rules.d/51-android.rules` con el `idVendor` que devuelve `lsusb`
  (por ejemplo `18d1` para Google/Pixel) y recarga:
  ```bash
  sudo udevadm control --reload-rules && sudo udevadm trigger
  ```
- [ ] **scrcpy** para ver y controlar la pantalla del teléfono desde el PC:
  ```bash
  sudo apt install scrcpy
  ```
- [ ] **Emulador** (solo si no hay dispositivo físico). Ojo: el APK es
  `arm64-v8a`, así que un AVD x86_64 no lo ejecutará. Usa una imagen de sistema
  `arm64-v8a` o añade `x86_64` en el preset.

---

## b) Configuración de Godot para exportar APK

### 1. Rutas del SDK

*Editor → Configuración del editor → Exportar → Android*:

| Campo                  | Valor en esta máquina                          |
| ---------------------- | ---------------------------------------------- |
| Ruta del SDK de Android | `/home/eduardo/Android/Sdk`                    |
| Ruta del SDK de Java    | `/usr/lib/jvm/java-17-openjdk-amd64`           |
| Debug keystore          | `~/.local/share/godot/keystores/debug.keystore` |
| Alias / contraseña      | `androiddebugkey` / `android`                  |

Usa el botón **Configurar SDK de Android** del diálogo de exportación: valida
las rutas y lista los componentes que falten (build-tools, platform, etc.).

### 2. Preset de exportación

El proyecto ya trae el preset `Android` en `juego/export_presets.cfg`. Lo
relevante de esa configuración:

- **`package/unique_name`**: `com.eduardo.juegochispita`. Si lo cambias, el
  teléfono lo trata como otra app (no actualiza la instalada).
- **`package/name`**: `Chispita` (nombre bajo el icono).
- **`architectures/arm64-v8a = true`**, el resto en `false`. Activa
  `armeabi-v7a` solo para teléfonos muy antiguos de 32 bits.
- **`gradle_build/use_gradle_build = false`**: usa la plantilla precompilada de
  Godot. Es lo recomendado aquí: no requiere Android Studio ni plugins, y el
  export es mucho más rápido.
- **`screen/immersive_mode = true`**: oculta las barras del sistema.
- **`package/signed = true`**: el APK siempre se firma. En *debug* se usa el
  debug keystore; en *release* hace falta un keystore propio.
- **`version/code = 1`** y **`version/name` vacío** (Godot usa `1.0.0`).
  Sube `version/code` en cada entrega que quieras instalar sobre la anterior.

### 3. Exportar desde el editor

1. *Proyecto → Exportar…*
2. Selecciona el preset **Android**.
3. **Exportar proyecto…** → guarda como `juego/JuegoChispita.apk`.
4. Para probar rápido con el teléfono conectado, usa el **botón de Android**
   de la barra superior (one-click deploy): compila, instala y ejecuta en un
   solo paso.

### 4. Exportar desde la terminal

```bash
# Debug: firmado con el debug keystore, sin configuración extra.
godot --headless --path juego --export-debug "Android" juego/JuegoChispita.apk

# Release: requiere keystore de release configurado en el preset.
godot --headless --path juego --export-release "Android" juego/JuegoChispita.apk
```

> El export de debug con este repositorio ya fue verificado y produce un APK
> firmado y alineado de ~47 MB.

### 5. Firma de release (solo para distribuir)

El preset no tiene keystore de release. Para generar un APK de release:

```bash
keytool -keyalg RSA -genkeypair -alias chispita \
  -keypass TU_PASS -keystore ~/keystores/chispita.keystore \
  -storepass TU_PASS -dname "CN=Chispita,O=Eduardo,C=ES" \
  -validity 10000 -deststoretype pkcs12
```

Luego, en *Proyecto → Exportar → Android → Opciones → Keystore*:

- `keystore/release`: ruta del `.keystore`
- `keystore/release_user`: alias (`chispita`)
- `keystore/release_password`: contraseña

No subas el keystore ni las contraseñas al repositorio.

---

## c) Configurar el dispositivo Android para depuración USB

1. **Activar opciones de desarrollador**
   *Ajustes → Información del teléfono → Número de compilación*: toca 7 veces.
   (En algunas marcas: *Ajustes → Acerca del teléfono → Información del
   software → Número de compilación*.)
2. **Activar depuración USB**
   *Ajustes → Sistema → Opciones de desarrollador → Depuración USB*.
3. **Conectar por USB** con un cable de datos (no solo de carga) y elegir
   **Transferencia de archivos (MTP)** en el aviso de USB del teléfono.
4. **Aceptar la huella RSA** en el diálogo *¿Permitir depuración USB?*. Marca
   *Confiar siempre en este equipo*.
5. **Verificar desde Linux**:
   ```bash
   ~/Android/Sdk/platform-tools/adb devices -l
   ```
   El estado correcto es `device`. Otros estados:
   - `unauthorized` → falta aceptar la huella RSA (o revocarla y repetir).
   - `no permissions` → faltan reglas udev (ver checklist, sección a).
   - `offline` → reconecta el cable o `adb kill-server && adb start-server`.

### Alternativa: depuración inalámbrica (Android 11+)

*Opciones de desarrollador → Depuración inalámbrica → Vincular dispositivo con
código*. El teléfono muestra IP, puerto y código:

```bash
adb pair 192.168.1.50:37123     # introduce el código de 6 dígitos
adb connect 192.168.1.50:5555   # puerto que muestra la pantalla principal
```

### Si el teléfono no aparece

```bash
lsusb                                   # comprobar que el equipo lo detecta
adb kill-server && adb start-server
adb devices
```

En Xiaomi/Redmi, activa además *Instalar vía USB* y desactiva
*Optimización de MIUI* si la instalación se queda colgada.

---

## d) Enviar el APK al dispositivo de prueba

### Opción 1: one-click deploy desde Godot (iteración rápida)

Con el teléfono conectado y autorizado, pulsa el **icono de Android** en la
barra superior del editor. Godot exporta en debug, instala y abre el juego.
Es el flujo recomendado mientras se desarrolla.

### Opción 2: instalar un APK ya compilado con `adb`

```bash
~/Android/Sdk/platform-tools/adb install -r juego/JuegoChispita.apk
```

- `-r` reinstala conservando los datos (el progreso vive en
  `user://progreso.cfg`).
- Si aparece `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, el APK está firmado con otra
  clave: desinstala primero (ver abajo).
- Si aparece `INSTALL_FAILED_VERSION_DOWNGRADE`, añade `-d`.

### Opción 3: copiar el archivo al teléfono

Copia `juego/JuegoChispita.apk` por MTP, USB o almacenamiento en la nube, ábrelo
desde el gestor de archivos del teléfono y permite *Instalar apps desconocidas*
para esa aplicación.

### Abrir el juego

```bash
adb shell monkey -p com.eduardo.juegochispita -c android.intent.category.LAUNCHER 1
```

### Ver registros (útil si el juego no arranca)

```bash
adb logcat -s godot:V
```

### Desinstalar y limpiar datos

```bash
adb uninstall com.eduardo.juegochispita
```

Desinstalar borra el progreso guardado. Para inspeccionar los datos de una
build de debug sin desinstalar:

```bash
adb shell run-as com.eduardo.juegochispita ls -l files
```

---

## Problemas frecuentes

| Síntoma                                   | Causa probable / solución                                                        |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| `Export template not found`               | Plantillas de exportación ausentes o de otra versión que el editor.              |
| `Android SDK path is invalid`             | Ruta del SDK o del JDK mal configurada en *Configuración del editor*.            |
| `Failed to export project` con `apksigner` | JDK distinto de 17. Apunta `java_sdk_path` a `java-17-openjdk-amd64`.            |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE`      | APK firmado con otra clave: `adb uninstall com.eduardo.juegochispita` y reinstala. |
| `INSTALL_FAILED_NO_MATCHING_ABIS`         | El dispositivo/emulador no es `arm64-v8a`. Añade esa arquitectura al preset.     |
| El juego se cierra al abrir               | Revisa `adb logcat -s godot:V`; suele ser un recurso faltante o error de script. |
| `adb: no permissions`                     | Reglas udev (sección a) o cable solo de carga.                                   |

---

## Notas del repositorio

- `juego/JuegoChispita.apk` y su `.idsig` están versionados en Git (~47 MB).
  Regenera el APK antes de cada entrega para que coincida con el código.
- `juego/.gitignore` ignora `.godot/` y `juego/android/`, pero no el APK.
- El progreso del jugador se guarda en `user://progreso.cfg`; desinstalar la app
  lo elimina.
