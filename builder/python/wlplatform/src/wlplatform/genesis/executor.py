from pathlib import Path
from datetime import datetime, timezone

class GenesisExecutor:

    def __init__(self, root):
        self.root = Path(root)

    def crystal_status(self):

        crystal = self.root / "Crystal" / "us"

        return {
            "component": "crystal",
            "path": str(crystal),
            "exists": crystal.exists(),
            "timestamp": datetime.now(timezone.utc).isoformat()
        }


    def spark_status(self):
    
        sparks = self.root / "Sparks"
    
        result = []
    
        if sparks.exists():
            for item in sparks.iterdir():
                if (
                    item.is_dir()
                    and item.name.startswith("spark-")
                ):
                    result.append(item.name)
    
        return {
            "component": "sparks",
            "count": len(result),
            "items": sorted(result)
        }


    def verify(self):

        checks = {
            "crystal": (self.root / "Crystal").exists(),
            "registry": (self.root / "Registry").exists(),
            "sparks": (self.root / "Sparks").exists()
        }

        return {
            "verification": checks,
            "passed": all(checks.values())
        }
