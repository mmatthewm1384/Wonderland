from research.correspondence.experiments.synthetic import bistable_series, rescale_series
from research.correspondence.normalize import normalize_polarity


def test_synthetic_reversal_is_bounded_and_centered():
    s = bistable_series(points=101, duration=10, rate=1)
    p = normalize_polarity(s.polarity)
    assert max(p) <= 1
    assert min(p) >= -1
    assert abs(p[50]) < 1e-12


def test_rescaling_preserves_polarity_shape():
    a = bistable_series(points=101, duration=10, rate=1)
    b = rescale_series(a, time_scale=1000, polarity_scale=2)
    assert normalize_polarity(a.polarity) == normalize_polarity(b.polarity)
