# Dotfiles de Artix Linux (dinit + labwc + Wayland)

Este repositorio contiene mi configuración personal ("dotfiles") para un entorno de escritorio minimalista y moderno en **Artix Linux**, usando **dinit** como sistema de inicio, **BTRFS** como sistema de archivos y **labwc** como compositor de Wayland.

Además de los archivos de configuración, incluyo los scripts necesarios para realizar la instalación base del sistema operativo.

## 📂 Contenido del Repositorio

La carpeta principal de configuraciones (`dotfiles/`) contiene:

### Interfaz y Entorno Wayland
*   **`labwc/`**: Configuración del compositor (rc.xml, menu.xml, autostart, environment).
*   **`waybar/`**: Barra de estado, módulos y estilos CSS.
*   **`wofi/`**: Lanzador de aplicaciones.
*   **`mako/`**: Demonio de notificaciones.
*   **`swaylock/`**: Bloqueo de pantalla.
*   **`wlogout/`**: Menú de apagado/salida.
*   **`gtk-3.0` y `gtk-4.0`**: Configuración de temas e iconos para aplicaciones GTK.
*   **`foot/`**: Configuración del emulador de terminal.

### Herramientas y Shell
*   **`btop/`**: Monitor de recursos del sistema.
*   **`fastfetch/`**: Información del sistema al abrir la terminal.
*   **`.bashrc` y `.bash_profile`**: Configuración del shell Bash (aliases, variables de entorno, prompt).

### Instalación del Sistema
*   **`01-instalacion-base.sh`**: Script para el particionado, formateo e instalación base de Artix Linux.
*   **`02-post-instalacion.sh`**: Script para la configuración del sistema, instalación de paquetes (drivers, entorno Wayland, utilidades) y configuración de servicios.
*   **`lnk/` o `install...`**: Scripts o directorios utilizados para desplegar/enlazar estos dotfiles a sus ubicaciones finales (`~/.config`).

## 🛠️ Requisitos Previos

Este entorno está diseñado para funcionar sobre una instalación limpia de **Artix Linux** con las siguientes características:
*   Sistema de inicio: `dinit`.
*   Gestión de sesión: `elogind` (NO `seatd` ni `turnstile`).
*   Arranque UEFI.
*   Sistema de archivos BTRFS (con subvolúmenes).

## 🚀 Instalación

### Paso 1: Instalar el Sistema Operativo (Opcional)

Si estás partiendo de cero, usa los scripts incluidos en este repositorio. Arranca desde un Live USB de Artix Linux y ejecuta:

```bash
# 1. Dar permisos de ejecución
chmod +x 01-instalacion-base.sh
# 2. Ejecutar instalación base (te pedirá el disco y datos del usuario)
./01-instalacion-base.sh
