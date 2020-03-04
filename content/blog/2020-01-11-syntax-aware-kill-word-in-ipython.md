---
title: "Syntax-aware redefinition of kill-word in IPython"
date: "2020-01-11T12:00:42+01:00"
language: en
slug: syntax-aware-kill-word-in-ipython
---

Although [IPython](https://ipython.org/) to me is the best of [all](https://bpython-interpreter.org) [the](http://bipython.org) [Python](https://github.com/prompt-toolkit/ptpython) [REPLs](https://docs.python.org/3/tutorial/interpreter.html#interactive-mode), there is something that bothered me about it for a while: Alt-Backspace is one of the shortcuts I use most. In many shell contexts, as well as generally in text editing, it removes the last word behind the cursor, i.e. the last word I wrote. It is a very useful shortcut to fix missspelled words or when after writing it I notice a word does not really work in a context after all and I want to replace it. This removal the last word is often called the "kill-word command".

Usually you'd expect the shortcut to remove "true" words when writing prose i.e.: whitespace. That is also how IPython applies it but for writing Python expressions at a REPL I would define word boundaries a little differently, namely as: All things separated by the programming language's non-word characters. For Python this amounts to spaces, `=`, `.`, `_`, `-`, and maybe even a bunch of other characters or character combinations. Except for spaces, IPython ignores them blissfully by default. This becomes most apparent in my daily work, when entering imports at the REPL. For example I were to misstype

```
In [1]: from django.db.models.fucntions  # <= Oops, I scrambled the letters C and N
```

I'd expect Alt-Backspace to only remove `fucntions`, so I can replace the word with `functions`. Instead what IPython (or being more precise: the underlying [prompt-toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit)) does is remove the entire module path, leaving only

```
In [1]:  from
```

That gets particularly annoying for long module paths of course. After some digging through the implementation of the kill-word functionality in the prompt-toolkit, I found a simple yet effective solution to make IPython more syntax-aware there. The following code snippet overrides the keybinding with a more "intelligent" version of original, that defines a word boundary with a more flexible regular expression `r"([^\s/\.\=\_\-]+)"`, i.e. a word consists of combination of characters that does *not* contain a space, `.`, `=`, `_`, or `-`. Which is what I did, and thanks to IPython's ability to script the shell startup, my `~/.ipython/profile_default/startup/10-sub-word-kill.py` now contain this:

```python
import re
from IPython import get_ipython
from prompt_toolkit import Application
from prompt_toolkit import Applicationt
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import ViInsertMode, EmacsInsertMode

ip = get_ipython()
insert_mode = ViInsertMode() | EmacsInsertMode()

FIND_SYNTAX_WORD_RE = re.compile(r"([^\s/\.\=\_\-]+)")


def syntax_word_kill(event, WORD=True):
    """
    Kill the "syntactical word" behind point, using whitespace and a few other
    characters as a word boundary. Usually bound to M-Backspace.
    """
    buff = event.current_buffer
    pos = buff.document.find_start_of_previous_word(
        count=event.arg, pattern=FIND_SYNTAX_WORD_RE
    )

    if pos is None:
        # Nothing found? delete until the start of the document.  (The
        # input starts with whitespace and no words were found before the
        # cursor.)
        pos = -buff.cursor_position

    if pos:
        deleted = buff.delete_before_cursor(count=-pos)

        # If the previous key press was also Control-W, concatenate deleted
        # text.
        if event.is_repeat:
            deleted += event.cli.clipboard.get_data().text

        event.cli.clipboard.set_text(deleted)
    else:
        # Nothing to delete. Bell.
        event.cli.output.bell()


# Register the shortcut if IPython is using prompt_toolkit
if getattr(ip, "pt_app", None):
    registry = ip.pt_app.key_bindings
    registry.add_binding(Keys.Escape, Keys.Backspace, filter=insert_mode)(syntax_word_kill)
```