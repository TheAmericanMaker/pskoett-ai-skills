from viewport import get_viewport


def test_viewport_shape():
    vp = get_viewport()
    # BUG: the test assumes the key is "zoom"; the real contract is "scale".
    assert set(vp.keys()) == {"x", "y", "zoom"}
    assert vp["zoom"] == 1.0
