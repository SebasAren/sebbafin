---
description: Fedora container build quirks and gotchas
---

- **Don't remove `pkgconf` in build cleanup**: `kmod` (kernel module management) requires `/usr/bin/pkg-config` at runtime via `pkgconf-pkg-config`. This means `pkgconf` is a transitive dependency of `systemd-udev` and cannot be removed in a `dnf5 remove` step without breaking the transaction.
