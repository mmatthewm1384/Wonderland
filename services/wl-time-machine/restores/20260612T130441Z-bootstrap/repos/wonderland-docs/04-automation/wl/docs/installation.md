# wl Installation

## Canonical Source

```text
~/Wonderland/repos/wonderland-docs/04-automation/wl
```

## Procedure

```shell
cd ~/Wonderland/repos/wonderland-docs/04-automation/wl
./install.sh
```

## PATH

Add to shell profile if needed:

```shell
export PATH="$HOME/Wonderland/tools/bin:$PATH"
```

## Verification

```shell
wl-status
wl-verify
```

## Rollback

```shell
rm -f ~/Wonderland/tools/bin/wl-*
rm -f ~/Wonderland/tools/lib/wl-common.sh
```
