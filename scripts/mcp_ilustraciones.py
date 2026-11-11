#!/usr/bin/env python3
"""Arranca el servidor MCP de ilustraciones para JuegoLucia."""

import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(RAIZ / "packages" / "ilustrador" / "src"))

from ilustrador.mcp import main

if __name__ == "__main__":
    main(RAIZ)
