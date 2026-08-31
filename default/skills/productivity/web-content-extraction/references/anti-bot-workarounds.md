# Anti-Bot Workarounds for Web Content Extraction

## Cloudflare Challenges

Cloudflare returns a challenge page that requires JavaScript execution and browser fingerprinting. Cannot be bypassed with curl.

**Detection**:
- Response contains "Just a moment..." title
- Response contains `cf_chl_opt` variable
- Response contains `/cdn-cgi/challenge-platform/` script

**Workaround**: Use full browser with JavaScript execution (browser_navigate). There's no curl-based solution.

## Rate Limiting

Some sites implement rate limiting or CAPTCHA after multiple requests.

**Detection**:
- HTTP 429 status
- Response contains "rate limit" or "too many requests"
- Unexpected redirects to login/CAPTCHA pages

**Workaround**:
- Add delays between requests (if doing multiple)
- Use browser session instead of multiple curl calls
- Check if content is available in cached/static form

## JavaScript-Required Pages

Pages that only render content with JavaScript enabled.

**Detection**:
- HTML shell only (no content in `<body>`)
- Content appears in browser but not in curl
- `noscript` tag with "Enable JavaScript" message

**Workaround**: Use browser_navigate to execute JavaScript.

## API Authentication

Some APIs require authentication tokens or cookies.

**Detection**:
- HTTP 401/403 responses
- "Unauthorized" or "Forbidden" in response
- Redirect to login page

**Workaround**:
1. Check if there's a public/anonymous endpoint
2. Look for tokens in page source or localStorage
3. Use browser to establish session first, then extract cookies

## Content Obfuscation

Some sites obfuscate content to prevent scraping.

**Detection**:
- Content appears as gibberish in raw HTML
- Unicode escape sequences (`\uXXXX`)
- CSS-based content hiding

**Workaround**:
- Browser rendering usually deobfuscates automatically
- Use accessibility tree (browser_snapshot) which gets rendered text

## Geo-Restrictions

Content restricted by geographic location.

**Detection**:
- HTTP 403 with "access denied" from specific regions
- Redirect to localized version with different content

**Workaround**:
- Use proxy/VPN if available
- Check for alternative CDN endpoints (e.g., `cn.clawhub-mirror.com` for China)

## SPA-Specific Challenges

### Hash Routing
Some SPAs use hash routing (`#/path`) instead of path routing.

**Workaround**: Include hash in URL: `https://example.com/#/skills/claw-stock`

### Lazy Loading
Content loaded on scroll or interaction.

**Workaround**: 
- Scroll page before extraction: `browser_scroll(direction="down")`
- Click to expand sections: `browser_click(ref="section-header")`

### Infinite Scroll
Content loads as user scrolls.

**Workaround**: Multiple scroll + snapshot cycles until no new content appears.

### Dynamic Imports
JavaScript modules loaded on demand.

**Workaround**: Wait for specific element to appear, then extract.

## Browser Console Variable Conflicts

JavaScript variables declared in browser console persist across calls but can conflict.

**Error**: `Identifier 'X' has already been declared`

**Workaround**:
```javascript
// Instead of:
const result = {};

// Use:
const extractionResult = {};

// Or wrap in IIFE:
(function() {
  const result = {};
  // ... extraction logic
  return result;
})()
```

## Cookie/Session Issues

Browser sessions may have different cookies than expected.

**Workaround**:
- Clear cookies: `browser_console(expression="document.cookie.split(';').forEach(c => document.cookie = c.trim().split('=')[0] + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT')")`
- Use incognito/private browsing if available
- Check if content is available without authentication
