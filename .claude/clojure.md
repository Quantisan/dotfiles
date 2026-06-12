# Clojure Conventions

Read this when working in a Clojure codebase. The general principles in `CLAUDE.md` still apply; this adds only what's specific to Clojure.

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

## Idioms

- Threading macros (`->`, `->>`) for transformation pipelines
- Destructuring to make data shapes explicit at function boundaries
- Let bindings for intermediate values that clarify intent
