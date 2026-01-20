---
description: Walk through branch changes from usage to implementation
---

Review this branch in a usage-first order.

Start from the public API or exported functions. If changes are internal, start from the branch's main entry point. Always: usage first, then implementation.

Group changes by concept or responsibility - logical units that belong together, even if they span multiple files. Balance chunk sizes so each is digestible.

For each chunk, explain what the code does. Reference files and line numbers only; do not reprint code.

After each chunk, stop and wait for a response before continuing.

If questions or deeper dives come up, answer inline and resume from the same place.
