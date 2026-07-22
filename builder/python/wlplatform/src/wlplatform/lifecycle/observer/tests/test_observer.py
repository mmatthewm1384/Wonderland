from wlplatform.lifecycle.observer.engine import (
    LifecycleObserverEngine
)

from wlplatform.lifecycle.observer.runtime import (
    RuntimeObserver
)

from wlplatform.lifecycle.observer.services import (
    ServiceObserver
)

from wlplatform.lifecycle.observer.dependencies import (
    DependencyObserver
)

from wlplatform.lifecycle.observer.certification import (
    CertificationObserver
)



def test_observer_snapshot():

    engine = LifecycleObserverEngine(

        RuntimeObserver(),

        ServiceObserver(),

        DependencyObserver(),

        CertificationObserver()

    )


    snapshot = engine.snapshot()


    data = snapshot.export()


    assert data["runtime"]["healthy"] is True

    assert data["certification"]["status"] == "CERTIFIED"
