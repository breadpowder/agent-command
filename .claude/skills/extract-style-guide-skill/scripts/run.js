#!/usr/bin/env node
/**
 * Extract Style Guide Skill for Claude Code
 *
 * Analyzes HTML template files and extracts comprehensive style guides
 * documenting all design patterns, tokens, and styling rules.
 *
 * Usage:
 *   node run.js <html-file-path> [output-file-path]
 *   node run.js template.html
 *   node run.js template.html custom-output.md
 *
 * Default output: STYLE_GUIDE.md in .superdesign/ directory or project root
 */

const fs = require('fs');
const path = require('path');

// Change to skill directory for proper module resolution
process.chdir(__dirname);

/**
 * Check if cheerio is installed
 */
function checkCheerioInstalled() {
  try {
    require.resolve('cheerio');
    return true;
  } catch (e) {
    return false;
  }
}

/**
 * Install cheerio if missing
 */
function installCheerio() {
  console.log('📦 Cheerio not found. Installing...');
  const { execSync } = require('child_process');
  try {
    execSync('npm install', { stdio: 'inherit', cwd: __dirname });
    console.log('✅ Cheerio installed successfully');
    return true;
  } catch (e) {
    console.error('❌ Failed to install cheerio:', e.message);
    console.error('Please run manually: cd', __dirname, '&& npm install');
    return false;
  }
}

/**
 * Parse command line arguments
 */
function parseArguments() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.error('❌ Error: No HTML file specified');
    console.log('Usage: node run.js <html-file-path> [output-file-path]');
    console.log('Example: node run.js template.html');
    process.exit(1);
  }

  const htmlFilePath = path.resolve(process.cwd(), args[0]);
  const outputPath = args[1]
    ? path.resolve(process.cwd(), args[1])
    : null; // Will be auto-determined later

  return { htmlFilePath, outputPath };
}

/**
 * Read HTML file
 */
function readHTMLFile(filePath) {
  if (!fs.existsSync(filePath)) {
    console.error(`❌ Error: File not found: ${filePath}`);
    process.exit(1);
  }

  try {
    const content = fs.readFileSync(filePath, 'utf-8');
    console.log(`✅ Read HTML file: ${path.basename(filePath)} (${content.length} characters)`);
    return content;
  } catch (error) {
    console.error(`❌ Error reading file: ${error.message}`);
    process.exit(1);
  }
}

/**
 * Extract CSS custom properties from :root
 */
function extractCSSVariables(html) {
  const rootMatch = html.match(/:root\s*{([^}]+)}/s);
  if (!rootMatch) return {};

  const variables = {};
  const cssText = rootMatch[1];
  const varPattern = /--([\w-]+):\s*([^;]+);/g;
  let match;

  while ((match = varPattern.exec(cssText)) !== null) {
    variables[match[1]] = match[2].trim();
  }

  return variables;
}

/**
 * Extract font imports (Google Fonts)
 */
function extractFontImports(html) {
  const fonts = [];
  const fontPattern = /<link[^>]*href=["']([^"']*fonts\.googleapis\.com[^"']*)["'][^>]*>/gi;
  let match;

  while ((match = fontPattern.exec(html)) !== null) {
    fonts.push(match[1]);
  }

  return fonts;
}

/**
 * Extract icon library imports
 */
function extractIconLibrary(html) {
  const lucideMatch = html.match(/<script[^>]*src=["']([^"']*lucide[^"']*)["'][^>]*>/i);
  if (lucideMatch) {
    return {
      name: 'Lucide Icons',
      cdn: lucideMatch[1],
      usage: 'data-lucide="icon-name"'
    };
  }

  const heroMatch = html.match(/<script[^>]*src=["']([^"']*heroicons[^"']*)["'][^>]*>/i);
  if (heroMatch) {
    return {
      name: 'Heroicons',
      cdn: heroMatch[1],
      usage: '<HeroIcon />'
    };
  }

  return null;
}

/**
 * Extract CSS classes and their definitions
 */
function extractCSSClasses(html) {
  const classes = {};
  const styleMatch = html.match(/<style[^>]*>([\s\S]*?)<\/style>/i);
  if (!styleMatch) return classes;

  const css = styleMatch[1];

  // Extract class definitions (simplified - matches .classname { ... })
  const classPattern = /\.([\w-]+)\s*{([^}]+)}/g;
  let match;

  while ((match = classPattern.exec(css)) !== null) {
    const className = match[1];
    const properties = match[2].trim();

    if (!classes[className]) {
      classes[className] = [];
    }
    classes[className].push(properties);
  }

  return classes;
}

/**
 * Extract keyframe animations
 */
function extractAnimations(html) {
  const animations = {};
  const styleMatch = html.match(/<style[^>]*>([\s\S]*?)<\/style>/i);
  if (!styleMatch) return animations;

  const css = styleMatch[1];
  const animPattern = /@keyframes\s+([\w-]+)\s*{([^}]+(?:{[^}]*}[^}]*)*)}/g;
  let match;

  while ((match = animPattern.exec(css)) !== null) {
    animations[match[1]] = match[2].trim();
  }

  return animations;
}

