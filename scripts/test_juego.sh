#!/usr/bin/env sh
set -eu

RAIZ=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
GODOT="${GODOT:-godot}"

if ! command -v "$GODOT" >/dev/null 2>&1; then
	if command -v godot4 >/dev/null 2>&1; then
		GODOT=godot4
	else
		echo "No se encontro Godot. Define GODOT=/ruta/a/godot." >&2
		exit 127
	fi
fi

echo "== Importando el proyecto =="
"$GODOT" --headless --path "$RAIZ/juego" --import

echo "== Pruebas headless =="
"$GODOT" --headless --path "$RAIZ/juego" --script res://pruebas/ejecutar.gd

echo "== Arranque =="
"$GODOT" --headless --path "$RAIZ/juego" --quit-after 120

echo "TODO OK"
