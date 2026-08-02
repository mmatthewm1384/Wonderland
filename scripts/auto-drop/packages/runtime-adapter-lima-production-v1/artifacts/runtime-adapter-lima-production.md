# Runtime Adapter Lima Production v1

## Responsibility

Production execution boundary for Wonderland runtime.

## Supported lifecycle

- start
- stop
- status

## Runtime

Lima:
wonderland-rootless

Container runtime:
rootless nerdctl

## Ownership

RuntimeService orchestrates.

LimaAdapter executes.

CLI does not call limactl directly.
