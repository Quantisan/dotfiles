# Is This Abstraction Earned?

Code review heuristic for recognizing premature or unjustified abstractions. An abstraction earns its place through concrete, repeated use and a name rooted in the problem domain.

## The Common-Pattern Signal (SICP 1.3.1)

SICP presents three procedures — `sum-integers`, `sum-cubes`, and `pi-sum` — that share the same structural skeleton, differing only in the function applied to each term and the function that provides the next value. Then:

> "These three procedures clearly share a common underlying pattern. They are for the most part identical, differing only in the name of the procedure, the function of `a` used to compute the term to be added, and the function that provides the next value of `a`."
>
> "The presence of such a common pattern is strong evidence that there is a useful abstraction waiting to be brought to the surface."
>
> — SICP, Section 1.3.1

The extracted abstraction (`sum`) takes the varying parts — the term function and the next function — as parameters. The key diagnostic: the common pattern must be *structural*, not superficial. Two procedures that happen to share a few lines are not the same as two procedures that share a computational skeleton.

> "Indeed, mathematicians long ago identified the abstraction of summation of a series and invented 'sigma notation' [...] to express this concept. The power of sigma notation is that it allows mathematicians to deal with the concept of summation itself rather than only with particular sums — for example, to formulate general results about sums that are independent of the particular series being summed."
>
> — SICP, Section 1.3.1

> "One of the things we should demand from a powerful programming language is the ability to build abstractions by assigning names to common patterns and then to work in terms of the abstractions directly."
>
> — SICP, Section 1.3.1

**Source:** https://sarabander.github.io/sicp/html/1_002e3.xhtml

## The Two-Occurrence Recognition (Alex Miller)

Miller presents a worked example: a JDBC metadata function for tables, then a near-identical one for catalogs. The structural skeleton is the same — get metadata, call a method on it, convert the result set, map a row function over it. The varying parts are the metadata method and the row function.

```clojure
(defn process-tables [connection]
  (reduce conj '()
    (map #(processTableRow %)
      (resultset-seq
        (.getTables (.getMetaData (connection)) nil nil "%" nil)))))

(defn process-catalogs [connection]
  (reduce conj '()
    (map #(processCatalogRow %)
      (resultset-seq
        (.getCatalogs (.getMetaData (connection)))))))
```

> "As soon as I wrote the second one of these...I could see that there was a pattern here."
>
> — Alex Miller, "Abstracting in Clojure"

The extraction:

```clojure
(defn import-jdbc-metadata [connection databaseMetadataCall rowFunction]
  (reduce concat '()
    (map #(rowFunction %)
      (resultset-seq
        (databaseMetadataCall (.getMetaData (connection)))))))
```

> "the abstraction points are the databaseMetadataCall and rowFunction functions, both passed into the function."

Miller notes the Java contrast: "I would have probably just copied the code in Java and been done with it." The language's support for passing functions as values made the abstraction *visible*.

**Source:** https://puredanger.github.io/tech.puredanger.com/2010/04/29/abstracting-in-clojure/

## Patterns as Trouble (Graham)

Graham's "Programming Bottom-Up" describes a different trigger for the same recognition — not noticing duplication after writing two functions, but *wishing for an operator that doesn't exist*:

> "As you're writing a program you may think 'I wish Lisp had such-and-such an operator.' So you go and write it. Afterward you realize that using the new operator would simplify the design of another part of the program, and so on. Language and program evolve together. Like the border between two warring states, the boundary between language and program is drawn and redrawn, until eventually it comes to rest along the mountains and rivers, the natural frontiers of your problem."
>
> — Paul Graham, "Programming Bottom-Up"

> "Because it causes you always to be on the lookout for patterns in your code, working bottom-up helps to clarify your ideas about the design of your program. If two distant components of a program are similar in form, you'll be led to notice the similarity and perhaps to redesign the program in a simpler way."
>
> — Paul Graham, "Programming Bottom-Up"

The diagnostic bite: patterns are not the abstraction — they are the *signal* that one is missing.

> "When I see patterns in my programs, I consider it a sign of trouble."
>
> — Paul Graham

**Source:** https://paulgraham.com/progbot.html

## Factoring, Not Refactoring (Normand)

Normand draws a sharp distinction between cleaning up code structure (refactoring) and decomposing code to reveal the structure of the *problem* (factoring). The right abstraction comes from domain understanding, not from noticing code smell:

> "What I'm after is code that models the problem. This is the only reliable way to make software that works. Code that inadequately models the problem is littered with nested conditionals for special cases, is unnecessarily bound in time and context, and is generally obtuse. You might be able to understand what the code is doing, but it's unclear whether it should be doing it."
>
> — Eric Normand, "Stop Refactoring, Start Factoring"

> "Factoring is inherently about decomposition. It means splitting functions into smaller functions (along the structural lines of the problem). It means finding those functions which are fundamental to the problem (you can tell they are fundamental because they are used in multiple places). It means revealing symmetries. It means separating concerns. Factoring is about uncovering structural beauty in problem domains."
>
> — Eric Normand, "Stop Refactoring, Start Factoring"

The metaphor that makes the distinction stick:

> "Refactoring is cleaning up the kitchen. Factoring is taking the kitchen apart and building a new kitchen better suited to the styles of the individual chef."
>
> — Eric Normand, "Stop Refactoring, Start Factoring"

And the behavioral implication:

> "Refactoring does not change the behavior of the code, while factoring might. It might because the code might turn out to be incorrect for the problem. [...] From the factoring perspective, you're not fixing a bug. You're correcting the expression of your problem."
>
> — Eric Normand, "Stop Refactoring, Start Factoring"

**Source:** https://ericnormand.me/article/stop-refactoring-and-start-factoring

## Knowing What Not to Think (SICP Lectures)

The master key, from Sussman:

> "But one of the things we have to learn how to do is ignore details. The key to understanding complicated things is to know what not to look at, and what not to compute, and what not to think."
>
> — Sussman, SICP Lecture 1B

> "The key to this — very good programming and very good design — is to know what not to think about."
>
> — Sussman, SICP Lecture 4A

And Abelson on deferring decisions:

> "See, in general, as systems designers, you're forced with the necessity to make decisions about how you're going to do things, and in general, the way you'd like to retain flexibility is to never make up your mind about anything until you're forced to do it."
>
> — Abelson, SICP Lecture 2B

**Source:** https://mk12.github.io/sicp/lecture/highlight.html

## Review Smells

- **Single call site, generic name.** An extraction with one caller and a name like `processData` or `handleResponse` — no structural pattern confirmed, no domain concept named.
- **Name describes implementation, not domain.** `makeHandler`, `wrapWithRetry`, `buildPipeline` — the name tells you *how*, not *what problem it solves*.
- **Abstraction introduced "for testing" or "for reuse" without actual reuse.** Wishful-thinking extraction driven by anticipated need rather than observed pattern.
- **Code smell drove the extraction, not domain understanding.** Normand's test: can you explain what problem structure this abstraction reveals? If you can only explain what code it cleans up, you refactored when you should have factored.
