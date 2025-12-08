---
description: Smart screenshot capture for HTML mockups with multiple tabs/views - eliminates empty space
---

You are tasked with capturing optimized screenshots of an HTML mockup file that contains multiple tabs or views.

## Input Parameters

Ask the user for:
1. **HTML file path**: Full path to the HTML file (default: `.superdesign/design_iterations/compliance_admin_portal.html`)
2. **Tab selector pattern**: CSS selector pattern for tabs (default: `button[data-tab]`)
3. **Tab names**: Comma-separated list of tab names (default: auto-detect from data-tab attributes)
4. **Output folder**: Where to save screenshots (default: `/Users/a3q6/Library/CloudStorage/<subpath>/mockups`)
5. **Output prefix**: Filename prefix for screenshots (default: extracted from HTML filename)

## Process

1. **Create Playwright Script** (`/tmp/screenshot-html-smart.js`):
   - Launch browser with temporary page to analyze content
   - For each tab/view:
     - Switch to the tab
     - Measure actual content boundaries (ignore full-width containers)
     - Detect meaningful content elements (cards, buttons, forms, text)
     - Calculate min/max positions
   - Calculate optimal viewport dimensions:
     - Width: leftOffset + maxContentWidth + rightPadding (60px)
     - Height: maxContentHeight + verticalPadding (120px total)
   - Create new page with optimal viewport
   - Capture full-page screenshots for each tab

2. **Content Detection Strategy**:
   ```javascript
   const meaningfulSelectors = [
     '.card', '.stat-card', '.feedback-item', '.query-item',
     'button', 'input', 'textarea', 'table', 'form',
     'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p',
     '.badge', '.tag', '.label', '.metric', '.filter-option'
   ];

   // Filter to visible elements with width < 95% of viewport
   // This excludes full-width background containers
   ```

3. **Run Script**:
   - Execute using `node run.js /tmp/screenshot-html-smart.js`
   - Display progress for each tab
   - Show final viewport dimensions and file locations

4. **Output**:
   - Save screenshots to specified folder
   - Naming: `{prefix}-{tab-name}.png`
   - Report file sizes and total reduction in empty space

## Example Playwright Script Template

```javascript
const { chromium } = require('playwright');

const HTML_FILE = 'file://{html_path}';
const OUTPUT_DIR = '{output_dir}';
const OUTPUT_PREFIX = '{prefix}';
const TAB_SELECTOR = '{tab_selector}';
const TAB_NAMES = {tab_names_array};

(async () => {
  const browser = await chromium.launch({ headless: false });
  const tempPage = await browser.newPage({ viewport: { width: 1920, height: 1080 } });

  await tempPage.goto(HTML_FILE);
  await tempPage.waitForTimeout(2000);

  console.log('📏 Ultra-smart content boundary detection...\\n');

  const tabDimensions = {};

  for (const tab of TAB_NAMES) {
    await tempPage.locator(\`${TAB_SELECTOR}="${tab}"\`).click();
    await tempPage.waitForTimeout(500);

    const dimensions = await tempPage.evaluate(() => {
      const meaningfulSelectors = [
        '.card', '.stat-card', '.feedback-item', '.query-item',
        'button', 'input', 'textarea', 'table', 'form',
        'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p',
        '.badge', '.tag', '.label', '.metric', '.filter-option'
      ];

      const meaningfulElements = [];
      meaningfulSelectors.forEach(selector => {
        meaningfulElements.push(...Array.from(document.querySelectorAll(selector)));
      });

      const visibleElements = meaningfulElements.filter(el => {
        const rect = el.getBoundingClientRect();
        const style = window.getComputedStyle(el);
        return (
          rect.width > 0 &&
          rect.height > 0 &&
          style.display !== 'none' &&
          style.visibility !== 'hidden' &&
          rect.width < window.innerWidth * 0.95
        );
      });

      let minLeft = Infinity, maxRight = 0, minTop = Infinity, maxBottom = 0;

      visibleElements.forEach(el => {
        const rect = el.getBoundingClientRect();
        minLeft = Math.min(minLeft, rect.left);
        maxRight = Math.max(maxRight, rect.right);
        minTop = Math.min(minTop, rect.top);
        maxBottom = Math.max(maxBottom, rect.bottom);
      });

      return {
        contentWidth: Math.ceil(maxRight - minLeft),
        contentHeight: Math.ceil(maxBottom - minTop),
        minLeft: Math.ceil(minLeft),
        elementCount: visibleElements.length
      };
    });

    tabDimensions[tab] = dimensions;
    console.log(\`   ${tab} tab (${dimensions.elementCount} elements): ${dimensions.contentWidth}px × ${dimensions.contentHeight}px\`);
  }

  const maxWidth = Math.max(...Object.values(tabDimensions).map(d => d.contentWidth));
  const maxHeight = Math.max(...Object.values(tabDimensions).map(d => d.contentHeight));
  const minLeft = Math.min(...Object.values(tabDimensions).map(d => d.minLeft));

  const optimalWidth = Math.ceil(minLeft + maxWidth + 60);
  const optimalHeight = Math.ceil(maxHeight + 120);

  console.log(\`\\n✨ Optimal viewport: ${optimalWidth}px × ${optimalHeight}px\\n\`);

  await tempPage.close();

  const page = await browser.newPage({ viewport: { width: optimalWidth, height: optimalHeight } });
  await page.goto(HTML_FILE);
  await page.waitForTimeout(2000);

  console.log('📸 Capturing screenshots...\\n');

  for (const tab of TAB_NAMES) {
    await page.locator(\`${TAB_SELECTOR}="${tab}"\`).click();
    await page.waitForTimeout(500);

    const outputPath = \`${OUTPUT_DIR}/${OUTPUT_PREFIX}-${tab}.png\`;
    await page.screenshot({ path: outputPath, fullPage: true });

    console.log(\`✅ ${tab}: ${outputPath}\`);
  }

  console.log('\\n✅ Complete!');
  await browser.close();
})();
```

## Success Criteria

- All tabs/views captured with minimal empty space
- Screenshots saved to OneDrive mockups folder
- Viewport optimized based on actual content boundaries
- Progress shown for each step
- File paths and sizes reported
