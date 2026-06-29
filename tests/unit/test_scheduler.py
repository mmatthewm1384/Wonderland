from __future__ import annotations

import unittest

from wl_controller.kernel.scheduler import Scheduler


class SchedulerTests(unittest.TestCase):
    def test_scheduler_runs_due_task(self):
        runs = {"count": 0}

        def task():
            runs["count"] += 1

        scheduler = Scheduler()
        scheduler.add("test", 0, task)
        scheduler.tick()

        self.assertEqual(runs["count"], 1)
        self.assertEqual(scheduler.tasks[0].runs, 1)
        self.assertEqual(scheduler.tasks[0].failures, 0)

    def test_scheduler_records_failure(self):
        def task():
            raise RuntimeError("boom")

        scheduler = Scheduler()
        scheduler.add("bad", 0, task)
        scheduler.tick()

        self.assertEqual(scheduler.tasks[0].runs, 0)
        self.assertEqual(scheduler.tasks[0].failures, 1)
        self.assertIn("boom", scheduler.tasks[0].last_error)


if __name__ == "__main__":
    unittest.main()