/**
 * Categorize CSS variables by type
 */
function categorizeVariables(variables) {
  const categories = {
    colors: {},
    typography: {},
    spacing: {},
    shadows: {},
    radius: {},
    other: {}
  };

  for (const [key, value] of Object.entries(variables)) {
    if (key.includes('color') || key.includes('background') || key.includes('foreground') ||
        key.includes('border') || key.includes('primary') || key.includes('secondary') ||
        key.includes('accent') || key.includes('destructive') || key.includes('success') ||
        key.includes('muted') || key.includes('card') || key.includes('popover') ||
        key.includes('input') || key.includes('ring') || value.includes('oklch') ||
        value.includes('hsl') || value.includes('rgb') || value.includes('#')) {
      categories.colors[key] = value;
    } else if (key.includes('font') || key.includes('tracking') || key.includes('letter')) {
      categories.typography[key] = value;
    } else if (key.includes('spacing') || key === 'spacing') {
      categories.spacing[key] = value;
    } else if (key.includes('shadow')) {
      categories.shadows[key] = value;
    } else if (key.includes('radius')) {
      categories.radius[key] = value;
    } else {
      categories.other[key] = value;
    }
  }

  return categories;
}

/**
 * Generate style guide markdown
 */
function generateStyleGuide(htmlFilePath, html) {
  const fileName = path.basename(htmlFilePath);
  const variables = extractCSSVariables(html);
  const categories = categorizeVariables(variables);
  const fonts = extractFontImports(html);
  const icons = extractIconLibrary(html);
  const animations = extractAnimations(html);
  const classes = extractCSSClasses(html);

  const today = new Date().toISOString().split('T')[0];

  let markdown = `# UI Design Style Guide
> **Generated from**: \`${fileName}\`
> **Last Updated**: ${today}
> **Purpose**: Comprehensive design system documentation for consistent UI implementation

---

## Table of Contents
1. [Overview](#overview)
2. [Color Palette](#color-palette)
3. [Typography](#typography)
4. [Spacing System](#spacing-system)
5. [Shadows & Elevation](#shadows--elevation)
6. [Border Radius](#border-radius)
7. [Animations & Transitions](#animations--transitions)
8. [Component Classes](#component-classes)
9. [Resources & Dependencies](#resources--dependencies)
10. [Quick Reference](#quick-reference)

---

## 1. Overview

This design system was extracted from \`${fileName}\` and documents all design patterns, tokens, and styling rules used in the template.

**Key Characteristics:**
- CSS Custom Properties (CSS Variables) for theming
- ${Object.keys(categories.colors).length} color tokens defined
- ${fonts.length > 0 ? 'Google Fonts integration' : 'System fonts'}
- ${icons ? icons.name + ' for iconography' : 'No icon library detected'}
- ${Object.keys(animations).length} keyframe animations

---

## 2. Color Palette

### 2.1 CSS Color Variables

\`\`\`css
:root {
${Object.entries(categories.colors).map(([key, value]) => `  --${key}: ${value};`).join('\n')}
}
\`\`\`

### 2.2 Color Categories

| Variable | Value | Usage |
|----------|-------|-------|
${Object.entries(categories.colors).map(([key, value]) => {
  let usage = 'General use';
  if (key.includes('primary')) usage = 'Primary brand color, buttons, links';
  else if (key.includes('secondary')) usage = 'Secondary UI elements';
  else if (key.includes('background')) usage = 'Page background';
  else if (key.includes('foreground')) usage = 'Primary text color';
  else if (key.includes('card')) usage = 'Card backgrounds';
  else if (key.includes('border')) usage = 'Border colors';
  else if (key.includes('destructive')) usage = 'Error states, delete actions';
  else if (key.includes('success')) usage = 'Success states, confirmations';
  else if (key.includes('muted')) usage = 'Disabled or muted elements';
  else if (key.includes('accent')) usage = 'Accent colors, highlights';

  return `| \`--${key}\` | \`${value}\` | ${usage} |`;
}).join('\n')}

