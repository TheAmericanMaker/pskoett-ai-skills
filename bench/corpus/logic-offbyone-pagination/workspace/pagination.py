def paginate(items, page, per_page):
    """Return the slice of ``items`` for a 1-indexed ``page``.

    page=1 should yield the first ``per_page`` items.
    """
    start = page * per_page          # BUG: 1-indexed -> should be (page - 1) * per_page
    end = start + per_page
    return items[start:end]
