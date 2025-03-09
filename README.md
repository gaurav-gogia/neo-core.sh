# 🛠️ neo-core.sh

🚀 **A Pure POSIX Shell Library for Data Structures and Utilities**

`neo-core.sh` is a **lightweight, POSIX-compliant shell library** providing
essential **data structures** (maps, objects, linked lists) and **utilities**
(file handling, XML parsing, etc.).

🔌 **Plug & Play:** Easily import and use in any shell script. ⚡

**Pure POSIX:** No Bash-isms, 100% POSIX-compliant. 🔍 **Optimized:** Efficient
and memory-friendly implementations.

---

## 📦 **Installation**

Clone the repository:

```sh
git clone https://github.com/gaurav-gogia/neo-core.sh.git
```

Then, source the required modules in your script: .
path/to/neo-core.sh/core/map.sh . path/to/neo-core.sh/core/ll.sh

Another method of sourcing these scripts would be to use `import` functions
provided in the library.

### Using Maps

```sh
#!/bin/sh

__imports=""

import() {
    file="$1"
    case "$__imports" in
        *"|$file|"*) return ;;
    esac
    __imports="$__imports|$file|"

    if [ -f "$file" ]; then
        printf "Importing %s\n" "$file"
        . "$file"
    else
        printf "Import Error: %s not found\n" "$file" >&2
        exit 1
    fi
}

import "path/to/neo-core.sh/core/map.sh"

map_set "key" "value"
map_get "key"
map_del "key"
```

### Using Linked Lists

```sh
#!/bin/sh

__imports=""

import() {
    file="$1"
    case "$__imports" in
        *"|$file|"*) return ;;
    esac
    __imports="$__imports|$file|"

    if [ -f "$file" ]; then
        printf "Importing %s\n" "$file"
        . "$file"
    else
        printf "Import Error: %s not found\n" "$file" >&2
        exit 1
    fi
}

import "path/to/neo-core.sh/core/map.sh"
import "path/to/neo-core.sh/core/obj.sh"
import "path/to/neo-core.sh/core/ll.sh"

object_set "head" "name" "First Node"
object_set "second" "name" "Second Node"

list_append "head" "second"
list_iterate "head"
```