**Color Format**: Most colors use **OKLCH** color space for perceptual uniformity.

---

## 3. Typography

### 3.1 Font System

${fonts.length > 0 ? `**Google Fonts Import:**
\`\`\`html
${fonts.map(url => `<link href="${url}" rel="stylesheet">`).join('\n')}
\`\`\`` : '**System Fonts**: Using default system font stack'}

\`\`\`css
${Object.entries(categories.typography).map(([key, value]) => `--${key}: ${value};`).join('\n')}
\`\`\`

### 3.2 Typography Variables

| Variable | Value | Usage |
|----------|-------|-------|
${Object.entries(categories.typography).map(([key, value]) =>
  `| \`--${key}\` | \`${value}\` | ${key.includes('sans') ? 'Primary font family' : key.includes('serif') ? 'Serif font family' : key.includes('mono') ? 'Monospace font' : 'Typography setting'} |`
).join('\n')}

---

## 4. Spacing System

${Object.keys(categories.spacing).length > 0 ? `### 4.1 Spacing Variables

\`\`\`css
${Object.entries(categories.spacing).map(([key, value]) => `--${key}: ${value};`).join('\n')}
\`\`\`

All spacing uses multiples of the base spacing unit for consistency.` : `**No spacing variables defined** - spacing may be defined inline or in class definitions.`}

---

## 5. Shadows & Elevation

### 5.1 Shadow Scale

\`\`\`css
${Object.entries(categories.shadows).map(([key, value]) => `--${key}: ${value};`).join('\n')}
\`\`\`

### 5.2 Shadow Usage

| Variable | Value | Usage |
|----------|-------|-------|
${Object.entries(categories.shadows).map(([key, value]) => {
  let usage = 'General shadow';
  if (key.includes('sm') || key.includes('2xs') || key.includes('xs')) usage = 'Subtle elevation, borders';
  else if (key.includes('md')) usage = 'Moderate elevation, hover states';
  else if (key.includes('lg') || key.includes('xl') || key.includes('2xl')) usage = 'High elevation, modals, dropdowns';
  else usage = 'Default shadow';

  return `| \`--${key}\` | \`${value}\` | ${usage} |`;
}).join('\n')}

---

## 6. Border Radius

### 6.1 Radius Scale

\`\`\`css
${Object.entries(categories.radius).map(([key, value]) => `--${key}: ${value};`).join('\n')}
\`\`\`

${Object.keys(categories.radius).length > 0 ? `**Base Radius**: \`${categories.radius.radius || 'Defined in variables'}\`

Use \`var(--radius)\` for consistent border radius across components.` : '**Note**: Border radius may be defined in component classes.'}

---

## 7. Animations & Transitions

### 7.1 Keyframe Animations

${Object.keys(animations).length > 0 ? Object.entries(animations).map(([name, definition]) => `**Animation: \`${name}\`**
\`\`\`css
@keyframes ${name} {
${definition}
}
\`\`\``).join('\n\n') : '**No keyframe animations defined** - transitions may be defined inline in component classes.'}

### 7.2 Common Transitions

Check component classes for transition definitions. Common patterns:
- \`transition: all 0.2s ease-out\` - Fast transitions (buttons, small elements)
- \`transition: all 0.3s ease-out\` - Medium transitions (modals, larger elements)
- \`transition: all 0.35s ease-out\` - Slow transitions (layout changes)

---

## 8. Component Classes

### 8.1 Extracted Classes

${Object.keys(classes).length > 0 ? `Total classes found: **${Object.keys(classes).length}**

