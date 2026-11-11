"""Pipeline reutilizable de generacion de ilustraciones."""

from .catalogo import Activo, Catalogo, Proyecto, cargar_proyecto
from .errores import IlustracionError
from .servicio import ResultadoGeneracion, generar_ilustracion, preparar_revisiones

__all__ = [
    "Activo",
    "Catalogo",
    "IlustracionError",
    "Proyecto",
    "ResultadoGeneracion",
    "cargar_proyecto",
    "generar_ilustracion",
    "preparar_revisiones",
]
