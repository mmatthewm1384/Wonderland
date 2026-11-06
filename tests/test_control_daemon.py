from unittest.mock import MagicMock
import pytest
from wonderland.core.adapters import CrystalAuditStore
from wonderland.core.protocols import AuditStore, ControlExecutor
from wonderland.daemons.control import ControlDaemonService

@pytest.fixture
def mock_executor():
    executor = MagicMock(spec=ControlExecutor)
    executor.spawn_service.return_value = True
    executor.terminate_service.return_value = True
    return executor

@pytest.fixture
def mock_audit_store():
    store = MagicMock(spec=AuditStore)
    return store

def test_control_daemon_start_success(mock_executor, mock_audit_store):
    daemon = ControlDaemonService(executor=mock_executor, audit_store=mock_audit_store)
    daemon.handle_service_lifecycle("control-daemon", "start")
    mock_executor.spawn_service.assert_called_once_with("control-daemon")
    mock_audit_store.log_event.assert_called_once()
    _, _, payload = mock_audit_store.log_event.call_args[0]
    assert payload["service"] == "control-daemon"
    assert payload["status"] == "SUCCESS"

def test_control_daemon_stop_failure(mock_executor, mock_audit_store):
    mock_executor.terminate_service.return_value = False
    daemon = ControlDaemonService(executor=mock_executor, audit_store=mock_audit_store)
    daemon.handle_service_lifecycle("crystal.audit", "stop")
    mock_executor.terminate_service.assert_called_once_with("crystal.audit")
    _, _, payload = mock_audit_store.log_event.call_args[0]
    assert payload["service"] == "crystal.audit"
    assert payload["status"] == "FAILED"

def test_control_daemon_unknown_action(mock_executor, mock_audit_store):
    daemon = ControlDaemonService(executor=mock_executor, audit_store=mock_audit_store)
    daemon.handle_service_lifecycle("test-service", "restart")
    mock_audit_store.log_event.assert_called_once()
    _, _, payload = mock_audit_store.log_event.call_args[0]
    assert payload["status"] == "FAILED"
    assert payload["action"] == "restart"

def test_crystal_audit_store_file_persistence(tmp_path):
    log_file = tmp_path / "crystal_audit.log"
    store = CrystalAuditStore(log_path=str(log_file))
    store.log_event("control-daemon", "TEST_CHECKPOINT", {"node_id": "alpha-1"})
    assert log_file.exists()
    content = log_file.read_text()
    assert "CONTROL-DAEMON" in content
    assert "TEST_CHECKPOINT" in content
    assert "alpha-1" in content
    
    entries = store.get_entries()
    assert len(entries) == 1
    assert entries[0]["service"] == "CONTROL-DAEMON"

def test_crystal_audit_store_edge_cases(tmp_path):
    log_file = tmp_path / "non_existent.log"
    store = CrystalAuditStore(log_path=str(log_file))
    assert store.get_entries() == []
    
    log_file.write_text("invalid json line\n{\"service\": \"TEST\"}\n")
    entries = store.get_entries()
    assert len(entries) == 1
    assert entries[0]["service"] == "TEST"

def test_control_daemon_run_safely(mock_audit_store):
    class FaultyExecutor:
        def execute(self, cmd: str):
            raise RuntimeError("fail")
    daemon = ControlDaemonService(executor=FaultyExecutor(), audit_store=mock_audit_store)
    assert daemon.run_safely("bad_cmd") is False

def test_control_daemon_run_safely_success(mock_audit_store):
    """Verify that run_safely returns True when execution succeeds."""
    class SuccessExecutor:
        def execute(self, cmd: str):
            pass

    daemon = ControlDaemonService(executor=SuccessExecutor(), audit_store=mock_audit_store)
    assert daemon.run_safely("good_cmd") is True
