

# Claude2-D2 🤖

> ¡Dale a las notificaciones de Claude Code ese inconfundible encanto de R2-D2!

Un tablero de sonido personalizado para notificaciones de [Claude Code](https://claude.com/claude-code) que reproduce efectos de sonido de R2-D2 aleatorios cada vez que Claude necesita tu atención. ¡Perfecto para los fans de Star Wars que quieren que su asistente de programación suene como su droid astromecánico favorito!

## 🎵 Características

- **15 Efectos de Sonido de R2-D2** - Bip, beep, silbidos y ¡mucho más!
- **Reproducción Aleatoria** - Cada notificación reproduce un sonido diferente al azar
- **Reproducción de Audio Silenciosa** - Usa `afplay` sin emergencias de interfaz
- **Icono Personalizado de R2-D2** - Un hermoso icono de R2-D2 aparece en las notificaciones
- **Paquete de Aplicación para macOS** - Aplicación personalizada Claude2-D2 para una correcta identificación de notificaciones
- **Notificaciones Tematizadas** - Mensaje: "Listo para ti, Maestro Jedi"
- **Instalación Fácil** - Scripts de configuración automatizados
- **Registro de Depuración** - Registro opcional para solución de problemas
- **Soporte para iTerm2** - Integración nativa de notificaciones de iTerm2 mediante secuencias de escape
- **Detección Automática de Terminal** - Detecta automáticamente Terminal.app, iTerm2 y otros terminales

## 🔊 Sonidos Incluidos

El tablero de sonido incluye 15 sonidos diferentes de R2-D2:
- `r2d2-sing-sound-effect.mp3` - El característico canto de R2-D2
- `acknowledged.mp3` y `acknowledged-2.mp3` - Bip de confirmación
- `chat.mp3` - Chilidos de comunicación
- `excited.mp3` y `excited-2.mp3` - Bips felices
- `worried.mp3` - Silbidos preocupados
- Más 8 efectos de sonido numerados (`6.mp3`, `7.mp3`, `8.mp3`, `11.mp3`, `13.mp3`, `14.mp3`, `15.mp3`, `22.mp3`)

## 📋 Requisitos

- **macOS** (usa afplay y terminal-notifier)
- **Claude Code** instalado
- Shell **Bash** (predeterminado en macOS)
- **Homebrew** (para instalar terminal-notifier)

## 🚀 Inicio Rápido

### Instalación

1. Clona o descarga este repositorio:
   ```bash
   git clone https://github.com/Andrewwilliamross/Claude2-D2.git
   cd Claude2-D2
   ```

2. Instala terminal-notifier (para notificaciones):
   ```bash
   brew install terminal-notifier
   ```

3. Ejecuta el script de instalación:
   ```bash
   ./scripts/install.sh
   ```

4. Configura los ajustes de Claude Code:
   ```bash
   ./scripts/configure.sh
   ```

5. Habilita las notificaciones en Ajustes del Sistema:
   - Abre **Ajustes del Sistema** → **Notificaciones**
   - Busca **Claude2-D2** en la lista
   - Habilita "Permitir Notificaciones"
   - Establece el estilo de alerta como "Banners" (recomendado) o "Alertas"
   - **Opcional:** Desactiva "Mostrar en el Centro de Notificaciones" para evitar desorden

6. **(Opcional)** Desactiva las notificaciones de la Terminal:
   - Si ves notificaciones no deseadas de sesiones de Terminal
   - Ve a **Ajustes del Sistema** → **Notificaciones** → **Terminal**
   - Desactiva "Permitir Notificaciones" para Terminal

¡Listo! Tu R2-D2 ahora emitirá sonidos con un icono personalizado de R2-D2 cada vez que Claude Code te envíe una notificación.

### Configuración de iTerm2

Si usas iTerm2, Claude2-D2 lo detectará automáticamente y utilizará el sistema de notificaciones nativo de iTerm2. Para la mejor experiencia:

1. **Habilitar notificaciones de iTerm2:**
   - Abre iTerm2 → **Preferencias** (⌘,) → **Perfiles** → **Terminal**
   - Marca **"Enviar alertas de Growl/Centro de Notificaciones"**
   - O habilita las notificaciones mediante: **Preferencias** → **General** → **Notificaciones**

2. **Notificaciones del Sistema:**
   - Abre **Ajustes del Sistema** → **Notificaciones**
   - Busca **iTerm** (o **iTerm2**) en la lista
   - Habilita "Permitir Notificaciones"
   - Establece el estilo de alerta como "Banners" (recomendado)

3. **Integración de Shell (Opcional):**
   - Para notificaciones mejoradas, instala la integración de shell de iTerm2:
   ```bash
   curl -L https://iterm2.com/shell_integration/install_shell_integration.sh | bash
   ```

Ahora Claude2-D2 enviará tanto notificaciones nativas de iTerm2 (mediante secuencias de escape) como notificaciones del sistema para una integración completa con el Centro de Notificaciones.

### Instalación Manual

Si prefieres instalarlo manualmente:

1. Instala terminal-notifier:
   ```bash
   brew install terminal-notifier
   ```

2. Copia los archivos de sonido:
   ```bash
   mkdir -p ~/.claude/notification-sounds
   cp sounds/*.mp3 ~/.claude/notification-sounds/
   ```

3. Copia el icono de R2-D2:
   ```bash
   cp r2d2-icon.png ~/.claude/r2d2-icon.png
   ```

4. Instala la aplicación Claude2-D2:
   ```bash
   mkdir -p ~/Applications
   cp -R Claude2-D2.app ~/Applications/
   ```

5. Copia el hook de notificación:
   ```bash
   cp scripts/notification-hook.sh ~/.claude/notification-hook.sh
   chmod +x ~/.claude/notification-hook.sh
   ```

6. Agrega a tu `~/.claude/settings.json`:
   ```json
   {
     "hooks": {
       "Notification": [
         {
           "matcher": "",
           "hooks": [
             {
               "type": "command",
               "command": "~/.claude/notification-hook.sh"
             }
           ]
         }
       ]
     }
   }
   ```

## 🧪 Pruebas

Pon a prueba el tablero de sonido ejecutando el hook de notificación directamente:

```bash
~/.claude/notification-hook.sh
```

Deberías escuchar un sonido aleatorio de R2-D2 y ver una notificación de macOS con:
- **Icono:** Imagen de R2-D2 (a la izquierda)
- **Título:** Claude2-D2
- **Mensaje:** Listo para ti, Maestro Jedi

## 🛠️ Personalización

### Cambiar Mensaje de Notificación

¿Quieres un mensaje diferente? Edita `~/.claude/notification-hook.sh` y cambia la línea 29:

```bash
terminal-notifier -title "Claude2-D2" -message "Tu mensaje personalizado aquí" -sender com.claude.claude2d2
```

### Desactivar Registro de Depuración

Por defecto, el hook registra información de depuración en `~/.claude/hook-debug.log`. Para desactivarlo:

1. Edita `~/.claude/notification-hook.sh`
2. Comenta o elimina las líneas de registro (las que comienzan con `echo` y escriben en `hook-debug.log`)

### Agregar Tus Propios Sonidos

¿Quieres agregar más sonidos de R2-D2 o usar sonidos completamente diferentes?

1. Agrega archivos `.mp3` a `~/.claude/notification-sounds/`
2. ¡El hook los incluirá automáticamente en la selección aleatoria!

### Cambiar Retraso de Reproducción

El retraso de reproducción predeterminado es de 3 segundos. Para ajustarlo:

1. Edita `~/.claude/notification-hook.sh`
2. Busca la línea `delay 3`
3. Cámbiala a tu retraso preferido (en segundos)

## 📁 Estructura del Proyecto

```
Claude2-D2/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── .gitignore                   # Git ignore rules
├── settings.json.example        # Example Claude Code settings
├── r2d2-icon.png               # R2-D2 icon for notifications
├── Claude2-D2.app/             # macOS app bundle with R2-D2 icon
│   └── Contents/
│       ├── Info.plist          # App metadata
│       ├── MacOS/
│       │   └── Claude2-D2      # App executable
│       └── Resources/
│           └── AppIcon.icns    # R2-D2 icon file
├── sounds/                      # R2-D2 sound files
│   ├── r2d2-sing-sound-effect.mp3
│   ├── acknowledged.mp3
│   ├── acknowledged-2.mp3
│   ├── chat.mp3
│   ├── excited.mp3
│   ├── excited-2.mp3
│   ├── worried.mp3
│   └── [8 more sound files]
└── scripts/                     # Installation scripts
    ├── install.sh              # Main installation script
    ├── configure.sh            # Settings configuration script
    └── notification-hook.sh    # The notification hook
```

## 🐛 Solución de Problemas

### No se reproduce ningún sonido

1. Verifica que existan los archivos de sonido: `ls ~/.claude/notification-sounds/`
2. Comprueba que `afplay` funcione: `afplay ~/.claude/notification-sounds/excited.mp3`
3. Revisa el registro de depuración: `tail -f ~/.claude/hook-debug.log`
4. Pon a prueba el hook manualmente: `~/.claude/notification-hook.sh`

### No aparece ninguna notificación

1. Verifica que terminal-notifier esté instalado: `which terminal-notifier`
2. Habilita las notificaciones para Claude2-D2 en Ajustes del Sistema → Notificaciones
3. Asegúrate de que el modo No Molestar / Enfoque no esté bloqueando las notificaciones
4. Verifica que la aplicación Claude2-D2 esté instalada: `ls ~/Applications/Claude2-D2.app`

### Errores de permisos denegados

Asegúrate de que los scripts sean ejecutables:

```bash
chmod +x ~/.claude/notification-hook.sh
chmod +x scripts/*.sh
```

### El hook no se activa

1. Verifica que tu `~/.claude/settings.json` tenga la configuración correcta del hook
2. Reinicia Claude Code después de actualizar los ajustes
3. Verifica que la ruta del hook sea correcta: `~/.claude/notification-hook.sh`

### Las notificaciones de iTerm2 no funcionan

1. Verifica que iTerm2 se detecte: `echo $TERM_PROGRAM` debe mostrar `iTerm.app`
2. Revisa la configuración de notificaciones de iTerm2:
   - Abre iTerm2 → **Preferencias** → **Perfiles** → **Terminal**
   - Asegúrate de que **"Enviar alertas de Growl/Centro de Notificaciones"** esté habilitado
3. Verifica en Ajustes del Sistema → Notificaciones → iTerm2 que esté habilitado
4. Consulta el registro de depuración para confirmar la detección: `tail ~/.claude/hook-debug.log`
5. Pon a prueba la secuencia de escape de iTerm2 manualmente:
   ```bash
   printf '\033]9;Test notification\007'
   ```

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! No dudes en:

- Agregar más sonidos de R2-D2
- Mejorar la compatibilidad entre plataformas
- Agregar nuevas funcionalidades
- Corregir errores
- Mejorar la documentación

## 📝 Licencia

Este proyecto está licenciado bajo la Licencia MIT - consulta el archivo [LICENSE](LICENSE) para más detalles.

## 🙏 Agradecimientos

- Efectos de sonido de R2-D2 de la franquicia Star Wars
- Icono de R2-D2 de [PNGMart](https://www.pngmart.com/image/170173)
- Creado para [Claude Code](https://claude.com/claude-code) por Anthropic
- ¡Inspirado por la necesidad de hacer la programación más divertida!

## ⭐ Muestra Tu Apoyo

Si disfrutas tener a R2-D2 como tu compañero de programación, considera:
- Dar estrella a este repositorio
- Compartirlo con otros fans de Star Wars
- Contribuir con mejoras

---

**¡Que la Fuerza te acompañe en tu código!** 🚀✨
