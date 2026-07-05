from __future__ import annotations

from pathlib import Path

from wlknowledge.model import KnowledgeModel
from wlknowledge.scanners.applications import scan_applications
from wlknowledge.scanners.commands import scan_commands
from wlknowledge.scanners.documentation import scan_decisions, scan_documents
from wlknowledge.scanners.repository import scan_repository
from wlknowledge.scanners.services import scan_services


def compile_model(root: Path) -> KnowledgeModel:
    model = KnowledgeModel()
    model.repository = scan_repository(root)
    model.commands = scan_commands(root)
    model.applications = scan_applications(root)
    model.services = scan_services(root)
    model.documents = scan_documents(root)
    model.decisions = scan_decisions(root)
    return model.finalize()
