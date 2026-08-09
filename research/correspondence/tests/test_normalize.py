from research.correspondence.normalize import normalize_polarity


def test_normalize_polarity():
    assert normalize_polarity([-2, 0, 2]) == [-1.0, 0.0, 1.0]


def test_zero_series():
    assert normalize_polarity([0, 0]) == [0.0, 0.0]
