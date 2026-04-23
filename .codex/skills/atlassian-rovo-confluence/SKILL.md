---
name: atlassian-rovo-confluence
description: Use when working with Confluence content in gfw.atlassian.net through Atlassian Rovo, especially to crawl a page tree, summarize a page or doc set, rank which linked pages are worth reviewing, or answer questions by interrogating connected Confluence pages.
---

# Atlassian Rovo Confluence

Use Atlassian MCP first for `gfw.atlassian.net` Confluence work. Do not browse the web for page contents when MCP can read the page directly.

## Defaults

- Default site: `gfw.atlassian.net`
- If the user provides a `gfw.atlassian.net` Confluence URL or page id, try a direct read first with `cloudId: "gfw.atlassian.net"`.
- Prefer `contentFormat: "markdown"` for page reads.
- Only run `atlassianUserInfo` or `getAccessibleAtlassianResources` after the first MCP failure, or when the user explicitly asks to verify access.

## Routing

1. If the user gives a Confluence URL containing `/pages/<pageId>/`, extract `<pageId>` and call `getConfluencePage` with `cloudId: "gfw.atlassian.net"`.
2. If the user asks about a page and its linked docs, or the starting page looks like a hub, read the page first, then call `getConfluencePageDescendants` before using search.
3. If the user gives a Confluence tiny link or needs discovery outside the current page tree, use `search`.
4. If `search` returns an ARI and you need a quick skim, use `fetch`.
5. If you need the full page body or page metadata by id, use `getConfluencePage`.
6. If the user asks to browse spaces, use `getConfluenceSpaces`.
7. If the user asks to browse pages inside a known space, use `getPagesInConfluenceSpace`.
8. Use `searchConfluenceUsingCql` only when the user explicitly asks for CQL or needs exact CQL filtering.

## Crawl a Hub or Doc Set

Use this when the user asks which linked pages matter, wants a doc-set summary, or wants you to interrogate a page and its related docs.

1. Read the starting page with `getConfluencePage`.
2. If it is a hub, index, dashboard, or the user asks about linked docs, call `getConfluencePageDescendants` with `depth: 1` before searching.
3. Use descendants to identify readable child pages and read a small batch in parallel.
4. Summarize each page by role: source of truth, supporting context, operational detail, archive, or low-signal.
5. Widen scope with `search` only if the current tree does not answer the question.
6. Stop once you can answer the user’s question confidently.

## Artifact Routing

- `page`: use `getConfluencePage`
- Search result ARI needing a quick skim: use `fetch`
- `database` or `embed` returned by descendants: treat as non-page artifacts
- Do not repeatedly try `getConfluencePage` or `fetch` on descendants already identified as `database` or `embed`
- If an artifact is not readable through MCP, note the limitation and move on unless the user explicitly wants that artifact investigated

## Common Tasks

### Summarize One Page

- If a page URL or id is available, use `getConfluencePage`.
- Summarize the purpose, current state, owners, decisions, and obvious gaps.
- If the page is mostly a hub, say so directly.

### Review Linked Pages

- Start from the hub page, then inspect descendants before searching.
- Read only enough linked pages to separate source-of-truth pages from supporting or low-signal pages.
- Return a ranked shortlist such as `read first`, `read next`, and `skip`.

### Find a Page From a Vague Request

- Use `search` with a natural-language query.
- Prefer Confluence page results over Jira unless the user asks for Jira.
- If there are several plausible matches, summarize the best candidates briefly before going deeper.

### Browse a Space

- Use `getConfluenceSpaces` to identify the space.
- Use `getPagesInConfluenceSpace` for the selected space.
- Use sort and limit parameters to keep the result tight.

## Search Rules

- Do not search when an exact page URL or id is already available, unless you need context outside that page tree.
- Use `search` to widen scope, not to rediscover pages you already have from descendants.
- Use natural-language queries. Do not use web-style operators like `site:`.
- Prefer one focused discovery search over several near-duplicate searches.
- If search returns duplicates across spaces, prefer pages closest to the starting page’s space or tree unless the user asks for cross-space comparison.
- Use `fetch` to skim search hits before promoting them to full `getConfluencePage` reads.

## Sampling and Stop Rules

- For large archives such as meeting notes, interview summaries, or feedback logs, sample 2-3 representative pages first.
- Expand only if the sample is inconsistent or the user asks for exhaustive review.
- When the user asks for a ranked shortlist, do not enumerate every child page.
- Favor a confident synthesis over exhaustive crawling.

## Guardrails

- Prefer MCP over web browsing for Confluence content you can access directly.
- Do not use JQL or CQL tools unless the user asks for them or natural-language search is insufficient.
- Do not do broad searches when the page URL or page id is already available.
- When comparing docs, focus on purpose and content differences, not formatting noise.
- Empty or partial results may be permission or scope issues; re-check auth before assuming the page is missing.
