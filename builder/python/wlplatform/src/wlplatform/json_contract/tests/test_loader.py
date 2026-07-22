from wlplatform.json.loader import load_artifact


def test_loader_reads_json(tmp_path):
    file = tmp_path / "test.json"
    file.write_text('{"certified": true}')

    result = load_artifact(file)

    assert result["artifact"]["certified"] is True
    assert result["metadata"]["validated"] is True
