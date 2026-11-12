import threading

import numpy as np


class LockFreeRingBuffer:
    def __init__(self, capacity: int, n_channels: int = 1) -> None:
        self.capacity: int = capacity
        self.n_channels: int = n_channels
        self.buffer: np.ndarray = np.zeros((capacity, n_channels), dtype=np.float32)
        self.head: int = 0
        self.tail: int = 0
        self._lock: threading.Lock = threading.Lock()

    def write(self, data: np.ndarray) -> int:
        n: int = int(data.shape[0])
        with self._lock:
            idx: np.ndarray = (self.head + np.arange(n)) % self.capacity
            self.buffer[idx] = data
            self.head = int((self.head + n) % self.capacity)
        return int(n)

    def read(self, n: int) -> np.ndarray:
        with self._lock:
            idx: np.ndarray = (self.tail + np.arange(n)) % self.capacity
            out: np.ndarray = self.buffer[idx].copy()
            self.tail = int((self.tail + n) % self.capacity)
        return out.astype(np.float32)
