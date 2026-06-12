# wl Recovery

## Failure

`wl-*` commands are missing or broken.

## Recovery Procedure

1. Restore the automation repository or package.
2. Run `04-automation/wl/install.sh`.
3. Verify with `wl-status`.
4. Verify with `wl-verify`.

## Manual Fallback

All core workspace operations can be performed manually using documented shell commands.

## Rollback

Remove installed commands:

```shell
rm -f ~/Wonderland/tools/bin/wl-*
```
