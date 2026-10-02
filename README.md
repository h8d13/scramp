# Scramp

a simple *.in stamper to package scripts

there are only 2 rules:

1. `.in` files are never executable; a stamped file is made executable only if it starts with a `#!` shebang.

2. name commands without an extension (`hello.in`) and sourced files with `.sh` (`paths.sh.in`).

---

So you'd write code in `src/`, stamp vars/consts with `@something@`

Finally `declare` them in `buildit.sh`.
