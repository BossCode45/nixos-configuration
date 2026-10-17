#!/usr/bin/env python3
"""Convert nixfmt's 2-space indentation to tabs.

Usage: ./tabify-nix.py [FILE...]   (default: every git-tracked .nix file)

Only lines that start in code are touched. Lines that start inside a string
('' or ") are left exactly as they are, because Nix only strips leading
*spaces* from '' strings, so tabs there would change the string's value.
"""
import subprocess
import sys

INDENT = 2


def lex_line(line, stack):
    """Advance the lexer state `stack` over one line (mutates it in place).

    Stack entries: ["code", brace_depth], ["ind"] (''), ["dq"] ("), ["block"].
    A "code" entry above a string entry is a ${ } interpolation.
    """
    i, n = 0, len(line)
    while i < n:
        mode = stack[-1][0]
        rest = line[i:]
        if mode == "code":
            c = line[i]
            if c == "#":
                return
            if rest.startswith("/*"):
                stack.append(["block"])
                i += 2
            elif c == '"':
                stack.append(["dq"])
                i += 1
            elif rest.startswith("''"):
                stack.append(["ind"])
                i += 2
            elif c == "{":
                stack[-1][1] += 1
                i += 1
            elif c == "}":
                if stack[-1][1] == 0 and len(stack) > 1:
                    stack.pop()  # end of ${ } interpolation
                else:
                    stack[-1][1] -= 1
                i += 1
            else:
                i += 1
        elif mode == "block":
            if rest.startswith("*/"):
                stack.pop()
                i += 2
            else:
                i += 1
        elif mode == "dq":
            if rest.startswith("\\"):
                i += 2
            elif rest.startswith("$${"):
                i += 3
            elif rest.startswith("${"):
                stack.append(["code", 0])
                i += 2
            elif rest.startswith('"'):
                stack.pop()
                i += 1
            else:
                i += 1
        elif mode == "ind":
            if rest.startswith("'''") or rest.startswith("''$"):
                i += 3
            elif rest.startswith("''\\"):
                i += 4
            elif rest.startswith("''"):
                stack.pop()
                i += 2
            elif rest.startswith("$${"):
                i += 3
            elif rest.startswith("${"):
                stack.append(["code", 0])
                i += 2
            else:
                i += 1


def tabify(text):
    stack = [["code", 0]]
    out = []
    for line in text.split("\n"):
        if stack[-1][0] in ("code", "block"):
            stripped = line.lstrip(" \t")
            ws = line[: len(line) - len(stripped)]
            if stripped:
                tabs = ws.count("\t")
                spaces = ws.count(" ")
                line = "\t" * (tabs + spaces // INDENT) + " " * (spaces % INDENT) + stripped
            else:
                line = ""
        out.append(line)
        lex_line(line, stack)
    if stack != [["code", 0]]:
        raise ValueError(f"unbalanced lexer state at EOF: {stack}")
    return "\n".join(out)


def main():
    files = sys.argv[1:] or subprocess.run(
        ["git", "ls-files", "*.nix"], capture_output=True, text=True, check=True
    ).stdout.split()
    failed = False
    for path in files:
        with open(path) as f:
            src = f.read()
        try:
            new = tabify(src)
        except ValueError as e:
            print(f"{path}: {e}, skipped", file=sys.stderr)
            failed = True
            continue
        if new != src:
            with open(path, "w") as f:
                f.write(new)
            print(f"tabified {path}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