**Major Component Categories:**
${(() => {
  const buttonClasses = Object.keys(classes).filter(c => c.includes('button') || c.includes('btn'));
  const cardClasses = Object.keys(classes).filter(c => c.includes('card'));
  const formClasses = Object.keys(classes).filter(c => c.includes('input') || c.includes('form') || c.includes('select'));
  const navClasses = Object.keys(classes).filter(c => c.includes('nav') || c.includes('breadcrumb') || c.includes('tab'));
  const messageClasses = Object.keys(classes).filter(c => c.includes('message') || c.includes('chat') || c.includes('bubble'));

  const categories = [];
  if (buttonClasses.length > 0) categories.push(`- **Buttons** (${buttonClasses.length}): ${buttonClasses.slice(0, 5).map(c => `\`.${c}\``).join(', ')}${buttonClasses.length > 5 ? '...' : ''}`);
  if (cardClasses.length > 0) categories.push(`- **Cards** (${cardClasses.length}): ${cardClasses.slice(0, 5).map(c => `\`.${c}\``).join(', ')}${cardClasses.length > 5 ? '...' : ''}`);
  if (formClasses.length > 0) categories.push(`- **Forms** (${formClasses.length}): ${formClasses.slice(0, 5).map(c => `\`.${c}\``).join(', ')}${formClasses.length > 5 ? '...' : ''}`);
  if (navClasses.length > 0) categories.push(`- **Navigation** (${navClasses.length}): ${navClasses.slice(0, 5).map(c => `\`.${c}\``).join(', ')}${navClasses.length > 5 ? '...' : ''}`);
  if (messageClasses.length > 0) categories.push(`- **Messages/Chat** (${messageClasses.length}): ${messageClasses.slice(0, 5).map(c => `\`.${c}\``).join(', ')}${messageClasses.length > 5 ? '...' : ''}`);

  return categories.join('\n');
})()}

**Note**: For complete component code examples, refer to the source template file.` : '**No component classes extracted** - styles may be inline or externally linked.'}

---

## 9. Resources & Dependencies

### 9.1 External Libraries

${fonts.length > 0 ? `**Google Fonts:**
${fonts.map(url => `- ${url}`).join('\n')}` : ''}

${icons ? `**Icon Library:**
- **Library**: ${icons.name}
- **CDN**: \`${icons.cdn}\`
- **Usage**: \`${icons.usage}\`

**Initialization:**
\`\`\`html
<script>
  lucide.createIcons(); // Call after DOM ready
</script>
\`\`\`` : '**No icon library detected**'}

### 9.2 Browser Support

- **OKLCH Colors**: Requires modern browsers (Chrome 111+, Safari 15.4+, Firefox 113+)
  - Consider fallbacks for older browsers
- **CSS Custom Properties**: Widely supported (IE 11 needs fallback)
- **CSS Grid/Flexbox**: Modern browser support required

---

## 10. Quick Reference

### Color Quick Reference
\`\`\`css
/* Most commonly used colors */
${Object.entries(categories.colors).slice(0, 8).map(([key, value]) => `${key}: ${value}`).join('\n')}
\`\`\`

### Shadow Quick Reference
\`\`\`css
/* Shadow elevation scale */
${Object.entries(categories.shadows).map(([key, value]) => `${key}: ${value}`).join('\n')}
\`\`\`

### Radius Quick Reference
\`\`\`css
/* Border radius scale */
${Object.entries(categories.radius).map(([key, value]) => `${key}: ${value}`).join('\n')}
\`\`\`

---

**End of Style Guide**

Generated by Claude Code \`extract-style-guide-skill\`
`;

  return markdown;
}

/**
 * Determine output file path
 */
function determineOutputPath(htmlFilePath, userSpecifiedPath) {
  if (userSpecifiedPath) {
    return userSpecifiedPath;
  }

  // Try .superdesign/ directory first
  const projectRoot = path.dirname(path.dirname(path.dirname(htmlFilePath)));
  const superdesignPath = path.join(projectRoot, '.superdesign', 'STYLE_GUIDE.md');
  const superdesignDir = path.dirname(superdesignPath);

  if (fs.existsSync(superdesignDir)) {
    return superdesignPath;
  }

  // Fall back to project root
  return path.join(projectRoot, 'STYLE_GUIDE.md');
}

/**
 * Write style guide to file
 */
function writeStyleGuide(outputPath, content) {
  try {
    // Ensure directory exists
    const dir = path.dirname(outputPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }

    fs.writeFileSync(outputPath, content, 'utf-8');
    console.log(`\n✅ Style guide generated successfully`);
    console.log(`📄 Location: ${outputPath}`);
    console.log(`📊 Size: ${(content.length / 1024).toFixed(2)} KB`);
    return true;
  } catch (error) {
    console.error(`❌ Error writing file: ${error.message}`);
    return false;
  }
}

