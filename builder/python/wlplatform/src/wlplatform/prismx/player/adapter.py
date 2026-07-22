"""
PRISMX Player Adapter Interface
"""


from abc import ABC, abstractmethod


class PlayerAdapter(ABC):
    """
    Backend-neutral media player contract.
    """


    @abstractmethod
    def open(self, source):

        pass


    @abstractmethod
    def play(self):

        pass


    @abstractmethod
    def pause(self):

        pass


    @abstractmethod
    def stop(self):

        pass


    @abstractmethod
    def status(self):

        pass
