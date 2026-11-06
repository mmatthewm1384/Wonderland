import numpy as np
import threading

class LockFreeRingBuffer:
    def __init__(self, capacity: int, n_channels: int = 1):
        self.capacity = capacity
        self.n_channels = n_channels
        self.buffer = np.zeros((capacity, n_channels), dtype=np.float32)
        self.head = 0
        self.tail = 0
        self._lock = threading.Lock()

    def write(self, data: np.ndarray) -> int:
        n = data.shape[0]
        with self._lock:
            idx = (self.head + np.arange(n)) % self.capacity
            self.buffer[idx] = data
            self.head = (self.head + n) % self.capacity
        return n

    def read(self, n: int) -> np.ndarray:
        with self._lock:
            idx = (self.tail + np.arange(n)) % self.capacity
            out = self.buffer[idx].copy()
            self.tail = (self.tail + n) % self.capacity
        return out