/**
 * Extract comprehensive data using cheerio and prepare for Claude analysis
 */
function extractComprehensiveData(htmlFilePath, html) {
  const fileName = path.basename(htmlFilePath);
  const variables = extractCSSVariables(html);
  const categories = categorizeVariables(variables);
  const fonts = extractFontImports(html);
  const icons = extractIconLibrary(html);
  const animations = extractAnimations(html);
  const classes = extractCSSClasses(html);

  // Use cheerio for more detailed extraction
  const cheerio = require('cheerio');
  const $ = cheerio.load(html);

  // Extract more detailed information
  const extractionData = {
    metadata: {
      fileName,
      extractedAt: new Date().toISOString(),
      templateSize: html.length,
      extractionMethod: 'hybrid-cheerio-claude'
    },
    designTokens: {
      colors: categories.colors,
      typography: categories.typography,
      spacing: categories.spacing,
      shadows: categories.shadows,
      radius: categories.radius,
      other: categories.other
    },
    dependencies: {
      fonts,
      icons
    },
    animations,
    components: {
      classes,
      totalCount: Object.keys(classes).length,
      categories: categorizeClasses(classes)
    },
    htmlStructure: {
      totalElements: $('*').length,
      interactiveElements: $('button, input, select, textarea, a[href]').length,
      hasForm: $('form').length > 0,
      hasModal: $('.modal, [role="dialog"]').length > 0,
      hasNavigation: $('nav, .nav, .navigation').length > 0
    }
  };

  return extractionData;
}

/**
 * Categorize CSS classes by component type
 */
function categorizeClasses(classes) {
  const classNames = Object.keys(classes);

  return {
    buttons: classNames.filter(c => c.includes('button') || c.includes('btn')),
    cards: classNames.filter(c => c.includes('card')),
    forms: classNames.filter(c => c.includes('input') || c.includes('form') || c.includes('select') || c.includes('textarea')),
    navigation: classNames.filter(c => c.includes('nav') || c.includes('breadcrumb') || c.includes('tab') || c.includes('menu')),
    messages: classNames.filter(c => c.includes('message') || c.includes('chat') || c.includes('bubble') || c.includes('toast')),
    modals: classNames.filter(c => c.includes('modal') || c.includes('dialog') || c.includes('overlay') || c.includes('popup')),
    layout: classNames.filter(c => c.includes('container') || c.includes('wrapper') || c.includes('layout') || c.includes('grid') || c.includes('sidebar')),
    typography: classNames.filter(c => c.includes('title') || c.includes('text') || c.includes('heading') || c.includes('label')),
    states: classNames.filter(c => c.includes('hover') || c.includes('active') || c.includes('focus') || c.includes('disabled') || c.includes('loading')),
    utility: classNames.filter(c => c.includes('hidden') || c.includes('visible') || c.includes('scroll') || c.includes('truncate'))
  };
}

/**
 * Generate Claude analysis prompt
 */
function generateClaudePrompt(extractionData, htmlFilePath) {
  return `# Style Guide Analysis Request

I've extracted raw design data from the HTML template using cheerio. Please analyze this data and generate a comprehensive, high-quality style guide following the structure from the \`/extract-style-guide\` command.

## Extracted Data

\`\`\`json
${JSON.stringify(extractionData, null, 2)}
\`\`\`

## Template File
**Source**: \`${path.basename(htmlFilePath)}\`

## Analysis Instructions

Please analyze the extracted data and generate a comprehensive STYLE_GUIDE.md that includes:

1. **Enhanced Color Analysis**:
   - Convert OKLCH colors to HEX equivalents for reference
   - Identify color relationships and hierarchies
   - Document color usage patterns and semantics
   - Note any gradients used

2. **Typography Analysis**:
   - Document the complete type scale
   - Identify font weights and their usage
   - Note line heights and letter spacing patterns

3. **Component Pattern Recognition**:
   - Analyze the ${extractionData.components.totalCount} CSS classes
   - Identify component patterns and variants
   - Document component states (hover, focus, active, disabled)
   - Provide code examples for major components

4. **Interaction Patterns**:
   - Analyze the ${Object.keys(extractionData.animations).length} animations
   - Document transition patterns and timing
   - Identify hover/focus/active patterns

5. **Design System Insights**:
   - Identify the design philosophy (minimal, modern, neo-brutalist, etc.)
   - Note consistency patterns
   - Suggest areas for improvement or standardization

6. **Migration Guide**:
   - Provide step-by-step instructions for applying these styles to new pages
   - Include common pitfalls and solutions

Please generate the complete STYLE_GUIDE.md following the comprehensive structure from the \`/extract-style-guide\` command.`;
}

