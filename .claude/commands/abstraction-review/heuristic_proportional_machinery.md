# Is the Machinery Proportional?

Code review heuristic for recognizing abstractions that use heavier mechanisms than the problem requires. Given that an abstraction is earned and cuts along the right seam, is it built with the simplest tool that works?

## The Simplicity Toolkit (Hickey)

Hickey presents paired columns — complexity-generating constructs and their simpler replacements:

| Complexity | Simplicity |
|---|---|
| State, Objects | Values |
| Methods | Functions, Namespaces |
| vars | Managed refs |
| Inheritance, switch, matching | Polymorphism a la carte |
| Syntax | Data |
| Imperative loops, fold | Set functions |
| Actors | Queues |
| ORM | Declarative data manipulation |
| Conditionals | Rules |
| Inconsistency | Consistency |

> "So if you take away two things from this talk, one would be the difference between the words 'simple' and 'easy'. The other, I would hope, would be the fact that we can create precisely the same programs we are creating right now with these tools of complexity, with *dramatically* drastically simpler tools. I did C++ for a long time. I did Java. I did C#. I know how to make big systems in those languages, and I completely believe you do not need all that complexity. You can write as sophisticated a system with dramatically simpler tools, which means you are going to be focusing on the system, what it is supposed to do, instead of all the gook that falls out of the constructs you are using."
>
> — Rich Hickey, "Simple Made Easy"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md

## Data Over Entities (Hickey)

> "There's a presumption built-in to that question that I think needs to be addressed first. That is, that there should be specialized, named, data structures/classes corresponding to imagined information-based entities in a system, and a partitioning of functions by their association with same entities [...]. I've come to the conclusion after 20 years of C++/Java/C#/CLOS/OODBMS that this is a bad idea."
>
> — Rich Hickey, "Rich Already Answered That" (Q&A gist)

> "Data is data, and having very few general data structures to hold it and very many general functions to manipulate it is the key. That is the Clojure philosophy."
>
> — Rich Hickey, "Rich Already Answered That"

> "Data: Please! We are programmers. We supposedly write data processing programs. There are all these programs that do not have any data in them. They have all these constructs we put around it and globbed on top of data.
>
> Data is actually really simple. There are not a tremendous number of variations in the essential nature of data. There are maps. There are sets. There are linear, sequential things. There are not a lot of other conceptual categories of data. We create hundreds of thousands of variations that have nothing to do with the essence of this stuff, and make it hard to write programs that manipulate the essence of the stuff. We should just manipulate the essence of the stuff. It is not hard. It is simpler."
>
> — Rich Hickey, "Simple Made Easy"

**Sources:**
- https://gist.github.com/reborg/dc8b0c96c397a56668905e2767fd697f
- https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md

## Polymorphism a la Carte (Hickey)

On what protocols provide — and why they sit above functions but below macros:

> "The biggest thing, I think, the most desirable thing, the most esoteric, this is tough to get, but boy when you have it your life is completely, totally different thing, is polymorphism a la carte. Clojure protocols and Haskell type classes, and constructs like that, give you the ability to independently say, 'I have data structures. I have definitions of sets of functions, and I can connect them together.' And those are three independent operations. In other words, the genericity is not tied to anything in particular. It is available a la carte."
>
> — Rich Hickey, "Simple Made Easy"

The explicit preference hierarchy, from the Q&A gist:

> "Prefer using protocols to specify your abstractions, vs interfaces."
>
> "Prefer `reify` to `proxy` unless some interop API forces you to use `proxy`. You shouldn't be creating things in Clojure that would require you to use `proxy`."
>
> "Prefer `deftype` to `gen-class` unless some interop API forces you to use gen-class."
>
> — Rich Hickey, "Rich Already Answered That"

On why protocols exist despite multimethods being more powerful:

> "`multimethod`, OTOH, don't suffer from this problem. But it is difficult to get something as generic as Clojure's multimethods to compete with interface dispatch in Java. Also, multimethods are kind of atomic, often you need a set of them to completely specify an abstraction."
>
> "`defprotocol` takes a subset of multimethod power, open extension, combine it with a fixed, but extremely common, dispatch mechanism (single dispatch on 'type' of first arg), allow a set of functions constituting an abstraction to be named, specified, and implemented as group, and provide a clear way to extend the protocol."
>
> — Rich Hickey, "Rich Already Answered That"

**Source:** https://gist.github.com/reborg/dc8b0c96c397a56668905e2767fd697f

## Closed Pattern Matching vs. Open Dispatch (Hickey)

> "If you are talking about the aspect of pattern matching that acts as a conditional based upon structure, I'm not a big fan. I feel about them the way I do about switch statements — they're brittle and inextensible. I find the extensive use of them in some functional languages an indication of the lack of polymorphism in those languages."
>
> — Rich Hickey, "Rich Already Answered That"

