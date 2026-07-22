from .adapter import RuntimeAdapter


class LifecycleRuntimeBridge:


    def __init__(self, adapter=None):

        self.runtime = (
            adapter
            or RuntimeAdapter()
        )


    def start(self):

        return self.runtime.start()


    def stop(self):

        return self.runtime.stop()


    def restart(self):

        return self.runtime.restart()


    def sleep(self):

        return self.runtime.sleep()


    def wake(self):

        return self.runtime.wake()


    def verify_health(self):

        return self.runtime.health()
