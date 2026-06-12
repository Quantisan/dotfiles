# Clojure Conventions

Read this when working in a Clojure codebase. The general principles in `CLAUDE.md` still apply; this adds language specifics.

## Domain Naming in Practice

Applying "naming reflects the domain" to Clojure—namespaces, keywords, and functions:

```clojure
;; Namespaces organized by domain
(ns topics.actions)
(ns messages.core)
(ns ui.components)

;; State actions namespaced by system part
:llm.actions/response-received
:chat.actions/message-sent

;; Functions mirror domain operations
(defn save [topic] ...)
(defn submit [form] ...)
```

## Code Style

- Threading macros (`->`, `->>`) for transformation pipelines
- Destructuring to make data shapes explicit at function boundaries
- Small, focused functions that do one thing well
- Descriptive names that make code self-documenting
- Let bindings for intermediate values that clarify intent

## Working with the Codebase

1. Study existing patterns before implementing
2. Check dependencies before assuming libraries exist
3. Follow established namespace conventions
4. Run tests throughout development
5. Manual testing before considering complete
