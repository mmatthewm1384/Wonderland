"""
Wonderland Event Dispatcher.
"""

from __future__ import annotations


class EventDispatcher:

    def __init__(self):
        self.subscribers = []


    def register(
        self,
        subscriber,
    ):
        self.subscribers.append(
            subscriber
        )


    def dispatch(
        self,
        event: dict,
    ):

        results = []

        for subscriber in self.subscribers:

            if subscriber.handles(event):

                result = subscriber.process(
                    event
                )

                if result:
                    results.append(result)

        return results
