---
name: atlassian-rovo-confluence
description: Use when working with Confluence content in gfw.atlassian.net through the Atlassian Rovo MCP server, especially to summarize a page from a Confluence URL, compare two pages, find pages by title or topic, browse spaces and pages, or verify Atlassian MCP auth without re-deriving tool selection.
---

# Atlassian Rovo Confluence

Use Atlassian MCP first for `gfw.atlassian.net` Confluence work. Do not browse the web for page contents when MCP can read the page directly.

## Defaults

- Default site: `gfw.atlassian.net`
- Prefer `contentFormat: "markdown"` for page reads
- Use setup and auth checks only when the connection is uncertain

## Quick Checks

1. If auth or setup is unclear, call:
   - `atlassianUserInfo`
   - `getAccessibleAtlassianResources`
2. Confirm `gfw.atlassian.net` appears with Confluence scopes before troubleshooting further.

## Routing

1. If the user gives a Confluence URL containing `/pages/<pageId>/`, extract `<pageId>` and call `getConfluencePage` with `cloudId: "gfw.atlassian.net"`.
2. If the user gives a Confluence tiny link or needs discovery by title or topic, start with `search`.
3. If `search` returns an ARI and you need a quick content read, use `fetch`.
4. If you need the full page body or page metadata by id, use `getConfluencePage`.
5. If the user asks to browse spaces, use `getConfluenceSpaces`.
6. If the user asks to browse pages inside a known space, use `getPagesInConfluenceSpace`.
7. Use `searchConfluenceUsingCql` only when the user explicitly asks for CQL or needs exact CQL filtering.

## Common Tasks

### Summarize One Page

- If a page URL or id is available, use `getConfluencePage`.
- Summarize the purpose, current state, owners, decisions, and obvious gaps.
- If the page is mostly a hub, say so directly.

### Find a Page From a Vague Request

- Use `search` with a natural-language query.
- Prefer Confluence page results over Jira unless the user asks for Jira.
- If there are several plausible matches, summarize the best candidates briefly before going deeper.

### Browse a Space

- Use `getConfluenceSpaces` to identify the space.
- Use `getPagesInConfluenceSpace` for the selected space.
- Use sort and limit parameters to keep the result tight.

## Guardrails

- Prefer MCP over web browsing for Confluence content you can access directly.
- Do not use JQL or CQL tools unless the user asks for them or natural-language search is insufficient.
- Do not do broad searches when the page URL or page id is already available.
- When comparing docs, focus on purpose and content differences, not formatting noise.
- Empty or partial results may be permission or scope issues; re-check auth before assuming the page is missing.

