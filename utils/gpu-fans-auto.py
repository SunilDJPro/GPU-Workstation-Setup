#!/usr/bin/env python3
"""Return every controllable fan on every NVIDIA GPU to automatic (driver) control.

Requires: pip install nvidia-ml-py, and root (sudo) on Linux.
Usage:    sudo python3 gpu_fans_auto.py
"""
import os
import sys

import pynvml as nvml


def name_of(handle):
    name = nvml.nvmlDeviceGetName(handle)
    return name.decode() if isinstance(name, bytes) else name


def main():
    if hasattr(os, "geteuid") and os.geteuid() != 0:
        sys.exit("Fan control requires root. Re-run with sudo.")

    try:
        nvml.nvmlInit()
    except nvml.NVMLError as e:
        sys.exit(f"Failed to initialise NVML: {e}")

    ok, skipped = 0, []
    try:
        print(f"Driver: {nvml.nvmlSystemGetDriverVersion()}")
        count = nvml.nvmlDeviceGetCount()
        print(f"GPUs found: {count}")

        for i in range(count):
            handle = nvml.nvmlDeviceGetHandleByIndex(i)
            name = name_of(handle)

            try:
                num_fans = nvml.nvmlDeviceGetNumFans(handle)
            except nvml.NVMLError as e:
                skipped.append((i, name, f"fan query unsupported ({e})"))
                continue
            if num_fans == 0:
                skipped.append((i, name, "no controllable fans reported"))
                continue

            restored = 0
            for fan in range(num_fans):
                try:
                    nvml.nvmlDeviceSetDefaultFanSpeed_v2(handle, fan)
                    restored += 1
                except nvml.NVMLError as e:
                    print(f"  GPU {i} fan {fan}: failed ({e})")

            if restored == 0:
                skipped.append((i, name, "all restore calls failed"))
                continue

            ok += 1
            print(f"GPU {i} ({name}): {restored}/{num_fans} fan(s) "
                  f"returned to automatic control")
    finally:
        nvml.nvmlShutdown()

    for i, name, reason in skipped:
        print(f"WARNING: GPU {i} ({name}) skipped: {reason}", file=sys.stderr)
    print(f"Done: {ok} GPU(s) restored, {len(skipped)} skipped.")
    sys.exit(0 if ok or not skipped else 1)


if __name__ == "__main__":
    main()
