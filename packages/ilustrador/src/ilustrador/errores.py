"""Errores de negocio del pipeline de ilustraciones."""


class IlustracionError(RuntimeError):
    """Error recuperable del pipeline.

    La libreria nunca llama a ``sys.exit``: el CLI lo traduce a un mensaje y
    codigo de salida, y el servidor MCP lo devuelve como error de tool.
    """
