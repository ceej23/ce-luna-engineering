#!/usr/bin/env python3
"""Open the two permitted assessment records without symlink races.

The caller supplies an absolute bundle directory and either ``events`` or
``exception``.  Bytes are copied while the descriptor-relative handles are
open; no path is reopened after validation.
"""

import errno
import os
import stat
import sys


def fail(code: int = 1) -> int:
    return code


def open_directory(root: str) -> int:
    if not root.startswith("/") or root == "/":
        raise OSError(errno.EINVAL, "bundle must be a non-root absolute path")
    nofollow = getattr(os, "O_NOFOLLOW", None)
    if nofollow is None or not hasattr(os, "O_DIRECTORY"):
        raise OSError(errno.ENOTSUP, "required open flags unavailable")
    fd = os.open("/", os.O_RDONLY | os.O_DIRECTORY | nofollow)
    try:
        for component in root.split("/")[1:]:
            if component in ("", ".", ".."):
                raise OSError(errno.EINVAL, "unsafe bundle path")
            next_fd = os.open(
                component,
                os.O_RDONLY | os.O_DIRECTORY | nofollow,
                dir_fd=fd,
            )
            os.close(fd)
            fd = next_fd
        return fd
    except Exception:
        os.close(fd)
        raise


def snapshot(bundle: str, record: str) -> int:
    if record not in ("events", "exception"):
        return fail()
    try:
        bundle_fd = open_directory(bundle)
        try:
            nofollow = getattr(os, "O_NOFOLLOW", None)
            if nofollow is None or not hasattr(os, "O_DIRECTORY"):
                return fail()
            try:
                record_fd = os.open(
                    f"{record}.tsv", os.O_RDONLY | nofollow, dir_fd=bundle_fd
                )
            except FileNotFoundError:
                return 2 if record == "exception" else fail()
            try:
                mode = os.fstat(record_fd).st_mode
                if not stat.S_ISREG(mode):
                    return fail()
                while True:
                    chunk = os.read(record_fd, 1024 * 1024)
                    if not chunk:
                        break
                    sys.stdout.buffer.write(chunk)
                sys.stdout.buffer.flush()
            finally:
                os.close(record_fd)
        finally:
            os.close(bundle_fd)
    except (OSError, ValueError):
        return fail()
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(1)
    raise SystemExit(snapshot(sys.argv[1], sys.argv[2]))
