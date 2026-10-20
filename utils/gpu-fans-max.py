#!/usr/bin/env python3
"""Set every controllable fan on every NVIDIA GPU to 100% (manual mode).

Requires: pip install nvidia-ml-py, and root (sudo) on Linux.
Usage:    sudo python3 gpu_fans_max.py [--speed 100]

The speed persists after this script exits. Run gpu_fans_auto.py to restore
the driver's automatic fan control.
"""
import argparse
import os
import sys

import pynvml as nvml


def name_of(handle):
    name = nvml.nvmlDeviceGetName(handle)
    return name.decode() if isinstance(name, bytes) else name


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--speed", type=int, default=100,
                        help="fan speed percent to set (default: 100)")
    args = parser.parse_args()
    if not 0 <= args.speed <= 100:
        sys.exit("--speed must be between 0 and 100")

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

            set_fans = 0
            for fan in range(num_fans):
                try:
                    nvml.nvmlDeviceSetFanSpeed_v2(handle, fan, args.speed)
                    set_fans += 1
                except nvml.NVMLError as e:
                    print(f"  GPU {i} fan {fan}: failed ({e})")

            if set_fans == 0:
                skipped.append((i, name, "all fan set calls failed"))
                continue

            ok += 1
            try:
                speeds = [nvml.nvmlDeviceGetFanSpeed_v2(handle, f)
                          for f in range(num_fans)]
            except nvml.NVMLError:
                speeds = ["n/a"]
            print(f"GPU {i} ({name}): set {set_fans}/{num_fans} fan(s) "
                  f"to {args.speed}% -> reported {speeds}")
    finally:
        nvml.nvmlShutdown()

    for i, name, reason in skipped:
        print(f"WARNING: GPU {i} ({name}) skipped: {reason}", file=sys.stderr)
    print(f"Done: {ok} GPU(s) updated, {len(skipped)} skipped.")
    sys.exit(0 if ok or not skipped else 1)


if __name__ == "__main__":
    main()
