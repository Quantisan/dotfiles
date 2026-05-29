# Does This Abstraction Cut Along the Right Seam?

Code review heuristic for recognizing abstractions that group the wrong things together — even when the abstraction itself is justified. The diagnostic is complecting: two things that could be independent are interleaved, or one coherent thing is split across two places.

## Complecting (Hickey)

> "So there is this really cool word called 'complect'. I found it. I love it. It means 'to interleave or entwine or braid'. [...] So what do you know about complect? It is bad. Do not do it. This is where complexity comes from: complecting."
>
> — Rich Hickey, "Simple Made Easy" (Strange Loop 2011)

> "Look at this diagram. Look at the first one. Look at the last one. It is the same stuff in both those diagrams. It is the same strips! What happened? They got complected. And now it is hard to understand the bottom diagram from the top one, but it is the same stuff. You are doing this all the time."
>
> — Rich Hickey, "Simple Made Easy"

The operational definition of simple — it is about interleaving, not cardinality:

> "If we want to look for simple things, we want to look for things that have sort of one of something. They have one role. They fulfill one task or job. [...] The critical thing there, though, is that when you are looking for something that is simple, you want to see it have focus in these areas. You do not want to see it combining things.
>
> On the other hand, we cannot get too fixated about 'one'. In particular, simple does not mean that there is only one of them. It also does not mean an interface that only has one operation. So it is important to distinguish cardinality, counting things, from actual interleaving. What matters for simplicity is that there is no interleaving, not that there is only one thing."
>
> — Rich Hickey, "Simple Made Easy"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md

## The Complexity Toolkit (Hickey)

The concrete diagnostic table — what complects what:

| Construct | Complects |
|---|---|
| State | Everything that touches it |
| Objects | State, identity, value |
| Methods | Function and state, namespaces |
| Syntax | Meaning, order |
| Inheritance | Types |
| Switch/matching | Multiple who/what pairs |
| var(iable)s | Value, time |
| Imperative loops, fold | What/how |
| Actors | What/who |
| Conditionals | Why, rest of program |

> "All right, let us see why things are complex. State, we already talked about. It complects everything it touches. Objects complect state, identity, and value. They mix these three things up in a way that you cannot extricate the parts.
>
> Methods complect function and state, ordinarily. In addition, in some languages, they complect namespaces. [...]
>
> Switching and matching, they complect multiple pairs of who is going to do something and what happens, and they do it all in one place in a closed way. That is very bad."
>
> — Rich Hickey, "Simple Made Easy"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md

## Modularity Does Not Imply Simplicity (Hickey)

> "Who has seen components that have this kind of characteristic? [...] You can write modular software with all kinds of interconnections between them. They may not call each other, but they are completely complected."
>
> — Rich Hickey, "Simple Made Easy"

> "Partitioning and stratification don't imply simplicity, but are enabled by it."
>
> — Rich Hickey, "Simple Made Easy" (slide)

> "So I would encourage you to be particularly careful not to be fooled by code organization. There are tons of libraries that look, oh, look, there is different classes; there are separate classes. They call each other in sort of these nice ways. Then you get out in the field and you are like, oh, my God! This thing presumes that that thing never returns the number 17. What is that?"
>
> — Rich Hickey, "Simple Made Easy"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md

## Design Is Taking Things Apart (Hickey)

> "So I think that a simple idea behind design is to look at it in terms of taking things apart. This is the opposite notion we typically have. [...] I think, instead, what you want to do is break things apart in such a way that they can be put back together.
>
> And that's fundamentally what design is about: taking things apart so you can put them back together because obviously taking things apart and walking away is not really going to help.
>
> The other thing you find in good designs is that they're always about one or very few things. Designs that survive, designs that really foster reuse are about a single thing, generally."
>
> — Rich Hickey, "Design, Composition and Performance" (QCon 2013)

> "Usually the answer to your problem in the field is: I have just insufficiently broken something down, and so the solution I'm going to need is just breaking it down more. And that's less expensive than: I created this giant ball of everything and I need to untangle it."
>
> — Rich Hickey, "Design, Composition and Performance"

The decomposition questions — Who, What, When, Where, Why, How:

> "What kinds of things would we take apart? [...] You can take apart the requirements for a system. You can take apart the order in which things happen, who is going to talk to whom, information parts of your system for mechanism parts, and you can actually take apart different solutions to assess their merit."
>
> — Rich Hickey, "Design, Composition and Performance"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/DesignCompositionPerformance.md

## Information vs. Mechanism (Hickey)

> "This one is kind of interesting because I don't see it talked about often enough, which is to separate information versus mechanism. [...] One is sort of this device into which you stick stuff and you can go back later, and it's kind of a little bit of a place. And the other is a piece of information, which you should really not treat that way at all. So pulling these things apart, talking about your system and clearly differentiating the stuff that's information from the stuff that's sort of the mechanics of your program is quite critical."
>
> — Rich Hickey, "Design, Composition and Performance"

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/DesignCompositionPerformance.md

