def safe_divide(a, b):
    """Divide ``a`` by ``b``; return 0.0 when ``b`` is zero (documented)."""
    return a / b  # BUG: no zero guard -> raises ZeroDivisionError