/**
 * Main execution
 */
function main() {
  console.log('🎨 Extract Style Guide Skill (Hybrid: Cheerio + Claude)\n');

  // Check dependencies
  if (!checkCheerioInstalled()) {
    if (!installCheerio()) {
      process.exit(1);
    }
  }

  // Parse arguments
  const { htmlFilePath, outputPath } = parseArguments();

  // Read HTML
  const html = readHTMLFile(htmlFilePath);

  // Phase 1: Automated extraction with cheerio
  console.log('🔍 Phase 1: Automated extraction with cheerio...');
  const extractionData = extractComprehensiveData(htmlFilePath, html);

  console.log(`✅ Extracted:`);
  console.log(`   - ${Object.keys(extractionData.designTokens.colors).length} color tokens`);
  console.log(`   - ${Object.keys(extractionData.designTokens.typography).length} typography tokens`);
  console.log(`   - ${extractionData.components.totalCount} component classes`);
  console.log(`   - ${Object.keys(extractionData.animations).length} animations`);
  console.log(`   - ${extractionData.htmlStructure.totalElements} HTML elements`);

  // Save extraction data to JSON
  const projectRoot = path.dirname(path.dirname(path.dirname(htmlFilePath)));
  const extractionJsonPath = path.join(projectRoot, '.superdesign', 'extraction-data.json');

  try {
    const dir = path.dirname(extractionJsonPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(extractionJsonPath, JSON.stringify(extractionData, null, 2), 'utf-8');
    console.log(`\n📊 Extraction data saved: ${extractionJsonPath}`);
  } catch (error) {
    console.error(`⚠️  Could not save extraction data: ${error.message}`);
  }

  // Phase 2: Generate basic style guide (automated)
  console.log('\n🔍 Phase 2: Generating basic style guide...');
  const basicStyleGuide = generateStyleGuide(htmlFilePath, html);
  const finalOutputPath = determineOutputPath(htmlFilePath, outputPath);

  if (writeStyleGuide(finalOutputPath, basicStyleGuide)) {
    console.log(`✅ Basic style guide generated: ${finalOutputPath}`);
  } else {
    console.error('❌ Failed to write basic style guide');
  }

  // Phase 3: Prepare Claude analysis
  console.log('\n🤖 Phase 3: Preparing Claude analysis prompt...');
  const claudePrompt = generateClaudePrompt(extractionData, htmlFilePath);
  const promptPath = path.join(projectRoot, '.superdesign', 'claude-analysis-prompt.md');

  try {
    fs.writeFileSync(promptPath, claudePrompt, 'utf-8');
    console.log(`✅ Claude prompt saved: ${promptPath}`);
  } catch (error) {
    console.error(`⚠️  Could not save Claude prompt: ${error.message}`);
  }

  // Summary and next steps
  console.log(`\n✨ Hybrid extraction complete!\n`);
  console.log(`📋 Generated Files:`);
  console.log(`   1. ${extractionJsonPath} - Raw extraction data (JSON)`);
  console.log(`   2. ${finalOutputPath} - Basic style guide`);
  console.log(`   3. ${promptPath} - Claude analysis prompt\n`);

  console.log(`🚀 Next Steps:`);
  console.log(`   1. [AUTOMATED] Basic style guide already generated`);
  console.log(`   2. [CLAUDE] Run: Read '${promptPath}' and analyze`);
  console.log(`   3. [RESULT] Claude will generate comprehensive STYLE_GUIDE.md\n`);

  console.log(`💡 Quick Claude Analysis:`);
  console.log(`   Ask Claude: "Read ${promptPath} and generate the comprehensive style guide"`);
  console.log(`   Or copy the content and paste to Claude for analysis\n`);
}

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = { main, generateStyleGuide, extractCSSVariables };