> "They are closed, enumerated in a single construct.
> They are frequently replicated.
> The binding aspect is used to rename structure components because the language throws the names away, presuming the types are enough."
>
> "Polymorphic functions and maps are, IMO, preferable because:
> They are open, no single co-located enumeration of possibilities.
> There is no master switch, each 'type' (really situation, with Clojure's multimethods) owner takes care of themselves.
> Maps allow for structures with named components where the names don't get lost."
>
> — Rich Hickey, "Rich Already Answered That"

And the empirical lesson from porting Okasaki's data structures from ML to Java:

> "Adding types can have a multiplicative, rather than an additive, effect on pattern matches."
>
> — Rich Hickey, "Rich Already Answered That"

**Source:** https://gist.github.com/reborg/dc8b0c96c397a56668905e2767fd697f

## Abstraction Interfaces Should Be Small (Hickey)

> "The point I would like to get across today is just that they should be really small, much smaller than what we typically see. [...] The thing with those giant interfaces is that it is a lot harder to break up those programs."
>
> — Rich Hickey, "Simple Made Easy"

> "They are specifications. They are not actually the implementations. They should only use values and other abstractions in their definitions."
>
> — Rich Hickey, "Simple Made Easy"

> "And the biggest problem you have when you are doing this part of design is if you complect this with 'how'. You can complect it with 'how' by jamming them together and saying, 'here is just a concrete function' instead of having an interface [...]. Strictly separating 'what' from 'how' is the key to making 'how' somebody else's problem."
>
> — Rich Hickey, "Simple Made Easy"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md

## "Everything Configurable" Is Not Design (Hickey)

> "You want to be able to say no because the value that you convey in your design is strictly about the decisions you've made. [...] But you know what? I really appreciate the fact that this thing just works, and it sounds great, and I can do the next thing. I don't have to fiddle around with the inside of it.
>
> So if you leave all the options open, you're not designing. That is not design. Everything configurable, that's like do your own thing."
>
> — Rich Hickey, "Design, Composition and Performance"

> "A lot of times what can happen is you can adopt a solution that is larger than your problem, and then what do you have? You have two problems, right? You have your problem and now you have this thing that was too big, too big for it."
>
> — Rich Hickey, "Design, Composition and Performance"

> "Constraint drives creativity. When you don't have a lot of choices, you're forced to pick an answer and move on."
>
> — Rich Hickey, "Design, Composition and Performance"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/DesignCompositionPerformance.md

## The Macro Last Resort

> "Don't use macros unless you have to."
>
> — Creative Clojure, "When do you need macros in Clojure?"

Three legitimate macro use cases:
1. You don't want to eagerly evaluate all arguments (e.g. in a control structure)
2. You want some of the code to run at compile time, not at runtime
3. You want a custom syntax which can't be evaluated with the normal function evaluation rule

> "Normal code shouldn't need macros. You should normally start off with a function, and only reach for a macro when all else fails."
>
> — Creative Clojure

On the cost:

> "More complex to write, harder to maintain and can't be used flexibly in ways that functions can (e.g. passing to higher order functions)."
>
> — Creative Clojure

On composability of reader macros:

> "User-defined reader macros don't compose, they clash. [...] CL has this feature and it is very rarely used for that exact reason — programs that require custom reader macros are a pain."
>
> — Rich Hickey, "Rich Already Answered That"

And on not unifying things that aren't uniform:

> "Just because protocols can be used to make things reach many types doesn't mean they should be used to unify things that aren't uniform."
>
> — Rich Hickey, "Rich Already Answered That"

**Sources:**
- https://clojurefun.wordpress.com/2013/01/09/when-do-you-need-macros-in-clojure/
- https://gist.github.com/reborg/dc8b0c96c397a56668905e2767fd697f

## Decision Hierarchy

Prefer earlier options — each step down requires stronger justification:

1. **Plain function** — composes, is first-class, testable, holds no surprises
2. **Higher-order function** — when the varying part is behavior (SICP 1.3's "common template" pattern)
3. **Data-driven dispatch** — when variation is configuration, not behavior (maps, tables, registries)
4. **Protocol** — when open, type-based extension matters and you need a named set of operations
5. **Multimethod** — when dispatch needs arbitrary logic beyond single type dispatch
6. **Macro** — only when you need deferred evaluation or syntax control

## Review Smells

- **Protocol with one implementation.** If there is no second implementation and no concrete plan for one, a plain function or HOF would do.
- **Multimethod where a map lookup suffices.** If dispatch is on a known, finite set of keywords, a data table is simpler and faster.
- **Macro where a function would work.** If all arguments can be eagerly evaluated and no syntax transformation is needed, a function composes better.
- **"Everything configurable."** Hickey: that's not design. If the abstraction exposes every knob rather than making decisions, it has traded the problem for a meta-problem.
- **Solution larger than the problem.** Hickey: "you can adopt a solution that is larger than your problem, and then what do you have? You have two problems."
- **Giant interface.** Hickey: "they should be really small, much smaller than what we typically see." If a protocol has more than a few functions, it likely complects multiple abstractions.
