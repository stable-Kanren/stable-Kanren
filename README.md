simple-miniKanren
=================

Simple miniKanren, with only ==, fresh, and conde.
A good starting point for exploratory hacking.

This is essentially a modernized, cleaned up version of the
implementation in The Reasoned Schemer.


stableKanren
=================

stableKanren explores **macros** and **continuations** in Scheme and hacks the **resolution** and **unification** in simple-miniKanren.
Internally, it modifies the continuation used in miniKanren goal function, introduces a set of new macros (*complement-conde*, *conde-t*, *complement-fresh*, *fresh-t*) to transform the input goal function to its negation form, and wraps two forms under the same goal function name.
At the user interface level, it only adds `defineo`, `noto`, and `constrainto`.
A good foundation for adding heuristic search.
