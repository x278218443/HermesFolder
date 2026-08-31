---
name: web-content-extraction
description: Extract structured content (markdown, tables, lists, code blocks) from websites, especially SPAs and protected pages where direct API access fails.
---

# Web Content Extraction

Extract structured content from websites when direct access (curl, API calls) fails or returns incomplete data. Common targets: SKILL.md files, documentation pages, API specs, README files rendered by SPAs.

## When to Use

- Target URL returns HTML shell (SPA) instead of content
- Direct curl/API returns Cloudflare challenges, 403s, or empty pages
- Content is rendered by JavaScript and not in raw HTML
- User needs structured content (markdown, tables, code) from a web page

## Workflow

### Phase 1: Try Direct Access First

```bash
# Always attempt direct access before browser approach
curl -sL "https://target.com/path/to/file.md" | head -50
curl -sL "https://target.com/api/endpoint" | python3 -m json.tool
```

**Success indicators**: Content starts with markdown, JSON, or actual data (not `<!doctype html>` or `<html`)

**Failure indicators**: HTML shell, Cloudflare challenge, 403, empty response, "Just a moment..." page

### Phase 2: Browser Extraction (SPA/Protected Pages)

When direct access fails, use browser tools:

```python
# 1. Navigate to the page
browser_navigate(url=target_url)

# 2. Get full page snapshot with accessibility tree
browser_snapshot(full=True)

# 3. If content is in code blocks or specific elements, extract via JS
browser_console(expression="""
  // Extract from rendered markdown
  const main = document.querySelector('main, .content, article');
  if (main) {
    let result = '';
    const walker = document.createTreeWalker(main, NodeFilter.SHOW_TEXT, null, false);
    while (walker.nextNode()) {
      const text = walker.currentNode.textContent.trim();
      if (text) result += text + '\\n';
    }
    result;
  }
""")
```

### Phase 3: React/Vue SPA Deep Extraction

For complex SPAs where simple text extraction isn't enough:

```python
# Check for React internals
browser_console(expression="""
  const root = document.getElementById('root');
  const reactKey = Object.keys(root || {}).find(k => k.startsWith('__react'));
  JSON.stringify({reactKey, rootKeys: Object.keys(root || {}).slice(0, 10)});
""")

# Try to find content in React fiber tree (advanced)
browser_console(expression="""
  function findReactFiber(el) {
    const key = Object.keys(el).find(k => k.startsWith('__reactFiber$') || k.startsWith('__reactInternalInstance$'));
    return key ? el[key] : null;
  }
  // Walk fiber tree looking for content
""")
```

### Phase 4: Reconstruct Markdown

After extracting text, reconstruct proper markdown:

1. **Headers**: Map heading levels (h1 → `#`, h2 → `##`, etc.)
2. **Tables**: Convert extracted table data to markdown table syntax
3. **Lists**: Reconstruct ordered/unordered lists with proper markers
4. **Code blocks**: Wrap in triple backticks with language if known
5. **Bold/Italic**: Preserve from original DOM structure
6. **Blockquotes**: Prefix lines with `>`
7. **Horizontal rules**: Insert `---` between sections

## Pitfalls

1. **Variable name conflicts**: Browser console re-declares variables across calls. Use unique names or wrap in IIFE:
   ```javascript
   (function() {
     const result = {};
     // ... extraction logic
     return result;
   })()
   ```

2. **Network interception limitations**: `window.fetch` interception doesn't catch all request types (XHR, blob URLs, programmatic anchor clicks). Don't rely solely on intercepted URLs.

3. **Download buttons in SPAs**: Often use programmatic anchor creation (`document.createElement('a')`) or Blob URLs, not standard `href`. May not trigger fetch interceptor.

4. **Variable redeclaration errors**: `Identifier 'X' has already been declared` means the variable exists in page scope. Use different names or IIFE pattern.

5. **Cloudflare challenges**: Cannot be bypassed with curl. Requires full browser with JavaScript execution.

6. **Partial content extraction**: Always verify completeness by comparing:
   - Number of headers found vs expected
   - Table row counts
   - Whether code blocks are complete (check for closing ```)

## Example: Extracting SKILL.md from ClawHub

```python
# 1. Navigate
browser_navigate(url="https://cn.clawhub-mirror.com/skills/claw-stock")

# 2. Get full snapshot
browser_snapshot(full=True)

# 3. Extract text content from main section
browser_console(expression="""
  const main = document.querySelector('main');
  if (main) {
    let result = '';
    const walker = document.createTreeWalker(main, NodeFilter.SHOW_TEXT, null, false);
    while (walker.nextNode()) {
      const text = walker.currentNode.textContent.trim();
      if (text) result += text + '\\n';
    }
    result;
  }
""")

# 4. Reconstruct markdown manually or with LLM assistance
# 5. Save to file
write_file(path="/tmp/output.md", content=reconstructed_markdown)
```

## Verification

After extraction, verify:
- [ ] All major sections present (check headers)
- [ ] Tables have correct column counts
- [ ] Code blocks are complete (opening and closing ```)
- [ ] Lists have proper numbering/bullet points
- [ ] No truncated content (compare line count to original if possible)
- [ ] File size is reasonable for expected content

## References

- See `references/react-spa-extraction.md` for advanced React fiber tree extraction patterns
- See `references/anti-bot-workarounds.md` for handling Cloudflare and other protections