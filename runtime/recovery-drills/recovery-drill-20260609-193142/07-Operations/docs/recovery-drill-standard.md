# Recovery Drill Standard
<!-- id: recovery-drill-standard-v4 -->

Purpose:
Defines how Wonderland proves recovery capability without modifying the live vault.

Recovery drill command:
    wl recovery drill

Procedure:

1. Create verified snapshot
2. Verify snapshot checksum
3. Extract snapshot into runtime recovery drill directory
4. Confirm required vault layers exist
5. Write recovery drill report
6. Index operational reports

Rule:
A recovery system is not trusted until recovery has been tested.

state: active
version: 4
