# ============================================================
# INK · ~/.bash_profile  (versión robusta para cambio de PC)
# Arranca labwc automáticamente al iniciar sesión en tty1.
# Si labwc falla, NO te deja en un login vacío: muestra el error
# y cae a un shell normal para que puedas diagnosticar.
# ============================================================

# PATH personal
for d in "$HOME/bin" "$HOME/.local/bin"; do
    if [ -d "$d" ] && [[ ":$PATH:" != *":$d:"* ]]; then
        PATH="$d:$PATH"
    fi
done
export PATH

# Editor por defecto (nvim si existe, si no vim)
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim VISUAL=nvim
else
    export EDITOR=vim VISUAL=vim
fi

# -------- lo necesario para que labwc pueda arrancar --------

# XDG_RUNTIME_DIR: lo crea turnstile/elogind/systemd al hacer login.
# Fallback a /tmp si no existe.
if [ -z "$XDG_RUNTIME_DIR" ]; then
    if [ -d "/run/user/$(id -u)" ] && [ -w "/run/user/$(id -u)" ]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    else
        export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
        mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
    fi
fi

export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=labwc
export XDG_SESSION_DESKTOP=labwc

# CAMBIO 1: ya no se fuerza seatd. Si el PC nuevo usa logind/elogind,
# forzar seatd rompe el arranque. Solo se usa seatd si logind no está
# disponible y el socket de seatd existe.
if [ -z "$LIBSEAT_BACKEND" ]; then
    if [ -S /run/seatd.sock ] && [ ! -d /run/systemd/seats ] && ! pgrep -x elogind >/dev/null 2>&1; then
        export LIBSEAT_BACKEND=seatd
    fi
fi

# CAMBIO 2: GPU NVIDIA (muy común al cambiar de PC): evita cursor
# invisible/pantalla negra en wlroots.
if [ -d /proc/driver/nvidia ]; then
    export WLR_NO_HARDWARE_CURSORS=1
fi

# Si labwc no arranca por problemas de GPU, descomenta esta línea:
# export WLR_RENDERER=pixman

# El resto de variables (MOZ_ENABLE_WAYLAND, QT_QPA_PLATFORM, XCURSOR_*,
# etc.) viven en ~/.config/labwc/environment.

# Español para fechas en shell (opcional)
# export LC_TIME=es_ES.UTF-8

# -------- arrancar labwc --------
# CAMBIO 3: acepta tty1 o VT 1 (XDG_VTNR) por si $(tty) no coincide.
_on_tty1=0
if [ "$(tty 2>/dev/null)" = "/dev/tty1" ] || [ "${XDG_VTNR:-}" = "1" ]; then
    _on_tty1=1
fi

if [ -z "$WAYLAND_DISPLAY" ] && [ -z "$DISPLAY" ] && [ "$_on_tty1" = "1" ]; then
    if ! command -v labwc >/dev/null 2>&1; then
        echo "⚠ labwc no está instalado en este PC. Instálalo y vuelve a entrar."
    else
        mkdir -p "$HOME/.local/state"
        _log="$HOME/.local/state/labwc.log"
        [ -f "$_log" ] && mv -f "$_log" "$_log.old"

        # CAMBIO 4: sin 'exec', para ver el error si falla.
        if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && command -v dbus-run-session >/dev/null 2>&1; then
            dbus-run-session labwc >"$_log" 2>&1
        else
            labwc >"$_log" 2>&1
        fi
        _rc=$?

        if [ "$_rc" -eq 0 ]; then
            exit 0   # cierre normal de sesión
        fi

        echo "⚠ labwc terminó con error (código $_rc). Últimas líneas del log:"
        tail -n 15 "$_log"
        echo "Log completo: $_log"
        echo "Pistas: ¿estás en el grupo 'seat'/'video'/'input'? ¿seatd/elogind corriendo?"
    fi
fi
unset _on_tty1 _log _rc

# Si no arrancamos labwc seguimos como login shell normal
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
