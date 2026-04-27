#!/usr/bin/env python3
"""
PICO-8 token counter — calibrated to match PICO-8's INFO command exactly.

Rules (reverse-engineered):
  NOT counted: commas, periods, 'local', 'end', 'in',
               closing brackets ) ] }, comments
  Everything else counts as 1 token.

Usage: python3 count_tokens.py [bobby.p8]
"""
import re, sys

NO_COUNT_WORDS   = {'local', 'end', 'in'}
NO_COUNT_BRACKET = {')', ']', '}'}

TOKEN_RE = re.compile(r'''
    (?P<string>   \[\[.*?\]\] | "(?:[^"\\]|\\.)*" | '(?:[^'\\]|\\.)*' )
  | (?P<hexnum>   0x[0-9a-fA-F]+(?:\.[0-9a-fA-F]*)? )
  | (?P<decnum>   \d+(?:\.\d*)? )
  | (?P<multiop>  !=|~=|==|<=|>=|\.\.|\.\.=|\+=|-=|\*=|/=|%=|\^=|<<=|>>=|<<>|>><)
  | (?P<singleop> [+\-*/%\^&|~<>=!\\#;:])
  | (?P<bracket>  [(){}\[\]])
  | (?P<skip>     [,.])
  | (?P<word>     [A-Za-z_][A-Za-z0-9_]*)
''', re.VERBOSE | re.DOTALL)


def count_tokens(lua_src: str) -> int:
    src = re.sub(r'--\[\[.*?\]\]', ' ', lua_src, flags=re.DOTALL)
    src = re.sub(r'--[^\n]*', ' ', src)
    n = 0
    for match in TOKEN_RE.finditer(src):
        kind = match.lastgroup
        val  = match.group()
        if kind == 'skip':
            continue
        if kind == 'word'    and val in NO_COUNT_WORDS:
            continue
        if kind == 'bracket' and val in NO_COUNT_BRACKET:
            continue
        n += 1
    return n


def main():
    fname = sys.argv[1] if len(sys.argv) > 1 else 'bobby.p8'
    with open(fname, encoding='latin-1') as f:
        content = f.read()
    m = re.search(r'__lua__\n(.*?)(?:\n__[a-z]+__|$)', content, re.DOTALL)
    if not m:
        print('No __lua__ section found'); sys.exit(1)
    n = count_tokens(m.group(1))
    remaining = 8192 - n
    print(f'Tokens used : {n} / 8192')
    print(f'Remaining   : {remaining}')
    if remaining < 200:
        print('WARNING: very low token budget!')


if __name__ == '__main__':
    main()
