def get_viewport():
    """API contract: returns x, y, and scale.

    NOTE: the zoom factor is exposed as ``scale`` (not ``zoom``) — this is the
    public contract and must not change.
    """
    return {"x": 0, "y": 0, "scale": 1.0}
