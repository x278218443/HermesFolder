# React SPA Content Extraction Patterns

## Why Direct Access Fails

React/Vue SPAs serve an HTML shell with JavaScript that renders content client-side. The actual data is either:
- Bundled in the JavaScript (check `<script>` tags)
- Fetched via API after page load (intercept via fetch/XHR)
- Stored in React/Vue state (accessible via fiber/instance tree)

## Pattern 1: Accessibility Tree Extraction

Most reliable for extracting rendered content. Works even when DOM manipulation is complex.

```python
browser_navigate(url=target_url)
browser_snapshot(full=True)  # Returns accessibility tree with all text
```

**Advantages**:
- Captures all visible text including dynamically rendered content
- Preserves structure (headers, lists, tables, code blocks)
- No need to understand React/Vue internals

**Limitations**:
- May lose some formatting details
- Tables may come as flat text (needs reconstruction)
- Code blocks may have escaped characters

## Pattern 2: DOM Text Walker

Extract text content with structure preservation:

```javascript
const main = document.querySelector('main, .content, article');
if (main) {
  let result = '';
  const walker = document.createTreeWalker(
    main, 
    NodeFilter.SHOW_TEXT, 
    null, 
    false
  );
  while (walker.nextNode()) {
    const text = walker.currentNode.textContent.trim();
    if (text) result += text + '\n';
  }
  result;
}
```

**When to use**: Content is in standard HTML elements, not custom components.

## Pattern 3: React Fiber Tree Extraction

For deep extraction from React state/props:

```javascript
function findReactFiber(el) {
  const key = Object.keys(el).find(
    k => k.startsWith('__reactFiber$') || 
         k.startsWith('__reactInternalInstance$')
  );
  return key ? el[key] : null;
}

// Walk fiber tree
function extractFromFiber(fiber, depth = 0) {
  if (depth > 30 || !fiber) return null;
  
  // Check memoizedState for content
  let state = fiber.memoizedState;
  while (state) {
    if (state.memoizedState && typeof state.memoizedState === 'object') {
      const s = state.memoizedState;
      if (s.current && typeof s.current === 'string' && s.current.length > 100) {
        return s.current;
      }
    }
    state = state.next;
  }
  
  // Check memoizedProps
  let props = fiber.memoizedProps;
  if (props) {
    for (const key of Object.keys(props)) {
      if (typeof props[key] === 'string' && props[key].includes('target-text')) {
        return props[key];
      }
    }
  }
  
  // Recurse
  return extractFromFiber(fiber.child, depth + 1) || 
         extractFromFiber(fiber.sibling, depth + 1);
}
```

**When to use**: Content is stored in React state, not rendered in DOM.

## Pattern 4: Intercepting API Calls

Monitor what the SPA fetches:

```javascript
// Before navigation, install interceptor
const origFetch = window.fetch;
window._interceptedUrls = [];
window.fetch = function(...args) {
  window._interceptedUrls.push(args[0]);
  return origFetch.apply(this, args);
};

// After interaction, check intercepted URLs
JSON.stringify(window._interceptedUrls);
```

**Limitations**:
- Doesn't catch XHR (only fetch)
- Doesn't catch programmatic anchor clicks
- Doesn't catch Blob URLs created after page load

## Pattern 5: Performance API for Resource URLs

```javascript
performance.getEntriesByType('resource')
  .filter(r => r.name.includes('api') || r.name.includes('data'))
  .map(r => r.name);
```

**When to use**: Finding API endpoints the SPA calls.

## Common Anti-Patterns

1. **Don't rely on download button href**: Often uses Blob URLs or programmatic clicks
2. **Don't assume API endpoints**: Try `/api/`, `/raw/`, `/data/` patterns but don't assume
3. **Don't skip the accessibility tree**: It's the most reliable extraction method
4. **Don't forget variable redeclaration**: Use IIFE or unique names in browser console