## Open vs. Closed Indirection (Tellman)

Tellman distinguishes two indirection tools, and the boundary between them is a key seam diagnostic:

> "Two indirection tools:
> References: Conveys values. Open.
> Conditionals: Decides based upon values. Closed: to change them, we need to change code."
>
> "For a decision mechanism to be open it must be unordered: table with unique keys."
>
> — Zachary Tellman, "Elements of Clojure" (via Dan Lebrero's summary)

A `cond`/`case` that requires code changes to extend signals a closed mechanism where an open one is needed. The seam is in the wrong place — the variation has been complected with the dispatch.

On boundaries and assumptions:

> "To write software we must learn to draw boundaries."
>
> "Build SW from principled components (build to be discarded), separated by interfaces where necessary (build to last)."
>
> "Broad assumptions means smaller models which means simpler code."
>
> "Over-engineered code == too few assumptions."
>
> — Zachary Tellman, "Elements of Clojure" (via Dan Lebrero's summary)

On what belongs together:

> "Abstractions that fail together should stay together."
>
> "Group models with similar assumptions, wrap them in a single layer that enforces those assumptions."
>
> — Zachary Tellman, "Elements of Clojure" (via Dan Lebrero's summary)

**Source (summary):** https://danlebrero.com/2020/08/12/elements-of-clojure-book-summary/
**Source (book):** Zachary Tellman, *Elements of Clojure* (Leanpub)

## Composition Structure (Tellman)

> "Process always:
> Pull data from environment.
> Transform data.
> Push data to environment.
> Keep them separated until the last possible moment."
>
> "Keep transform code in a different namespace than push/pull code."
>
> — Zachary Tellman, "Elements of Clojure" (via Dan Lebrero's summary)

> "Functions can do three things:
> Pull data into scope: Name should describe the data type it returns.
> Transform data in scope: Avoid verbs.
> Push data to another scope: Name should be the effect it has.
> At least one function in every process must do all three. This functions are difficult to reuse."
>
> — Zachary Tellman, "Elements of Clojure" (via Dan Lebrero's summary)

**Source (summary):** https://danlebrero.com/2020/08/12/elements-of-clojure-book-summary/

## Wrong Seam Iteration (Sierra)

Stuart Sierra's "Lifecycle Composition" is a worked example of discovering, through use, that an abstraction drew a boundary that complected the wrong concerns — then iterating:

**Version 1** (side-effecting, returns future): complects "when did it start" with the act of starting.

**Version 2** (synchronous, no return value): "made it very clear that I was using start/stop only for side-effects, forcing all of my components to contain mutable state."

**Version 3** (returns updated component): "In this version, start and stop feel more like functions. They are still not pure functions, because they will have to execute side-effects such as connecting to a database or opening a web server port, but at least they return something meaningful."

Sierra explicitly reflects on the cost of getting the seam wrong:

> "As always, mutable objects muddy the distinction between values and identities."
>
> "So I don't have a perfect system. It works well enough for the applications I've developed with it so far [...] but I always have to adapt to circumstance."
>
> — Stuart Sierra, "Lifecycle Composition"

**Source:** https://stuartsierra.com/2013/09/15/lifecycle-composition/

## Developing Entanglement Radar (Hickey)

> "You have to start developing sensibilities around entanglement. You have to have entanglement radar. You want to look at some software and say, ugh! Not that I do not like the names you used, or the shape of the code, or there was a semicolon. That is also important, too. But you want to start seeing complecting. You want to start seeing interconnections between things that could be independent. That is where you are going to get the most power."
>
> — Rich Hickey, "Simple Made Easy"

> "Simplicity often means making more things, not fewer."
>
> — Rich Hickey, "Simple Made Easy" (slide)

**Source:** https://github.com/matthiasn/talk-transcripts/blob/master/Hickey_Rich/SimpleMadeEasy-mostly-text.md

## Review Smells

- **Module A knows something about module B's internals.** Hickey: "This thing presumes that that thing never returns the number 17." Partitioning happened, but simplicity did not.
- **A `cond`/`case` that must be edited to handle new cases.** Tellman: closed indirection where open indirection (a dispatch map, protocol) is needed.
- **A function that both transforms data and causes effects.** Tellman: pull, transform, and push are three roles — a function doing all three has complected them and is difficult to reuse.
- **State change that ripples.** Hickey: "State complects everything that touches it." If changing one piece of state forces you to reason about distant parts of the system, the seam was drawn around the wrong thing.
- **Separate files or modules that cannot be understood independently.** The partitioning created an illusion of separation without actual simplicity.
