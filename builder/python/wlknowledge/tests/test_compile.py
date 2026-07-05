from pathlib import Path

from wlknowledge.compiler import compile_model

def test_compile_model_repo_root():
root = Path(file).resolve().parents[4]
model = compile_model(root)
assert model.system == "Wonderland Knowledge Engine"
assert isinstance(model.commands, list)
assert model.fingerprint
