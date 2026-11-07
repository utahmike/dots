#!/usr/bin/env bash
# Hardware-in-the-loop smoke test; needs the bench probe attached.
set -eu
if ! command -v hwprobe-ctl >/dev/null; then
    echo "hwprobe-ctl not found: attach the bench probe and install hwprobe tools" >&2
    exit 1
fi
hwprobe-ctl smoke --target greeter
