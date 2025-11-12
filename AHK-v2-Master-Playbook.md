# AutoHotkey v2 Master Playbook
## The Complete Guide to Advanced AHK v2 Patterns, OOP, and Production Techniques

**Version:** 2025.1
**Target:** AutoHotkey v2.0+
**Author:** Elite AHK v2 Pattern Engineer

---

## Table of Contents

1. [Executive Snapshot](#executive-snapshot)
2. [Top 20 Idioms to Learn First](#top-20-idioms-to-learn-first)
3. [Syntax Sugar and Micro Idioms Catalog](#syntax-sugar-and-micro-idioms-catalog)
4. [Core OOP Patterns in AHK v2](#core-oop-patterns-in-ahk-v2)
5. [Evented and Input-Centric Patterns](#evented-and-input-centric-patterns)
6. [GUI v2 Advanced Techniques](#gui-v2-advanced-techniques)
7. [Windows Interop Power Moves](#windows-interop-power-moves)
8. [Text, Data, and Regex Mastery](#text-data-and-regex-mastery)
9. [Error Handling, Reliability, and Testing](#error-handling-reliability-and-testing)
10. [Performance Playbook](#performance-playbook)
11. [Anti-Patterns and v1 Traps](#anti-patterns-and-v1-traps)
12. [Final Integrated Example](#final-integrated-example)
13. [How to Spot AHK v2 Magic in Your Own Code](#how-to-spot-ahk-v2-magic-in-your-own-code)

---

## Executive Snapshot

### What Makes AHK v2 Special

AutoHotkey v2 is a **complete reimagining** of the scripting language, transitioning from imperative scripting to a modern, expression-based OOP language with first-class functions, powerful interop, and elegant closure semantics.

#### Key Differentiators

**1. Pure Expression-Based Syntax**
- Everything returns a value; no more "commands"
- Function calls require parentheses: `MsgBox("text")` not `MsgBox, text`
- Clean separation between expressions and statements

**2. True Object-Oriented Programming**
- Classes with constructors (`__New`), destructors (`__Delete`)
- Static properties and methods
- Magic methods (`__Get`, `__Set`, `__Call`, `__Enum`)
- Property getters/setters for encapsulation
- Prototype-based inheritance

**3. First-Class Functions and Closures**
- Functions are objects; pass them around freely
- Arrow functions `=>` for single-expression lambdas
- Closures capture outer scope automatically
- `ObjBindMethod` for method binding
- Variadic parameters with `*` operator

**4. Modern Collections**
- `Map()` for key-value pairs (replaces associative arrays)
- `Array()` for ordered sequences (1-indexed)
- Built-in iteration with `for..in`
- Custom enumerators via `__Enum`

**5. Powerful Windows Interop**
- `DllCall` with `Buffer` objects (replaces VarSetCapacity)
- `ComObject` and `ComCall` for COM automation
- `SendMessage`/`PostMessage`/`OnMessage` for window messaging
- Rich Win32 API access

**6. Event-Driven Architecture**
- `Hotkey()` function for dynamic hotkey registration
- `HotIf()` for context-sensitive hotkeys
- `InputHook` for advanced input capture
- `OnMessage` for window message hooks
- GUI events with `OnEvent` method

**7. Bulletproof Error Handling**
- `Try..Catch..Finally` structured exception handling
- `Throw` for custom errors
- Error objects with stack traces
- Resource cleanup guarantees

**8. Enhanced Control Flow**
- `Switch..Case` with fallthrough control
- `For..in` enumeration
- `While`/`Loop` with break/continue
- Ternary operator: `x ? a : b`

---

### The "Magic Sauce" of v2

The real power comes from **composing** these features:

- **Static class methods** act as namespaces for utility functions
- **Closures in SetTimer** create private timers with captured state
- **Property getters with lazy init** defer expensive computation
- **__Call magic** enables DSL-like method_missing patterns
- **GUI events bound to closures** wire UI to logic without globals
- **Two-pass GUI rendering** calculates exact sizes before display
- **Buffer + DllCall** provides zero-overhead Win32 access
- **Maps with CaseSense** enable fast case-insensitive lookups

---

## Top 20 Idioms to Learn First

Learn these in order. Each builds on the previous.

### 1. **Function Calls Require Parentheses**
```ahk
MsgBox("Hello")           ; Correct
MsgBox "Hello"            ; ERROR in v2
```

### 2. **Arrow Functions for Single Expressions**
```ahk
double := (x) => x * 2
click_handler := (*) => MsgBox("Clicked!")
```

### 3. **Variadic Parameters with Rest Operator**
```ahk
sum(numbers*) => (total := 0, [total += n for n in numbers], total)[-1]
```

### 4. **Map() for Key-Value Storage**
```ahk
config := Map("width", 800, "height", 600)
config["theme"] := "dark"
```

### 5. **Array Iteration with For..In**
```ahk
for index, value in ["apple", "banana", "cherry"]
    MsgBox(index ": " value)
```

### 6. **Try..Catch..Finally for Safety**
```ahk
try {
    file := FileOpen("data.txt", "r")
    content := file.Read()
} catch as err {
    MsgBox("Error: " err.Message)
} finally {
    if IsSet(file)
        file.Close()
}
```

### 7. **Static Class Methods as Namespaces**
```ahk
class Utils {
    static Clamp(val, min, max) => Max(min, Min(max, val))
}
```

### 8. **Property Getters and Setters**
```ahk
class Person {
    _age := 0
    Age {
        get => this._age
        set => this._age := Max(0, value)
    }
}
```

### 9. **Closures Capturing Outer Scope**
```ahk
makeCounter() {
    count := 0
    return (*) => ++count
}
counter := makeCounter()
MsgBox(counter())  ; 1
MsgBox(counter())  ; 2
```

### 10. **SetTimer with Closure State**
```ahk
debounce(fn, delay) {
    timer := 0
    return (args*) {
        SetTimer(timer, 0)
        timer := () => fn(args*)
        SetTimer(timer, -delay)
    }
}
```

### 11. **HotIf for Context-Sensitive Hotkeys**
```ahk
HotIf(() => WinActive("ahk_exe notepad.exe"))
Hotkey("^s", (*) => MsgBox("Save in Notepad"))
HotIf()
```

### 12. **Buffer for DllCall Structures**
```ahk
buf := Buffer(16)
NumPut("int", 10, buf, 0)
NumPut("int", 20, buf, 4)
```

### 13. **ComObject for Automation**
```ahk
shell := ComObject("WScript.Shell")
shell.Run("notepad.exe")
```

### 14. **Switch with Fallthrough**
```ahk
switch key {
    case "a", "A":
        MsgBox("Letter A")
    case "1":
        MsgBox("Number 1")
    default:
        MsgBox("Other")
}
```

### 15. **Default Parameter Values**
```ahk
greet(name := "World") => MsgBox("Hello, " name)
```

### 16. **Ternary Operator**
```ahk
status := (age >= 18) ? "Adult" : "Minor"
```

### 17. **Regex Named Captures to Map**
```ahk
if RegExMatch("ID:12345", "ID:(?P<id>\d+)", &match)
    MsgBox("ID is " match["id"])
```

### 18. **GUI Events with Closures**
```ahk
g := Gui()
g.AddButton(, "Click Me").OnEvent("Click", (*) => MsgBox("Hello!"))
g.Show()
```

### 19. **Static Variables for State**
```ahk
counter(*) {
    static count := 0
    return ++count
}
```

### 20. **Format() for String Building**
```ahk
msg := Format("User {1} has {2} points", name, score)
```

---

## Syntax Sugar and Micro Idioms Catalog

### 1. Arrow Functions for Single Expressions

**What it solves:** Verbose function definitions for simple transformations
**Why it works in v2:** First-class functions with expression-based syntax
**Core idea:** Use `=>` for single-expression lambdas instead of `{ return }`

```ahk
#Requires AutoHotkey v2.0+

; Traditional function
double_old(x) {
    return x * 2
}

; Arrow function - single expression
double := (x) => x * 2

; Multiple parameters
add := (a, b) => a + b

; No parameters - use (*)
random_msg := (*) => MsgBox("Random: " Random(1, 100))

; Complex expression with ternary
clamp := (x, min, max) => x < min ? min : (x > max ? max : x)

; Usage in array transformations
numbers := [1, 2, 3, 4, 5]
doubled := []
for n in numbers
    doubled.Push((x) => x * 2 (n))

MsgBox("Double of 5: " double(5))
MsgBox("Add 3+7: " add(3, 7))
MsgBox("Clamp 15 to [0,10]: " clamp(15, 0, 10))
```

**Gotchas:**
- Only for single expressions; use `{ }` for multi-line
- Captures variables by reference, not value
- Cannot use `return` keyword in arrow function body

**Performance:** Identical to regular functions; pure syntax sugar

**When to use:** GUI callbacks, array transforms, simple utilities
**When not to use:** Complex logic, need early returns, debugging

---

### 2. Closures with Captured Variables

**What it solves:** Passing state to callbacks without globals
**Why it works in v2:** Functions capture lexical scope by reference
**Core idea:** Inner functions "remember" outer variables

```ahk
#Requires AutoHotkey v2.0+

; Counter factory
makeCounter(start := 0) {
    count := start
    return Map(
        "inc", (*) => ++count,
        "dec", (*) => --count,
        "get", (*) => count,
        "reset", (*) => count := start
    )
}

counter := makeCounter(10)
MsgBox(counter["inc"]())  ; 11
MsgBox(counter["inc"]())  ; 12
MsgBox(counter["get"]())  ; 12
counter["reset"]()
MsgBox(counter["get"]())  ; 10

; Practical: GUI with private state
createToggleButton() {
    state := false
    g := Gui()
    btn := g.AddButton(, "Toggle: OFF")

    ; Closure captures state and btn
    btn.OnEvent("Click", (*) => (
        state := !state,
        btn.Text := "Toggle: " (state ? "ON" : "OFF")
    ))

    return g
}

gui := createToggleButton()
gui.Show()
return

; Advanced: Debounce function
debounce(fn, delay_ms) {
    timer_id := 0
    return (args*) {
        if timer_id
            SetTimer(timer_id, 0)
        timer_id := () => fn(args*)
        SetTimer(timer_id, -delay_ms)
    }
}

; Usage
expensive := debounce((text) => MsgBox("Searching: " text), 500)
expensive("a")
expensive("ab")
expensive("abc")  ; Only this fires after 500ms
Sleep(600)
```

**Gotchas:**
- Variables captured by reference - changes persist
- Circular references can leak memory (rare)
- Debugging captured state harder than globals

**Performance:** Minimal overhead; v2 closures are efficient

**Related patterns:**
- Factory functions
- Private methods via closures
- Event handlers with state

---

### 3. Default and Variadic Parameters

**What it solves:** Flexible function signatures without overloading
**Why it works in v2:** Built-in optional and rest parameters
**Core idea:** `param := default` and `params*` for variadic

```ahk
#Requires AutoHotkey v2.0+

; Default parameters
greet(name := "World", prefix := "Hello") {
    MsgBox(prefix ", " name "!")
}

greet()                    ; Hello, World!
greet("Alice")             ; Hello, Alice!
greet("Bob", "Hi")         ; Hi, Bob!

; Variadic parameters - collect remaining args
sum(numbers*) {
    total := 0
    for n in numbers
        total += n
    return total
}

MsgBox("Sum: " sum(1, 2, 3, 4, 5))  ; 15

; Combine default and variadic
log(level := "INFO", messages*) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    output := timestamp " [" level "] "
    for msg in messages
        output .= msg " "
    MsgBox(output)
}

log("ERROR", "Database", "connection", "failed")
log(, "Starting", "application")  ; Uses default level

; Spread operator - expand array into parameters
multiply(a, b, c) => a * b * c
nums := [2, 3, 4]
result := multiply(nums*)  ; Expands to multiply(2, 3, 4)
MsgBox("Result: " result)  ; 24

; Practical: Flexible configuration
configure(required, options*) {
    config := Map("required", required)

    ; Parse key-value pairs from variadic
    i := 1
    while i <= options.Length {
        if i + 1 <= options.Length {
            config[options[i]] := options[i + 1]
            i += 2
        } else {
            i++
        }
    }

    return config
}

cfg := configure("database", "host", "localhost", "port", 5432)
for key, val in cfg
    MsgBox(key ": " val)
```

**Gotchas:**
- Default params must be rightmost
- Variadic param must be last
- `params*` is an Array, 1-indexed
- Cannot have defaults in variadic param

**Performance:** Variadic has small overhead for array creation

**When to use:** APIs with optional config, logging, math functions
**When not to use:** Performance-critical inner loops

---

### 4. Regex Named Captures to Structured Maps

**What it solves:** Extracting structured data from text without fragile indexing
**Why it works in v2:** Named capture groups map to match object properties
**Core idea:** Use `(?P<name>pattern)` to create semantic captures

```ahk
#Requires AutoHotkey v2.0+

; Parse log entry
logText := "2025-01-15 14:23:45 [ERROR] Database connection failed"
pattern := "(?P<date>\d{4}-\d{2}-\d{2}) (?P<time>\d{2}:\d{2}:\d{2}) \[(?P<level>\w+)\] (?P<message>.+)"

if RegExMatch(logText, pattern, &match) {
    MsgBox("Date: " match["date"] "`n"
         . "Time: " match["time"] "`n"
         . "Level: " match["level"] "`n"
         . "Message: " match["message"])
}

; Parse URL
parseUrl(url) {
    pattern := "(?P<protocol>https?)://(?P<host>[^/:]+)(:(?P<port>\d+))?(?P<path>/[^?]*)?(\?(?P<query>.+))?"

    if RegExMatch(url, pattern, &m) {
        return Map(
            "protocol", m["protocol"],
            "host", m["host"],
            "port", m["port"] ?? (m["protocol"] = "https" ? "443" : "80"),
            "path", m["path"] ?? "/",
            "query", m["query"] ?? ""
        )
    }
    return Map()
}

url := parseUrl("https://example.com:8080/api/users?filter=active")
for key, val in url
    MsgBox(key ": " val)

; Extract structured data with replacement
replaceTemplate(template, data) {
    ; data is a Map
    return RegExReplace(template, "\{(?P<key>\w+)\}",
        (m) => data.Has(m["key"]) ? data[m["key"]] : m[0]
    )
}

template := "Hello {name}, you have {count} messages"
values := Map("name", "Alice", "count", 5)
result := replaceTemplate(template, values)
MsgBox(result)  ; Hello Alice, you have 5 messages

; Practical: CSV parser with named columns
parseCSV(text, headers) {
    rows := []
    lines := StrSplit(text, "`n")

    for line in lines {
        if Trim(line) = ""
            continue

        fields := StrSplit(line, ",")
        row := Map()

        for i, header in headers {
            if i <= fields.Length
                row[header] := Trim(fields[i])
        }

        rows.Push(row)
    }

    return rows
}

csv := "John,25,Engineer`nAlice,30,Designer`nBob,28,Manager"
data := parseCSV(csv, ["name", "age", "role"])

for row in data {
    MsgBox(row["name"] " is " row["age"] " years old, " row["role"])
}
```

**Gotchas:**
- Named groups increase regex complexity
- Unmatched groups return empty string, not `unset`
- Group names must be valid identifiers
- Nested groups capture outer only

**Performance:** Minimal overhead vs numbered captures

**When to use:** Parsing structured text, validation, extraction
**When not to use:** Simple searches, performance-critical loops

---

### 5. Property Getters/Setters with Validation and Lazy Caching

**What it solves:** Encapsulation, computed properties, deferred initialization
**Why it works in v2:** Property syntax with get/set blocks
**Core idea:** Control access to internal state with computed values

```ahk
#Requires AutoHotkey v2.0+

class Rectangle {
    _width := 0
    _height := 0
    _cachedArea := unset

    ; Simple getter/setter with validation
    Width {
        get => this._width
        set {
            if value < 0
                throw ValueError("Width must be non-negative")
            this._width := value
            this._cachedArea := unset  ; Invalidate cache
        }
    }

    Height {
        get => this._height
        set {
            if value < 0
                throw ValueError("Height must be non-negative")
            this._height := value
            this._cachedArea := unset
        }
    }

    ; Computed property with lazy caching
    Area {
        get {
            if !IsSet(this._cachedArea) {
                MsgBox("Computing area...")
                this._cachedArea := this._width * this._height
            }
            return this._cachedArea
        }
    }

    ; Read-only property
    Perimeter => (this._width + this._height) * 2

    ; Chainable setter
    SetSize(w, h) {
        this.Width := w
        this.Height := h
        return this
    }
}

rect := Rectangle()
rect.Width := 10
rect.Height := 5

MsgBox("Area: " rect.Area)       ; Computes
MsgBox("Area: " rect.Area)       ; Uses cache
MsgBox("Perimeter: " rect.Perimeter)

rect.Width := 20                 ; Invalidates cache
MsgBox("Area: " rect.Area)       ; Recomputes

; Advanced: Lazy initialization
class Config {
    _data := unset
    _filePath := ""

    __New(filePath) {
        this._filePath := filePath
    }

    ; Lazy load on first access
    Data {
        get {
            if !IsSet(this._data) {
                MsgBox("Loading config from " this._filePath)
                this._data := this._loadConfig()
            }
            return this._data
        }
    }

    _loadConfig() {
        ; Simulate expensive load
        Sleep(100)
        return Map("theme", "dark", "lang", "en")
    }

    ; Convenient access
    Get(key, default := "") {
        return this.Data.Has(key) ? this.Data[key] : default
    }
}

cfg := Config("settings.ini")
; Config not loaded yet
MsgBox("Starting...")
; Loads on first access
MsgBox("Theme: " cfg.Get("theme"))
MsgBox("Lang: " cfg.Get("lang"))
```

**Gotchas:**
- Can't use `=>` arrow syntax for setters (need `set { }`)
- Computed properties recalculate unless cached
- Validation in setter can throw - needs try/catch
- Property syntax looks like field access (good or bad)

**Performance:**
- Getters/setters: Minimal overhead
- Lazy init: Excellent for expensive operations
- Caching: Trade memory for speed

**When to use:** Public APIs, validation, computed values, lazy init
**When not to use:** Hot paths, simple data holders

---

### 6. ObjBindMethod and Bound Functions

**What it solves:** Passing methods as callbacks while preserving `this`
**Why it works in v2:** `ObjBindMethod` binds object context
**Core idea:** Create callable that remembers its object

```ahk
#Requires AutoHotkey v2.0+

class Counter {
    count := 0

    Increment(*) {
        this.count++
        MsgBox("Count: " this.count)
    }

    GetBoundIncrement() {
        return ObjBindMethod(this, "Increment")
    }
}

c := Counter()
c.Increment()  ; 1

; Create bound method
boundFn := ObjBindMethod(c, "Increment")
boundFn()      ; 2

; Using factory method
boundFn2 := c.GetBoundIncrement()
boundFn2()     ; 3

; Practical: GUI with method callbacks
class App {
    btnClicks := 0

    __New() {
        this.gui := Gui()
        this.btn := this.gui.AddButton(, "Click Me: 0")

        ; Bind method to preserve this context
        this.btn.OnEvent("Click", ObjBindMethod(this, "OnClick"))
    }

    OnClick(*) {
        this.btnClicks++
        this.btn.Text := "Click Me: " this.btnClicks
    }

    Show() {
        this.gui.Show()
    }
}

app := App()
app.Show()

; Alternative: Closure approach
class App2 {
    btnClicks := 0

    __New() {
        this.gui := Gui()
        this.btn := this.gui.AddButton(, "Click Me: 0")

        ; Closure captures this
        self := this
        this.btn.OnEvent("Click", (*) => self.OnClick())
    }

    OnClick() {
        this.btnClicks++
        this.btn.Text := "Click Me: " this.btnClicks
    }

    Show() {
        this.gui.Show()
    }
}

; Binding with arguments
class Logger {
    prefix := ""

    __New(prefix) {
        this.prefix := prefix
    }

    Log(level, msg) {
        MsgBox(this.prefix " [" level "] " msg)
    }
}

logger := Logger("MyApp")

; Bind object and first argument
errorLog := ObjBindMethod(logger, "Log", "ERROR")
infoLog := ObjBindMethod(logger, "Log", "INFO")

errorLog("Something failed")   ; MyApp [ERROR] Something failed
infoLog("App started")          ; MyApp [INFO] App started

return
```

**Gotchas:**
- Bound methods create new function objects (small memory)
- Can't unbind once bound
- Binding parameters fills from left to right
- Alternative: Use closures with captured `this`

**Performance:** Negligible overhead; use freely

**Related patterns:**
- Event handlers
- Callbacks to async operations
- Method references in collections

---

### 7. __Enum for Custom Collection Iteration

**What it solves:** Make custom classes work with `for..in`
**Why it works in v2:** `__Enum` magic method defines iteration
**Core idea:** Return a callable that yields items one by one

```ahk
#Requires AutoHotkey v2.0+

; Range iterator
class Range {
    start := 0
    stop := 0
    step := 1

    __New(start, stop, step := 1) {
        this.start := start
        this.stop := stop
        this.step := step
    }

    __Enum(numberOfVars) {
        current := this.start
        stop := this.stop
        step := this.step

        if numberOfVars = 1 {
            ; for value in range
            return (&val) {
                if (step > 0 && current >= stop) || (step < 0 && current <= stop)
                    return false
                val := current
                current += step
                return true
            }
        } else if numberOfVars = 2 {
            ; for index, value in range
            index := 0
            return (&idx, &val) {
                if (step > 0 && current >= stop) || (step < 0 && current <= stop)
                    return false
                idx := ++index
                val := current
                current += step
                return true
            }
        }
    }
}

; Usage
for n in Range(0, 10, 2)
    MsgBox(n)  ; 0, 2, 4, 6, 8

for i, n in Range(5, 1, -1)
    MsgBox(i ": " n)  ; 1: 5, 2: 4, 3: 3, 4: 2

; Practical: Linked list
class LinkedList {
    head := unset

    class Node {
        value := unset
        next := unset

        __New(value, next := unset) {
            this.value := value
            if IsSet(next)
                this.next := next
        }
    }

    Add(value) {
        if !IsSet(this.head) {
            this.head := LinkedList.Node(value)
        } else {
            node := this.head
            while IsSet(node.next)
                node := node.next
            node.next := LinkedList.Node(value)
        }
        return this
    }

    __Enum(numberOfVars) {
        current := IsSet(this.head) ? this.head : unset

        if numberOfVars = 1 {
            return (&val) {
                if !IsSet(current)
                    return false
                val := current.value
                current := IsSet(current.next) ? current.next : unset
                return true
            }
        }
    }
}

list := LinkedList()
list.Add("first").Add("second").Add("third")

for item in list
    MsgBox(item)

; Advanced: Filtered enumerable
class FilteredArray {
    arr := []
    predicate := ""

    __New(arr, predicate) {
        this.arr := arr
        this.predicate := predicate
    }

    __Enum(numberOfVars) {
        arr := this.arr
        pred := this.predicate
        index := 0

        return (&val) {
            while ++index <= arr.Length {
                if pred(arr[index]) {
                    val := arr[index]
                    return true
                }
            }
            return false
        }
    }
}

numbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
evens := FilteredArray(numbers, (x) => Mod(x, 2) = 0)

for n in evens
    MsgBox(n)  ; 2, 4, 6, 8, 10
```

**Gotchas:**
- `numberOfVars` is 1 for `for x in` or 2 for `for k, v in`
- Return function must return `true` to continue, `false` to stop
- Function parameters are output refs (`&var`)
- Iterator state managed manually in closure

**Performance:** Overhead depends on complexity; usually acceptable

**When to use:** Custom collections, lazy sequences, filters
**When not to use:** Simple arrays (use built-in), one-time iteration

---

### 8. Lazy Initialization via Static Properties

**What it solves:** Defer expensive class setup until first use
**Why it works in v2:** Static properties with getters evaluate once
**Core idea:** Initialize on first access, cache in static field

```ahk
#Requires AutoHotkey v2.0+

class Database {
    static _instance := unset

    ; Singleton with lazy init
    static Instance {
        get {
            if !IsSet(Database._instance) {
                MsgBox("Initializing database connection...")
                Database._instance := Database()
            }
            return Database._instance
        }
    }

    __New() {
        ; Expensive setup
        Sleep(100)
        this.connected := true
    }

    Query(sql) {
        return "Result for: " sql
    }
}

; Not initialized yet
MsgBox("App starting...")

; First access triggers initialization
result := Database.Instance.Query("SELECT * FROM users")
MsgBox(result)

; Subsequent access reuses instance
result2 := Database.Instance.Query("SELECT * FROM orders")
MsgBox(result2)

; Advanced: Lazy static data
class Config {
    static _defaults := unset

    static Defaults {
        get {
            if !IsSet(Config._defaults) {
                MsgBox("Loading default configuration...")
                Config._defaults := Config._loadDefaults()
            }
            return Config._defaults
        }
    }

    static _loadDefaults() {
        ; Simulate expensive operation
        Sleep(50)
        return Map(
            "theme", "dark",
            "language", "en",
            "timeout", 30
        )
    }

    static Get(key, default := "") {
        return Config.Defaults.Has(key) ? Config.Defaults[key] : default
    }
}

; Loads on first access
MsgBox("Theme: " Config.Get("theme"))
MsgBox("Language: " Config.Get("language"))

; Practical: Resource pool
class ResourcePool {
    static _pools := Map()

    static GetPool(name, factory) {
        if !ResourcePool._pools.Has(name) {
            MsgBox("Creating pool: " name)
            ResourcePool._pools[name] := factory()
        }
        return ResourcePool._pools[name]
    }
}

; Usage
stringPool := ResourcePool.GetPool("strings", () => [])
stringPool.Push("hello", "world")

numPool := ResourcePool.GetPool("numbers", () => Map())
numPool["pi"] := 3.14159

; Same pool instances
MsgBox(ResourcePool.GetPool("strings", () => [])[1])  ; "hello"
```

**Gotchas:**
- Static properties shared across all instances
- Initialization not thread-safe (AHK is single-threaded anyway)
- Can't reset without explicit method
- Memory persists until script exit

**Performance:** Excellent for expensive operations

**When to use:** Singletons, config, expensive resources, caches
**When not to use:** Frequently changing data, per-instance state

---

### 9. Short Event Closure Wiring

**What it solves:** Concise GUI event handler attachment
**Why it works in v2:** `OnEvent` accepts closures directly
**Core idea:** Inline arrow functions for simple handlers

```ahk
#Requires AutoHotkey v2.0+

g := Gui()
g.AddText(, "Click buttons to test:")

; Inline closure - no separate function needed
g.AddButton("w200", "Show Message")
 .OnEvent("Click", (*) => MsgBox("Hello from button!"))

; Closure with captured state
clickCount := 0
btn := g.AddButton("w200", "Count: 0")
btn.OnEvent("Click", (*) => (
    clickCount++,
    btn.Text := "Count: " clickCount
))

; Closure accessing GUI control
input := g.AddEdit("w200")
g.AddButton("w200", "Show Input")
 .OnEvent("Click", (*) => MsgBox("You entered: " input.Value))

; Multiple events on same control
hover := g.AddButton("w200", "Hover Me")
hover.OnEvent("Focus", (*) => hover.Text := "Focused!")
hover.OnEvent("LoseFocus", (*) => hover.Text := "Hover Me")

; Chain event handlers
result := g.AddText("w200", "Result: ")
g.AddButton("w200", "Calculate")
 .OnEvent("Click", (*) => result.Text := "Result: " (10 * 5))

g.Show()
return

; Advanced: Event bus pattern
class EventBus {
    listeners := Map()

    On(event, handler) {
        if !this.listeners.Has(event)
            this.listeners[event] := []
        this.listeners[event].Push(handler)
        return this
    }

    Emit(event, data := "") {
        if this.listeners.Has(event) {
            for handler in this.listeners[event]
                handler(data)
        }
        return this
    }

    Off(event, handler := "") {
        if !this.listeners.Has(event)
            return this
        if handler = "" {
            this.listeners.Delete(event)
        } else {
            for i, h in this.listeners[event] {
                if h = handler {
                    this.listeners[event].RemoveAt(i)
                    break
                }
            }
        }
        return this
    }
}

bus := EventBus()

; Register listeners
bus.On("login", (user) => MsgBox("User logged in: " user))
bus.On("login", (user) => MsgBox("Logging to file: " user))

; Trigger events
bus.Emit("login", "Alice")
```

**Gotchas:**
- `*` parameter captures all event args (often ignored)
- Closures capture by reference - beware loop variables
- Can't remove inline closures easily (save reference)
- Memory retained while control exists

**Performance:** Negligible overhead

**When to use:** Simple GUI events, one-off handlers
**When not to use:** Complex logic, reusable handlers, need to unbind

---

### 10. Switch Fallthrough Control

**What it solves:** Multiple cases sharing same logic
**Why it works in v2:** Clean switch syntax with comma-separated cases
**Core idea:** List multiple values in single `case` statement

```ahk
#Requires AutoHotkey v2.0+

; Multiple values in one case
processKey(key) {
    switch key {
        case "a", "A":
            MsgBox("Letter A (any case)")
        case "b", "B":
            MsgBox("Letter B (any case)")
        case "1", "2", "3":
            MsgBox("Digit 1, 2, or 3")
        default:
            MsgBox("Other key: " key)
    }
}

processKey("A")
processKey("2")
processKey("x")

; Switch with expressions
score := 85
grade := switch {
    case score >= 90: "A"
    case score >= 80: "B"
    case score >= 70: "C"
    case score >= 60: "D"
    default: "F"
}
MsgBox("Grade: " grade)

; Pattern matching simulation
describe(value) {
    switch Type(value) {
        case "String":
            return "Text: " value
        case "Integer", "Float":
            return "Number: " value
        case "Array":
            return "Array with " value.Length " items"
        case "Map":
            return "Map with " value.Count " keys"
        default:
            return "Unknown type"
    }
}

MsgBox(describe("hello"))
MsgBox(describe(42))
MsgBox(describe([1, 2, 3]))

; Practical: Command dispatcher
executeCommand(cmd, args*) {
    switch cmd {
        case "save", "s":
            MsgBox("Saving: " args[1])
        case "load", "l", "open":
            MsgBox("Loading: " args[1])
        case "delete", "del", "rm":
            MsgBox("Deleting: " args[1])
        case "help", "h", "?":
            MsgBox("Available: save, load, delete, help")
        default:
            MsgBox("Unknown command: " cmd)
    }
}

executeCommand("s", "file.txt")
executeCommand("open", "data.json")
executeCommand("help")

; Switch in expression context (ternary alternative)
getIcon(status) => switch status {
    case "online": "✓"
    case "offline": "✗"
    case "busy": "⌛"
    default: "?"
}

MsgBox("Status: " getIcon("online"))
```

**Gotchas:**
- No C-style fallthrough between cases (different from v1!)
- Each case is independent - no `break` needed
- Can use expressions in switch value and cases
- `default` is optional

**Performance:** Optimized by compiler; very fast

**When to use:** Multiple conditions, command dispatch, state machines
**When not to use:** Simple if/else (2 cases), complex nested logic

---

## Core OOP Patterns in AHK v2

### Pattern 1: Static Factory Methods and Utility Namespaces

**Use case:** Group related functions without global namespace pollution

**Why this matters:** Static methods provide namespacing, cleaner APIs, and singleton patterns without the awkwardness of global functions.

```ahk
#Requires AutoHotkey v2.0+

class StringUtils {
    ; No instance methods - pure namespace

    static Reverse(str) {
        result := ""
        Loop Parse str
            result := A_LoopField . result
        return result
    }

    static Truncate(str, maxLen, suffix := "...") {
        return (StrLen(str) > maxLen)
            ? SubStr(str, 1, maxLen - StrLen(suffix)) . suffix
            : str
    }

    static ToCamelCase(str) {
        result := ""
        capitalize := false
        Loop Parse str {
            if A_LoopField = "_" || A_LoopField = " " {
                capitalize := true
                continue
            }
            result .= capitalize ? StrUpper(A_LoopField) : A_LoopField
            capitalize := false
        }
        return result
    }
}

; Usage - clean namespace
MsgBox(StringUtils.Reverse("hello"))              ; "olleh"
MsgBox(StringUtils.Truncate("Long text here", 8)) ; "Long..."
MsgBox(StringUtils.ToCamelCase("hello_world"))    ; "helloWorld"

; Practical: Math utilities
class MathEx {
    static Clamp(value, min, max) => Max(min, Min(max, value))

    static Lerp(a, b, t) => a + (b - a) * this.Clamp(t, 0, 1)

    static InRange(value, min, max) => value >= min && value <= max

    static RoundTo(value, precision := 2) {
        multiplier := 10 ** precision
        return Round(value * multiplier) / multiplier
    }
}

MsgBox(MathEx.Clamp(15, 0, 10))        ; 10
MsgBox(MathEx.Lerp(0, 100, 0.5))       ; 50
MsgBox(MathEx.RoundTo(3.14159, 2))     ; 3.14

; Test harness
TestStringUtils() {
    assert(condition, message) {
        if !condition
            MsgBox("FAIL: " message)
    }

    assert(StringUtils.Reverse("abc") = "cba", "Reverse test")
    assert(StringUtils.Truncate("hello world", 5) = "he...", "Truncate test")
    assert(StringUtils.ToCamelCase("hello_world") = "helloWorld", "CamelCase test")

    MsgBox("All tests passed!")
}

TestStringUtils()
```

**When not to use:** If you need instance state, inheritance, or polymorphism

---

### Pattern 2: Property-Based Encapsulation with Validation

**Use case:** Enforce invariants and provide computed properties

**Why this matters:** Properties hide implementation, validate inputs, and compute values transparently.

```ahk
#Requires AutoHotkey v2.0+

class Temperature {
    _celsius := 0

    ; Celsius with validation
    Celsius {
        get => this._celsius
        set {
            if value < -273.15
                throw ValueError("Temperature below absolute zero")
            this._celsius := value
        }
    }

    ; Computed Fahrenheit
    Fahrenheit {
        get => this._celsius * 9/5 + 32
        set => this._celsius := (value - 32) * 5/9
    }

    ; Computed Kelvin
    Kelvin {
        get => this._celsius + 273.15
        set => this._celsius := value - 273.15
    }

    ; Chainable setter
    Set(value, unit := "C") {
        switch unit {
            case "C": this.Celsius := value
            case "F": this.Fahrenheit := value
            case "K": this.Kelvin := value
        }
        return this
    }

    ToString() {
        return Format("{1:.2f}°C = {2:.2f}°F = {3:.2f}K",
            this.Celsius, this.Fahrenheit, this.Kelvin)
    }
}

temp := Temperature()
temp.Celsius := 100
MsgBox(temp.ToString())  ; 100°C = 212°F = 373.15K

temp.Fahrenheit := 32
MsgBox(temp.ToString())  ; 0°C = 32°F = 273.15K

; Chainable
temp.Set(25, "C")
MsgBox(temp.Kelvin)      ; 298.15

; Test harness
TestTemperature() {
    t := Temperature()

    ; Test Celsius
    t.Celsius := 0
    assert(t.Fahrenheit = 32, "0°C = 32°F")

    ; Test Fahrenheit
    t.Fahrenheit := 212
    assert(t.Celsius = 100, "212°F = 100°C")

    ; Test Kelvin
    t.Kelvin := 273.15
    assert(abs(t.Celsius) < 0.01, "273.15K = 0°C")

    ; Test validation
    try {
        t.Celsius := -300
        MsgBox("FAIL: Should throw on invalid temp")
    } catch {
        ; Expected
    }

    MsgBox("Temperature tests passed!")

    assert(condition, msg) {
        if !condition
            throw Error(msg)
    }

    abs(x) => x < 0 ? -x : x
}

TestTemperature()
```

**When not to use:** Simple data holders without logic, performance-critical paths

---

### Pattern 3: __Call for Method Missing and DSL

**Use case:** Dynamic method dispatch, DSL creation, proxy patterns

**Why this matters:** `__Call` intercepts undefined method calls, enabling meta-programming and fluent DSLs.

```ahk
#Requires AutoHotkey v2.0+

; Query builder DSL
class QueryBuilder {
    _table := ""
    _fields := []
    _where := []
    _orderBy := ""

    ; Intercept method calls
    __Call(name, params) {
        ; Handle select_field, where_field, orderby_field
        if RegExMatch(name, "^select_(\w+)$", &m) {
            this._fields.Push(m[1])
            return this
        }
        if RegExMatch(name, "^where_(\w+)$", &m) {
            this._where.Push(m[1] " = '" params[1] "'")
            return this
        }
        if RegExMatch(name, "^orderby_(\w+)$", &m) {
            this._orderBy := m[1]
            return this
        }
        throw Error("Unknown method: " name)
    }

    From(table) {
        this._table := table
        return this
    }

    Build() {
        sql := "SELECT "
        sql .= this._fields.Length ? StrJoin(this._fields, ", ") : "*"
        sql .= " FROM " this._table

        if this._where.Length
            sql .= " WHERE " StrJoin(this._where, " AND ")

        if this._orderBy
            sql .= " ORDER BY " this._orderBy

        return sql
    }

    StrJoin(arr, delim) {
        result := ""
        for i, item in arr
            result .= (i > 1 ? delim : "") . item
        return result
    }
}

; Fluent DSL usage
query := QueryBuilder()
    .From("users")
    .select_name()
    .select_email()
    .where_status("active")
    .where_role("admin")
    .orderby_name()

MsgBox(query.Build())
; SELECT name, email FROM users WHERE status = 'active' AND role = 'admin' ORDER BY name

; Advanced: Builder pattern with __Call
class FormBuilder {
    controls := []

    __Call(name, params) {
        ; addText, addButton, addEdit, etc.
        if RegExMatch(name, "^add(\w+)$", &m) {
            this.controls.Push({type: m[1], params: params})
            return this
        }
        throw Error("Unknown control: " name)
    }

    Build() {
        g := Gui()
        for ctrl in this.controls {
            switch ctrl.type {
                case "Text":
                    g.AddText(ctrl.params*)
                case "Button":
                    g.AddButton(ctrl.params*)
                case "Edit":
                    g.AddEdit(ctrl.params*)
            }
        }
        return g
    }
}

form := FormBuilder()
    .addText("", "Enter your name:")
    .addEdit("w200")
    .addButton("w200", "Submit")
    .Build()

form.Show()

; Test harness
TestQueryBuilder() {
    q := QueryBuilder()
        .From("products")
        .select_id()
        .select_name()
        .where_price("9.99")

    expected := "SELECT id, name FROM products WHERE price = '9.99'"
    actual := q.Build()

    if actual != expected
        MsgBox("FAIL:`nExpected: " expected "`nActual: " actual)
    else
        MsgBox("QueryBuilder test passed!")
}

TestQueryBuilder()
return
```

**When not to use:** Simple APIs, need compile-time checking, debugging difficulty

---

### Pattern 4: Fluent APIs and Method Chaining

**Use case:** Readable configuration and builder patterns

**Why this matters:** Method chaining creates self-documenting, linear code flow.

```ahk
#Requires AutoHotkey v2.0+

class HttpRequest {
    _url := ""
    _method := "GET"
    _headers := Map()
    _body := ""

    Url(url) {
        this._url := url
        return this
    }

    Method(method) {
        this._method := StrUpper(method)
        return this
    }

    Header(key, value) {
        this._headers[key] := value
        return this
    }

    Body(body) {
        this._body := body
        return this
    }

    Send() {
        ; Simulate HTTP request
        msg := this._method " " this._url "`n`n"
        for key, val in this._headers
            msg .= key ": " val "`n"
        if this._body
            msg .= "`n" this._body
        MsgBox(msg)
        return this
    }
}

; Fluent usage
HttpRequest()
    .Url("https://api.example.com/users")
    .Method("POST")
    .Header("Content-Type", "application/json")
    .Header("Authorization", "Bearer token123")
    .Body('{"name": "Alice"}')
    .Send()

; Advanced: GUI builder
class FluentGui {
    gui := unset
    lastControl := unset

    __New(title := "") {
        this.gui := Gui(, title)
    }

    Text(options := "", text := "") {
        this.lastControl := this.gui.AddText(options, text)
        return this
    }

    Edit(options := "", text := "") {
        this.lastControl := this.gui.AddEdit(options, text)
        return this
    }

    Button(options := "", text := "") {
        this.lastControl := this.gui.AddButton(options, text)
        return this
    }

    OnClick(handler) {
        if IsSet(this.lastControl)
            this.lastControl.OnEvent("Click", handler)
        return this
    }

    Show(options := "") {
        this.gui.Show(options)
        return this
    }

    Get() => this.gui
}

; Fluent GUI creation
app := FluentGui("My App")
    .Text("", "Enter your name:")
    .Edit("w200 vNameInput")
    .Button("w200", "Submit")
    .OnClick((*) => MsgBox("Submitted!"))
    .Show()

; Test harness
TestHttpRequest() {
    req := HttpRequest()
        .Url("http://test.com")
        .Method("post")
        .Header("X-Test", "value")

    if req._url != "http://test.com"
        throw Error("URL not set")
    if req._method != "POST"
        throw Error("Method not uppercase")
    if !req._headers.Has("X-Test")
        throw Error("Header not set")

    MsgBox("HttpRequest tests passed!")
}

TestHttpRequest()
return
```

**When not to use:** Complex error handling (breaks chain), need intermediate values

---

### Pattern 5: Event Emitter and Observer Pattern

**Use case:** Decouple components, pub/sub messaging

**Why this matters:** Event emitters enable loose coupling and reactive architectures.

```ahk
#Requires AutoHotkey v2.0+

class EventEmitter {
    _listeners := Map()

    On(event, handler) {
        if !this._listeners.Has(event)
            this._listeners[event] := []
        this._listeners[event].Push(handler)
        return this
    }

    Once(event, handler) {
        wrapper := (data*) {
            handler(data*)
            this.Off(event, wrapper)
        }
        return this.On(event, wrapper)
    }

    Off(event, handler := "") {
        if !this._listeners.Has(event)
            return this

        if handler = "" {
            this._listeners.Delete(event)
        } else {
            listeners := this._listeners[event]
            for i, h in listeners {
                if h = handler {
                    listeners.RemoveAt(i)
                    break
                }
            }
        }
        return this
    }

    Emit(event, data*) {
        if this._listeners.Has(event) {
            for handler in this._listeners[event]
                handler(data*)
        }
        return this
    }
}

; Usage
emitter := EventEmitter()

; Subscribe
emitter.On("data", (value) => MsgBox("Received: " value))
emitter.On("data", (value) => MsgBox("Logger: " value))

; One-time listener
emitter.Once("ready", (*) => MsgBox("Ready fired once!"))

; Emit
emitter.Emit("data", "Hello")
emitter.Emit("ready")
emitter.Emit("ready")  ; Won't fire

; Practical: Application with events
class App extends EventEmitter {
    __New() {
        super.__New()
        this.On("login", (user) => this.OnLogin(user))
        this.On("logout", (*) => this.OnLogout())
    }

    Login(username) {
        MsgBox("Logging in: " username)
        this.Emit("login", username)
    }

    Logout() {
        MsgBox("Logging out")
        this.Emit("logout")
    }

    OnLogin(user) {
        MsgBox("Welcome, " user "!")
    }

    OnLogout() {
        MsgBox("Goodbye!")
    }
}

app := App()

; External listener
app.On("login", (user) => MsgBox("Analytics: " user " logged in"))

app.Login("Alice")
app.Logout()

; Test harness
TestEventEmitter() {
    em := EventEmitter()
    callCount := 0

    handler := (*) => callCount++

    em.On("test", handler)
    em.Emit("test")
    em.Emit("test")

    assert(callCount = 2, "On handler called twice")

    em.Off("test", handler)
    em.Emit("test")

    assert(callCount = 2, "Handler removed")

    callCount := 0
    em.Once("once", (*) => callCount++)
    em.Emit("once")
    em.Emit("once")

    assert(callCount = 1, "Once handler called once")

    MsgBox("EventEmitter tests passed!")

    assert(cond, msg) {
        if !cond
            throw Error(msg)
    }
}

TestEventEmitter()
```

**When not to use:** Simple callbacks suffice, tight coupling acceptable, debugging events hard

---

### Pattern 6: Composition via Delegation and Mixins

**Use case:** Share functionality without inheritance

**Why this matters:** Composition is more flexible than inheritance; mixins add capabilities.

```ahk
#Requires AutoHotkey v2.0+

; Loggable mixin
class Loggable {
    Log(message) {
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        MsgBox(timestamp " [" this.__Class "] " message)
    }
}

; Serializable mixin
class Serializable {
    ToJSON() {
        props := Map()
        for k, v in this.OwnProps()
            props[k] := v

        json := "{"
        first := true
        for k, v in props {
            if !first
                json .= ", "
            json .= '"' k '": "' v '"'
            first := false
        }
        json .= "}"
        return json
    }
}

; Compose via delegation
class User {
    name := ""
    email := ""

    ; Delegate logging
    _logger := Loggable()
    ; Delegate serialization
    _serializer := Serializable()

    __New(name, email) {
        this.name := name
        this.email := email
    }

    ; Forward method calls
    Log(message) => this._logger.Log(message)
    ToJSON() => this._serializer.ToJSON.Call(this)
}

user := User("Alice", "alice@example.com")
user.Log("User created")
MsgBox(user.ToJSON())

; Advanced: Trait composition helper
class Composable {
    static Mix(target, traits*) {
        for trait in traits {
            proto := trait.Prototype
            for k, v in proto.OwnProps() {
                if k != "__Init" && k != "__Class"
                    target.Prototype.DefineProp(k, {value: v})
            }
        }
    }
}

; Define traits
class Timestamped {
    GetTimestamp() => FormatTime(, "yyyy-MM-dd HH:mm:ss")
}

class Identifiable {
    static _nextId := 1

    __New() {
        this.id := Identifiable._nextId++
    }
}

; Compose class
class Document {
}

; Mix in traits
Composable.Mix(Document, Timestamped, Identifiable)

doc := Document()
MsgBox("ID: " doc.id)
MsgBox("Time: " doc.GetTimestamp())

; Test harness
TestComposition() {
    u := User("Bob", "bob@test.com")

    assert(u.name = "Bob", "Name set")
    assert(InStr(u.ToJSON(), "Bob"), "JSON contains name")

    d1 := Document()
    d2 := Document()

    assert(d2.id = d1.id + 1, "IDs increment")
    assert(d1.HasMethod("GetTimestamp"), "Trait mixed in")

    MsgBox("Composition tests passed!")

    assert(cond, msg) {
        if !cond
            throw Error(msg)
    }
}

TestComposition()
```

**When not to use:** Simple inheritance works, need polymorphism, trait conflicts

---

(Continuing in next message due to length...)


## Evented and Input-Centric Patterns

### Pattern 1: Dynamic Hotkey Registration with HotIf

**Use case:** Context-sensitive hotkeys that change based on active window or state

**Why this matters:** `HotIf` enables sophisticated hotkey scoping without conflicts

```ahk
#Requires AutoHotkey v2.0+

; Basic context-sensitive hotkeys
HotIf(() => WinActive("ahk_exe notepad.exe"))
Hotkey("^s", (*) => MsgBox("Save in Notepad"))
Hotkey("^n", (*) => MsgBox("New in Notepad"))
HotIf()

HotIf(() => WinActive("ahk_exe chrome.exe"))
Hotkey("^s", (*) => MsgBox("Save in Chrome"))
HotIf()

; State-based hotkey toggling
class AppModes {
    static mode := "normal"
    static SetMode(newMode) {
        this.mode := newMode
        MsgBox("Mode: " newMode)
    }
}

; Define mode-specific hotkeys
HotIf(() => AppModes.mode = "edit")
Hotkey("i", (*) => MsgBox("Insert mode"))
Hotkey("a", (*) => MsgBox("Append mode"))
HotIf()

HotIf(() => AppModes.mode = "normal")
Hotkey("i", (*) => AppModes.SetMode("edit"))
Hotkey("Esc", (*) => AppModes.SetMode("normal"))
HotIf()

; Advanced: Dynamic hotkey manager
class HotkeyManager {
    contexts := Map()
    
    AddContext(name, predicate) {
        this.contexts[name] := {pred: predicate, keys: Map()}
        return this
    }
    
    AddHotkey(context, key, handler) {
        if !this.contexts.Has(context)
            throw Error("Context not found: " context)
        
        this.contexts[context].keys[key] := handler
        
        ; Register with HotIf
        HotIf(this.contexts[context].pred)
        Hotkey(key, handler)
        HotIf()
        
        return this
    }
    
    RemoveContext(name) {
        if !this.contexts.Has(name)
            return this
            
        ctx := this.contexts[name]
        HotIf(ctx.pred)
        for key in ctx.keys
            Hotkey(key, "Off")
        HotIf()
        
        this.contexts.Delete(name)
        return this
    }
}

mgr := HotkeyManager()
mgr.AddContext("vscode", () => WinActive("ahk_exe Code.exe"))
   .AddHotkey("vscode", "^!t", (*) => MsgBox("Toggle terminal"))
   .AddHotkey("vscode", "^!e", (*) => MsgBox("Toggle explorer"))

return
```

**When not to use:** Global hotkeys, simple unconditional bindings

---

### Pattern 2: InputHook for Advanced Input Sequences

**Use case:** Detect multi-key sequences, chords, tap-dance behaviors

**Why this matters:** `InputHook` provides low-level input capture with timing control

```ahk
#Requires AutoHotkey v2.0+

; Double-tap detection
detectDoubleTap(key, timeout := 300, action := "") {
    static lastTap := 0
    static lastKey := ""
    
    now := A_TickCount
    
    if key = lastKey && (now - lastTap) < timeout {
        ; Double tap detected
        if action
            action()
        lastTap := 0
        lastKey := ""
        return true
    }
    
    lastTap := now
    lastKey := key
    return false
}

; Leader key pattern (vim-style)
class LeaderKey {
    static timeout := 1000
    static bindings := Map()
    static active := false
    
    static Register(sequence, handler) {
        this.bindings[sequence] := handler
    }
    
    static Start() {
        this.active := true
        ih := InputHook("L1 T" this.timeout / 1000)
        ih.KeyOpt("{All}", "E")  ; End on any key
        
        ih.OnChar := (ih, char) {
            this.HandleChar(char)
        }
        
        ih.OnEnd := (ih) {
            this.active := false
        }
        
        ih.Start()
        ToolTip("Leader...")
        SetTimer(() => ToolTip(), -this.timeout)
    }
    
    static HandleChar(char) {
        if this.bindings.Has(char) {
            ToolTip()
            this.bindings[char]()
        } else {
            ToolTip("Unknown: " char)
            SetTimer(() => ToolTip(), -500)
        }
    }
}

; Register leader bindings
LeaderKey.Register("s", (*) => MsgBox("Save"))
LeaderKey.Register("q", (*) => MsgBox("Quit"))
LeaderKey.Register("w", (*) => MsgBox("Window"))

; Trigger with Space as leader
Space::LeaderKey.Start()

; Chord detection
detectChord(keys, callback, timeout := 200) {
    pressed := Map()
    
    for key in keys {
        Hotkey(key, (*) {
            pressed[key] := true
            
            ; Check if all keys pressed
            allPressed := true
            for k in keys {
                if !pressed.Has(k) {
                    allPressed := false
                    break
                }
            }
            
            if allPressed {
                callback()
                pressed.Clear()
            }
            
            ; Reset after timeout
            SetTimer(() => pressed.Delete(key), -timeout)
        })
    }
}

; Example: Ctrl+Alt+Shift chord
; detectChord(["LCtrl", "LAlt", "LShift"], () => MsgBox("Chord!"))

return
```

**When not to use:** Simple hotkeys, no timing requirements

---

### Pattern 3: Debounce and Throttle with SetTimer

**Use case:** Rate-limit expensive operations, smooth UI updates

**Why this matters:** Prevents performance issues from rapid events

```ahk
#Requires AutoHotkey v2.0+

; Debounce - delay execution until quiet period
debounce(fn, delay) {
    timer := 0
    
    return (args*) {
        if timer
            SetTimer(timer, 0)
        
        timer := () => fn(args*)
        SetTimer(timer, -delay)
    }
}

; Throttle - limit execution rate
throttle(fn, delay) {
    lastCall := 0
    timer := 0
    
    return (args*) {
        now := A_TickCount
        
        if (now - lastCall) >= delay {
            fn(args*)
            lastCall := now
        } else {
            ; Schedule for later
            if timer
                SetTimer(timer, 0)
            
            timer := () {
                fn(args*)
                lastCall := A_TickCount
            }
            
            SetTimer(timer, -(delay - (now - lastCall)))
        }
    }
}

; Usage examples
expensiveSearch := (query) => MsgBox("Searching: " query)
debouncedSearch := debounce(expensiveSearch, 500)

; Simulate rapid input
debouncedSearch("a")
debouncedSearch("ab")
debouncedSearch("abc")  ; Only this executes

; Throttle example
updatePosition := (x, y) => ToolTip("Position: " x ", " y)
throttledUpdate := throttle(updatePosition, 100)

; Mouse tracking with throttle
SetTimer(() {
    MouseGetPos(&x, &y)
    throttledUpdate(x, y)
}, 10)

Sleep(3000)
SetTimer(, 0)
ToolTip()

return
```

**When not to use:** Need immediate response, already infrequent

---

## GUI v2 Advanced Techniques

### Pattern 1: Class-Based GUI Controllers with Event Routing

**Use case:** Organize GUI logic in reusable, testable classes

**Why this matters:** Clean separation of concerns, easier maintenance

```ahk
#Requires AutoHotkey v2.0+

class TodoApp {
    gui := unset
    listBox := unset
    input := unset
    todos := []
    
    __New() {
        this.gui := Gui(, "Todo App")
        this.gui.SetFont("s10")
        
        this.gui.AddText(, "Enter task:")
        this.input := this.gui.AddEdit("w300")
        
        addBtn := this.gui.AddButton("w100", "Add")
        addBtn.OnEvent("Click", ObjBindMethod(this, "OnAdd"))
        
        this.listBox := this.gui.AddListBox("w300 h200")
        
        delBtn := this.gui.AddButton("w100", "Delete")
        delBtn.OnEvent("Click", ObjBindMethod(this, "OnDelete"))
        
        clearBtn := this.gui.AddButton("w100 x+10", "Clear All")
        clearBtn.OnEvent("Click", ObjBindMethod(this, "OnClear"))
    }
    
    OnAdd(*) {
        text := this.input.Value
        if Trim(text) = ""
            return
        
        this.todos.Push(text)
        this.UpdateList()
        this.input.Value := ""
        this.input.Focus()
    }
    
    OnDelete(*) {
        selected := this.listBox.Value
        if selected = 0
            return
        
        this.todos.RemoveAt(selected)
        this.UpdateList()
    }
    
    OnClear(*) {
        this.todos := []
        this.UpdateList()
    }
    
    UpdateList() {
        this.listBox.Delete()
        for todo in this.todos
            this.listBox.Add([todo])
    }
    
    Show() {
        this.gui.Show()
    }
}

app := TodoApp()
app.Show()

return
```

---

### Pattern 2: Two-Pass GUI Rendering for Exact Sizing

**Use case:** Calculate final sizes before display (from InputTip)

**Why this matters:** Pixel-perfect layouts without guessing

```ahk
#Requires AutoHotkey v2.0+

; From InputTip pattern
createGui(callback) {
    ; First pass - measure
    g := callback({x: 0, y: 0, w: 0, h: 0, i: 1})
    g.Show("Hide")
    g.GetPos(&x, &y, &w, &h)
    g.Destroy()
    
    ; Second pass - render with measurements
    return callback({x: x, y: y, w: w, h: h, i: 0})
}

; Usage
myGui(info) {
    g := Gui()
    g.SetFont("s10")
    
    g.AddText(, "This text determines width")
    
    if info.i  ; First pass
        return g
    
    ; Second pass - know exact width
    w := info.w
    btnWidth := w - g.MarginX * 2
    
    g.AddEdit("w" btnWidth)
    g.AddButton("w" btnWidth, "Submit")
    
    return g
}

gui := createGui(myGui)
gui.Show()

return
```

---

### Pattern 3: Data Binding Between Maps and ListView

**Use case:** Sync data model with UI control

**Why this matters:** MVC pattern, reactive updates

```ahk
#Requires AutoHotkey v2.0+

class DataGridView {
    gui := unset
    lv := unset
    data := []
    columns := []
    
    __New(title, columns) {
        this.columns := columns
        this.gui := Gui(, title)
        
        ; Build columns
        colStr := ""
        for col in columns
            colStr .= col "|"
        
        this.lv := this.gui.AddListView("w600 h300", colStr)
        
        ; Auto-size columns
        for i, col in columns
            this.lv.ModifyCol(i, "AutoHdr")
    }
    
    SetData(data) {
        this.data := data
        this.Refresh()
        return this
    }
    
    Refresh() {
        this.lv.Delete()
        
        for row in this.data {
            values := []
            for col in this.columns {
                val := row.Has(col) ? row[col] : ""
                values.Push(val)
            }
            this.lv.Add(, values*)
        }
        
        return this
    }
    
    GetSelected() {
        row := this.lv.GetNext()
        return row ? this.data[row] : unset
    }
    
    Show() {
        this.gui.Show()
        return this
    }
}

; Usage
data := [
    Map("name", "Alice", "age", 30, "role", "Engineer"),
    Map("name", "Bob", "age", 25, "role", "Designer"),
    Map("name", "Charlie", "age", 35, "role", "Manager")
]

grid := DataGridView("Employees", ["name", "age", "role"])
grid.SetData(data).Show()

return
```

---

## Windows Interop Power Moves

### Pattern 1: Safe DllCall Wrappers with Buffer Management

**Use case:** Windows API access with automatic cleanup

**Why this matters:** Buffer lifetime management, type safety

```ahk
#Requires AutoHotkey v2.0+

class WinAPI {
    ; Get cursor position with proper buffer
    static GetCursorPos() {
        pt := Buffer(8)
        if DllCall("GetCursorPos", "Ptr", pt) {
            return {
                x: NumGet(pt, 0, "Int"),
                y: NumGet(pt, 4, "Int")
            }
        }
        return {x: 0, y: 0}
    }
    
    ; Set cursor position
    static SetCursorPos(x, y) {
        return DllCall("SetCursorPos", "Int", x, "Int", y)
    }
    
    ; Get window rect
    static GetWindowRect(hwnd) {
        rect := Buffer(16)
        if DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rect) {
            return {
                left: NumGet(rect, 0, "Int"),
                top: NumGet(rect, 4, "Int"),
                right: NumGet(rect, 8, "Int"),
                bottom: NumGet(rect, 12, "Int")
            }
        }
        return {left: 0, top: 0, right: 0, bottom: 0}
    }
    
    ; Flash window
    static FlashWindow(hwnd, count := 3) {
        info := Buffer(20)
        NumPut("UInt", 20, info, 0)           ; cbSize
        NumPut("Ptr", hwnd, info, 4)          ; hwnd
        NumPut("UInt", 0xF, info, 4+A_PtrSize) ; dwFlags (FLASHW_ALL)
        NumPut("UInt", count, info, 8+A_PtrSize)
        NumPut("UInt", 0, info, 12+A_PtrSize)
        
        return DllCall("FlashWindowEx", "Ptr", info)
    }
}

; Usage
pos := WinAPI.GetCursorPos()
MsgBox("Cursor at: " pos.x ", " pos.y)

WinAPI.SetCursorPos(100, 100)
Sleep(500)
WinAPI.SetCursorPos(pos.x, pos.y)

; Flash active window
WinAPI.FlashWindow(WinExist("A"), 5)

return
```

---

### Pattern 2: SendMessage and OnMessage for Window Communication

**Use case:** Low-level window messaging

```ahk
#Requires AutoHotkey v2.0+

class MessageHandler {
    static handlers := Map()
    
    static Register(msg, handler) {
        this.handlers[msg] := handler
        OnMessage(msg, handler)
    }
    
    static Unregister(msg) {
        if this.handlers.Has(msg) {
            OnMessage(msg, this.handlers[msg], 0)
            this.handlers.Delete(msg)
        }
    }
}

; Custom message
WM_CUSTOM := 0x8000

MessageHandler.Register(WM_CUSTOM, (wParam, lParam, msg, hwnd) {
    MsgBox("Custom message received: " wParam)
    return 0
})

; Send to self
PostMessage(WM_CUSTOM, 42, 0, , "A")

; Monitor clipboard changes
WM_CLIPBOARDUPDATE := 0x031D

class ClipboardMonitor {
    static onChange := ""
    static hwnd := 0
    
    static Start(callback) {
        this.onChange := callback
        
        ; Create hidden window
        g := Gui()
        g.Show("Hide")
        this.hwnd := g.Hwnd
        
        ; Register for clipboard updates
        DllCall("AddClipboardFormatListener", "Ptr", this.hwnd)
        
        OnMessage(WM_CLIPBOARDUPDATE, (w, l, m, h) => this.onChange())
    }
}

ClipboardMonitor.Start(() {
    ToolTip("Clipboard changed: " A_Clipboard)
    SetTimer(() => ToolTip(), -2000)
})

return
```

---

## Text, Data, and Regex Mastery

### Pattern 1: Fast Line Processing with FileOpen Streams

```ahk
#Requires AutoHotkey v2.0+

class FileProcessor {
    static ProcessLines(filePath, callback) {
        try {
            file := FileOpen(filePath, "r")
            lineNum := 0
            
            while !file.AtEOF {
                line := file.ReadLine()
                lineNum++
                
                ; Call callback with line number and content
                if !callback(lineNum, RTrim(line, "`r`n"))
                    break
            }
        } finally {
            if IsSet(file)
                file.Close()
        }
    }
    
    static Filter(filePath, outPath, predicate) {
        try {
            inFile := FileOpen(filePath, "r")
            outFile := FileOpen(outPath, "w")
            
            while !inFile.AtEOF {
                line := inFile.ReadLine()
                if predicate(RTrim(line, "`r`n"))
                    outFile.WriteLine(line)
            }
        } finally {
            if IsSet(inFile)
                inFile.Close()
            if IsSet(outFile)
                outFile.Close()
        }
    }
}

; Usage - count lines
count := 0
FileProcessor.ProcessLines("data.txt", (num, line) {
    global count
    count++
    return true
})
MsgBox("Lines: " count)

; Filter lines containing keyword
FileProcessor.Filter("input.txt", "output.txt",
    (line) => InStr(line, "ERROR"))

return
```

---

### Pattern 2: CSV and TSV Parsing Utilities

```ahk
#Requires AutoHotkey v2.0+

class CSVParser {
    static Parse(text, delimiter := ",") {
        rows := []
        lines := StrSplit(text, "`n")
        
        for line in lines {
            line := Trim(line, " `r`n")
            if line = ""
                continue
            
            fields := this._SplitCSVLine(line, delimiter)
            rows.Push(fields)
        }
        
        return rows
    }
    
    static ParseWithHeaders(text, delimiter := ",") {
        lines := StrSplit(text, "`n")
        if lines.Length = 0
            return []
        
        headers := this._SplitCSVLine(Trim(lines[1]), delimiter)
        rows := []
        
        Loop lines.Length - 1 {
            line := Trim(lines[A_Index + 1])
            if line = ""
                continue
            
            fields := this._SplitCSVLine(line, delimiter)
            row := Map()
            
            for i, header in headers {
                if i <= fields.Length
                    row[header] := fields[i]
            }
            
            rows.Push(row)
        }
        
        return rows
    }
    
    static _SplitCSVLine(line, delim) {
        fields := []
        field := ""
        inQuote := false
        
        Loop Parse line {
            char := A_LoopField
            
            if char = '"' {
                inQuote := !inQuote
            } else if char = delim && !inQuote {
                fields.Push(Trim(field))
                field := ""
            } else {
                field .= char
            }
        }
        
        fields.Push(Trim(field))
        return fields
    }
}

; Usage
csv := "name,age,role`nAlice,30,Engineer`nBob,25,Designer"
data := CSVParser.ParseWithHeaders(csv)

for row in data
    MsgBox(row["name"] " - " row["role"])

return
```

---

## Error Handling, Reliability, and Testing

### Pattern 1: Domain-Specific Error Classes

```ahk
#Requires AutoHotkey v2.0+

class ValidationError extends Error {
    field := ""
    
    __New(message, field := "") {
        super.__New(message)
        this.field := field
    }
}

class NetworkError extends Error {
    statusCode := 0
    
    __New(message, statusCode := 0) {
        super.__New(message)
        this.statusCode := statusCode
    }
}

; Usage
validateAge(age) {
    if age < 0 || age > 150
        throw ValidationError("Invalid age", "age")
    return true
}

try {
    validateAge(-5)
} catch ValidationError as err {
    MsgBox("Validation failed on field: " err.field "`n" err.Message)
} catch Error as err {
    MsgBox("Unexpected error: " err.Message)
}

return
```

---

### Pattern 2: Tiny Test Harness

```ahk
#Requires AutoHotkey v2.0+

class TestRunner {
    static tests := []
    static passed := 0
    static failed := 0
    
    static Test(name, fn) {
        this.tests.Push({name: name, fn: fn})
    }
    
    static Run() {
        this.passed := 0
        this.failed := 0
        results := []
        
        for test in this.tests {
            try {
                test.fn()
                this.passed++
                results.Push("✓ " test.name)
            } catch Error as err {
                this.failed++
                results.Push("✗ " test.name ": " err.Message)
            }
        }
        
        ; Show results
        summary := Format("Passed: {1} | Failed: {2}", this.passed, this.failed)
        msg := summary "`n`n" StrJoin(results, "`n")
        MsgBox(msg, "Test Results")
        
        StrJoin(arr, delim) {
            result := ""
            for i, item in arr
                result .= (i > 1 ? delim : "") . item
            return result
        }
    }
    
    static Assert(condition, message := "Assertion failed") {
        if !condition
            throw Error(message)
    }
    
    static AssertEqual(actual, expected, message := "") {
        if actual != expected {
            msg := message ? message : Format("Expected {1}, got {2}", expected, actual)
            throw Error(msg)
        }
    }
}

; Define tests
TestRunner.Test("String reverse", () {
    reverse(s) {
        r := ""
        Loop Parse s
            r := A_LoopField . r
        return r
    }
    
    TestRunner.AssertEqual(reverse("abc"), "cba")
    TestRunner.AssertEqual(reverse("hello"), "olleh")
})

TestRunner.Test("Math clamp", () {
    clamp(v, min, max) => Max(min, Min(max, v))
    
    TestRunner.AssertEqual(clamp(5, 0, 10), 5)
    TestRunner.AssertEqual(clamp(-5, 0, 10), 0)
    TestRunner.AssertEqual(clamp(15, 0, 10), 10)
})

; Run all tests
TestRunner.Run()

return
```

---

## Performance Playbook

### Arrays vs Maps

**Use Array when:**
- Ordered sequence
- Integer index access
- Iteration order matters
- Small collections (< 1000)

**Use Map when:**
- Key-value lookup
- String/object keys
- Frequent add/remove
- Large collections

### Microbench Harness

```ahk
#Requires AutoHotkey v2.0+

class Benchmark {
    static Compare(name1, fn1, name2, fn2, iterations := 10000) {
        ; Warmup
        Loop 100 {
            fn1()
            fn2()
        }
        
        ; Benchmark fn1
        start := A_TickCount
        Loop iterations
            fn1()
        time1 := A_TickCount - start
        
        ; Benchmark fn2
        start := A_TickCount
        Loop iterations
            fn2()
        time2 := A_TickCount - start
        
        ; Results
        faster := time1 < time2 ? name1 : name2
        ratio := Max(time1, time2) / Min(time1, time2)
        
        msg := Format("{1}: {2}ms`n{3}: {4}ms`n`n{5} is {6:.2f}x faster",
            name1, time1, name2, time2, faster, ratio)
        
        MsgBox(msg)
    }
}

; Example
Benchmark.Compare(
    "For loop",
    () {
        sum := 0
        arr := [1,2,3,4,5]
        Loop arr.Length
            sum += arr[A_Index]
    },
    "For..in loop",
    () {
        sum := 0
        for v in [1,2,3,4,5]
            sum += v
    },
    100000
)

return
```

---

## Anti-Patterns and v1 Traps

### Common v1 → v2 Migration Issues

**1. Command syntax**
```ahk
; v1
MsgBox, Hello

; v2 - CORRECT
MsgBox("Hello")
```

**2. Assignment vs comparison**
```ahk
; v1 - both work
if var = 5

; v2 - CORRECT
if var = 5   ; Assignment!
if var == 5  ; Comparison
```

**3. Arrays start at 1**
```ahk
; v2
arr := [10, 20, 30]
MsgBox(arr[1])  ; 10, not 0
```

**4. Forced expressions**
```ahk
; v1
Var := % Expr

; v2 - CORRECT (always expression)
Var := Expr
```

---

## Final Integrated Example

### Production-Ready Mini App

A complete application demonstrating best practices:

```ahk
#Requires AutoHotkey v2.0+

; ===== Configuration Management =====
class Config {
    static file := "app.ini"
    static data := Map()
    
    static Load() {
        this.data := Map()
        if FileExist(this.file) {
            try {
                content := FileRead(this.file)
                for line in StrSplit(content, "`n") {
                    if RegExMatch(Trim(line), "^(\w+)=(.*)$", &m)
                        this.data[m[1]] := m[2]
                }
            }
        }
    }
    
    static Get(key, default := "") {
        return this.data.Has(key) ? this.data[key] : default
    }
    
    static Set(key, value) {
        this.data[key] := value
    }
    
    static Save() {
        content := ""
        for key, val in this.data
            content .= key "=" val "`n"
        FileOpen(this.file, "w").Write(content)
    }
}

; ===== Main Application =====
class NotePad extends EventEmitter {
    gui := unset
    editor := unset
    currentFile := ""
    modified := false
    
    __New() {
        super.__New()
        
        ; Load config
        Config.Load()
        
        ; Create GUI
        this.gui := Gui(, "NotePad")
        this.gui.SetFont("s10", Config.Get("font", "Consolas"))
        
        ; Menu
        menu := Menu()
        menu.Add("&New", ObjBindMethod(this, "New"))
        menu.Add("&Open", ObjBindMethod(this, "Open"))
        menu.Add("&Save", ObjBindMethod(this, "Save"))
        menu.Add()
        menu.Add("E&xit", (*) => ExitApp())
        
        menuBar := MenuBar()
        menuBar.Add("&File", menu)
        this.gui.MenuBar := menuBar
        
        ; Editor
        this.editor := this.gui.AddEdit("w600 h400 vEditor")
        this.editor.OnEvent("Change", (*) => this.OnTextChange())
        
        ; Status bar
        this.status := this.gui.AddText("w600", "Ready")
        
        ; Setup hotkeys
        this.SetupHotkeys()
        
        ; Window close handler
        this.gui.OnEvent("Close", ObjBindMethod(this, "OnClose"))
    }
    
    SetupHotkeys() {
        HotIf(() => WinActive("ahk_id " this.gui.Hwnd))
        Hotkey("^s", ObjBindMethod(this, "Save"))
        Hotkey("^n", ObjBindMethod(this, "New"))
        Hotkey("^o", ObjBindMethod(this, "Open"))
        HotIf()
    }
    
    New(*) {
        if !this.CheckSave()
            return
        
        this.editor.Value := ""
        this.currentFile := ""
        this.modified := false
        this.UpdateTitle()
    }
    
    Open(*) {
        if !this.CheckSave()
            return
        
        file := FileSelect(3, , "Open File", "Text Files (*.txt)")
        if !file
            return
        
        try {
            this.editor.Value := FileRead(file)
            this.currentFile := file
            this.modified := false
            this.UpdateTitle()
            this.Emit("file-opened", file)
        } catch Error as err {
            MsgBox("Error opening file: " err.Message)
        }
    }
    
    Save(*) {
        if this.currentFile = "" {
            file := FileSelect("S", , "Save File", "Text Files (*.txt)")
            if !file
                return
            
            if !InStr(file, ".")
                file .= ".txt"
            
            this.currentFile := file
        }
        
        try {
            FileOpen(this.currentFile, "w").Write(this.editor.Value)
            this.modified := false
            this.UpdateTitle()
            this.Emit("file-saved", this.currentFile)
            this.status.Value := "Saved: " this.currentFile
        } catch Error as err {
            MsgBox("Error saving file: " err.Message)
        }
    }
    
    OnTextChange() {
        this.modified := true
        this.UpdateTitle()
    }
    
    UpdateTitle() {
        title := this.currentFile ? this.currentFile : "Untitled"
        if this.modified
            title := "* " title
        this.gui.Title := title " - NotePad"
    }
    
    CheckSave() {
        if !this.modified
            return true
        
        result := MsgBox("Save changes?", "NotePad", "YesNoCancel")
        if result = "Cancel"
            return false
        if result = "Yes"
            this.Save()
        
        return true
    }
    
    OnClose(*) {
        if this.CheckSave() {
            Config.Save()
            ExitApp()
        }
    }
    
    Show() {
        this.gui.Show()
        this.UpdateTitle()
    }
}

; ===== Event Emitter Base Class =====
class EventEmitter {
    _listeners := Map()
    
    On(event, handler) {
        if !this._listeners.Has(event)
            this._listeners[event] := []
        this._listeners[event].Push(handler)
        return this
    }
    
    Emit(event, data*) {
        if this._listeners.Has(event) {
            for handler in this._listeners[event]
                handler(data*)
        }
        return this
    }
}

; ===== Launch Application =====
app := NotePad()

; External listeners
app.On("file-opened", (file) => ToolTip("Opened: " file))
app.On("file-saved", (file) => ToolTip("Saved: " file))

app.Show()

return
```

**To run:**
1. Save as `notepad.ahk`
2. Run with AutoHotkey v2.0+
3. Use Ctrl+N, Ctrl+O, Ctrl+S

**To extend:**
- Add search/replace
- Add syntax highlighting
- Add recent files list
- Add auto-save timer

---

## How to Spot AHK v2 Magic in Your Own Code

✓ **Using arrow functions** for simple callbacks
✓ **Properties with getters** instead of public fields
✓ **Static class methods** instead of global functions
✓ **Closures in SetTimer** instead of global state
✓ **Maps** for key-value data instead of pseudo-arrays
✓ **Try..Finally** for cleanup instead of defer
✓ **__Enum** for custom iteration instead of manual loops
✓ **HotIf predicates** instead of global hotkey conflicts
✓ **Composition** instead of deep inheritance
✓ **Event emitters** instead of callback spaghetti
✓ **Two-pass GUI** instead of hardcoded sizes
✓ **Buffer + DllCall** instead of VarSetCapacity
✓ **Regex named groups** instead of numbered captures
✓ **Method chaining** for fluent APIs
✓ **Debounce/throttle** instead of raw SetTimer

---

## Conclusion

This playbook represents the **distilled wisdom** of production AHK v2 development, extracted from real-world projects like InputTip. Master these patterns, and you'll write cleaner, faster, more maintainable scripts.

**Key takeaways:**
1. **Think in expressions**, not commands
2. **Use closures** to eliminate global state
3. **Leverage properties** for encapsulation
4. **Compose with delegation**, not inheritance
5. **Embrace SetTimer** for async-like patterns
6. **Buffer management** is key for DllCall safety
7. **Two-pass rendering** solves GUI layout
8. **Event emitters** decouple components

**Next steps:**
- Study the InputTip source for real-world patterns
- Build a mini-app using 5+ patterns from this playbook
- Contribute your own patterns to the community

Happy scripting! 🚀
