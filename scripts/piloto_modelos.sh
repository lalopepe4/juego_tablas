#!/usr/bin/env bash
# Genera el piloto A/B de un activo con tres modelos de OpenRouter.
# Uso: bash scripts/piloto_modelos.sh [activo] [referencia]
# Coste orientativo: ~$0.10-0.20 por las tres imagenes.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

ACTIVO="${1:-Heroe_Chispita_atacando}"
REF="${2:-Ilustraciones/Heroe_Chispita_v01.png}"

if [[ ! -f "$REF" ]]; then
  echo "No se encontro la referencia: $REF" >&2
  exit 1
fi

MODELOS=(
  "google/gemini-nano-banana-2.1"
  "black-forest-labs/flux.2-pro"
  "qwen/qwen-image-3-pro"
)

for modelo in "${MODELOS[@]}"; do
  echo
  echo "=== $modelo ==="
  python3 scripts/generar_ilustraciones.py "$ACTIVO" \
    --ref "$REF" \
    --model "$modelo"
done

echo
echo "Piloto terminado. Revisa Ilustraciones/revision/ y compara."
