# Wonderland Runtime Certification

Date: 20260801

## CLI

Status:
{
    "service": "platform",
    "status": "ready",
    "runtime": {
        "service": "runtime",
        "action": "status",
        "timestamp": "2026-08-01T11:55:54.801747+00:00",
        "adapter": {
            "adapter": "lima",
            "instance": "wonderland-rootless",
            "lima": {
                "command": [
                    "limactl",
                    "list",
                    "wonderland-rootless"
                ],
                "exit_code": 0,
                "stdout": "NAME                   STATUS     SSH                VMTYPE    ARCH       CPUS    MEMORY    DISK      DIR\nwonderland-rootless    Stopped    127.0.0.1:62259    vz        aarch64    4       8GiB      100GiB    ~/.lima/wonderland-rootless",
                "stderr": ""
            }
        }
    }
}

## Certification

Generated during runtime certification pass.

