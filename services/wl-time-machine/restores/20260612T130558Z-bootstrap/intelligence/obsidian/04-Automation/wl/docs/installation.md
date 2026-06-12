# wl Installation

## Procedure

```shell
cd 04-automation/wl
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
```
