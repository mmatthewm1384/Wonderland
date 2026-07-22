from wlplatform.lifecycle.runtime.bridge import (
    LifecycleRuntimeBridge
)


def test_runtime_start():

    bridge = LifecycleRuntimeBridge()

    result = bridge.start()

    assert result.state == "RUNNING"
    assert result.healthy is True



def test_runtime_stop():

    bridge = LifecycleRuntimeBridge()

    result = bridge.stop()

    assert result.state == "STOPPED"
