---
name: extract-style-guide-skill
description: Extract comprehensive style guides from HTML templates using a hybrid approach (automated cheerio extraction + Claude analysis). Use when user requests style guide generation from HTML/mockups, or when working with design iterations in .superdesign/ directory. This skill should be used for documenting design systems, extracting design tokens (colors, typography, spacing), and creating migration guides from mockup to production code.
---

# Extract Style Guide

Extract comprehensive style guides from HTML templates to document design systems and enable consistent UI implementation across pages.

## Purpose

This skill extracts design patterns, tokens, and styling rules from HTML templates using a two-stage hybrid approach:

1. **Stage 1 (Automated)**: Run `scripts/run.js` to extract raw CSS data with cheerio
2. **Stage 2 (Claude Analysis)**: Analyze extraction data to create comprehensive style guide

The hybrid approach combines deterministic extraction (cheerio) with intelligent analysis (Claude) to produce production-ready documentation.

## When to Use

Use this skill when:

- User requests "extract style guide" or "generate style guide" from an HTML template
- Working with files in `.superdesign/design_iterations/` or similar design directories
- User wants to document a design system from mockups
- User needs to apply consistent styles from one page to other pages
- User mentions "design tokens", "color palette", "typography system", or "component library"

## How to Use

### Step 1: Run Automated Extraction

Execute the extraction script on the HTML template:

```bash
cd /home/zineng/workspace/workflow/.claude/skills/extract-style-guide-skill
node scripts/run.js /path/to/template.html
```

**Example:**
```bash
node scripts/run.js ../../.superdesign/design_iterations/chat-ui.html
```

The script will automatically:
- Extract CSS variables from `:root` blocks
- Categorize design tokens (colors, typography, spacing, shadows, radius)
- Identify component classes and patterns
- Extract animations and keyframes
- Analyze HTML structure for component types
- Generate 3 output files in `.superdesign/` directory

**Expected Output Files:**
1. `extraction-data.json` - Raw JSON data (5-10 KB)
2. `STYLE_GUIDE.md` - Basic automated guide (8-10 KB)
3. `claude-analysis-prompt.md` - Prompt for Claude analysis (7-10 KB)

**Typical Extraction Time:** 1-2 seconds

### Step 2: Analyze with Claude (REQUIRED)

Read the generated `claude-analysis-prompt.md` file and perform comprehensive analysis to create the enhanced style guide:

```bash
# Read the prompt file
Read .superdesign/claude-analysis-prompt.md
```

**Analysis Tasks:**

1. **Color Enhancement**
   - Convert OKLCH colors to HEX equivalents using https://oklch.com/
   - Add RGB equivalents if needed
   - Analyze color relationships (hue, lightness, chroma)
   - Identify color hierarchy and semantic usage
   - Document gradients with full specifications

2. **Typography Analysis**
   - Extract ACTUAL type scale from CSS classes (not theoretical values)
   - Document font weights, line heights, letter spacing
   - Identify font import sources (Google Fonts URLs)
   - Create usage guidelines for each type style

3. **Component Documentation**
   - Provide copy-paste ready code for ALL component classes
   - Include ALL states: default, hover, focus, active, disabled
   - Add inline px comments for clarity (e.g., `padding: 0.625rem; /* 10px */`)
   - Create HTML usage examples
   - Document when to use each component variant

4. **Spacing & Layout**
   - Extract ACTUAL spacing values from template (not theoretical scale)
   - Document spacing multiplier system
   - Map common usage for each spacing value
   - Document border radius scale

5. **Design Insights**
   - Identify design philosophy (e.g., "Professional Enterprise", "Neo-brutalism")
   - List design system strengths
   - Provide recommendations for improvements
   - Create step-by-step migration guide

6. **Complete Documentation**
   - Add Executive Summary with key achievements
   - Include browser compatibility notes
   - Create Quick Reference section
   - Ensure all code examples are copy-paste ready

**Output File:** Write analysis to `.superdesign/STYLE_GUIDE_ENHANCED.md` (50+ KB)

**Analysis Time:** 30-60 seconds

### Step 3: Inform User of Completion

After generating the enhanced style guide, inform the user:

```
✅ Style guide generated successfully

📄 **Comprehensive Guide**: .superdesign/STYLE_GUIDE_ENHANCED.md (50+ KB)
📄 **Basic Guide**: .superdesign/STYLE_GUIDE.md (8 KB)
📊 **Raw Data**: .superdesign/extraction-data.json

🎨 **Extracted**:
   - [X] OKLCH color tokens (with HEX equivalents)
   - [X] component classes systematically categorized
   - [X] complete type scale
   - [X] keyframe animations
   - [X] spacing system
   - [X] shadow elevation scale

✨ **Includes**:
   - Executive Summary
   - Multi-format colors with analysis (OKLCH + HEX + RGB)
   - Complete component code examples (all states)
   - Transform patterns
   - Design Insights & Philosophy
   - Step-by-step Migration Guide
   - Quick Reference

Ready for use in creating consistent UI designs across new pages.
```

## Quality Standards

Follow these critical requirements during Claude analysis (Stage 2):

1. **Multi-Format Colors (CRITICAL)**
   - Always include OKLCH (source from template)
   - Always include HEX equivalent (convert using https://oklch.com/)
   - Include RGB if present in template
   - Add color analysis explaining hue/lightness/chroma values

2. **Complete Type Scale (CRITICAL)**
   - Extract from ACTUAL CSS classes in template (`.epic-title`, `.section-title`, etc.)
   - Never use theoretical or placeholder values
   - Include: rem/px, weight, line-height, letter-spacing, color, usage

3. **Component Code (CRITICAL)**
   - Provide FULL CSS with inline px comments
   - Include ALL states: default, hover, active, focus, disabled
   - Add HTML usage examples
   - Document when to use each variant

4. **Extraction Accuracy**
   - Extract ACTUAL values from template, never assume or use placeholders
   - Document what exists in template, not what "should" exist
   - Preserve exact values (colors, sizes, timing)

5. **Practical Guidance**
   - Create actionable migration guide with step-by-step checklist
   - Document browser compatibility (OKLCH requires Chrome 111+, Safari 15.4+, Firefox 113+)
   - Provide design insights explaining philosophy and decisions

## Script Behavior

The `scripts/run.js` script will:

- Auto-install cheerio if not present (runs `npm install` automatically)
- Accept two arguments: `<html-file-path>` and optional `<output-file-path>`
- Default output location: `.superdesign/STYLE_GUIDE.md` (relative to template file)
- Generate 3 files: extraction JSON, basic guide, Claude prompt

**Common Issues:**

- **"Cheerio not found"**: Script will auto-install dependencies
- **"I only got basic guide"**: Complete Stage 2 by reading `claude-analysis-prompt.md`
- **Path issues**: Use absolute or relative paths from skill directory

## File Structure

```
.superdesign/
├── extraction-data.json              # Stage 1: Raw JSON data (programmatic access)
├── STYLE_GUIDE.md                    # Stage 1: Basic automated guide (quick reference)
├── claude-analysis-prompt.md         # Stage 1→2: Prompt for Claude analysis
└── STYLE_GUIDE_ENHANCED.md           # Stage 2: Comprehensive guide (FINAL OUTPUT) ✅
```

## Examples

**User Request Examples:**
- "Extract the style guide from this template"
- "Generate a design system doc from chat-ui.html"
- "Document the colors and components from this mockup"
- "I need to apply these styles to other pages, create a guide"

**Expected Workflow:**
1. User creates mockup in `.superdesign/design_iterations/new-feature.html`
2. Claude runs extraction script (Stage 1)
3. Claude reads `claude-analysis-prompt.md` and analyzes (Stage 2)
4. Claude generates `STYLE_GUIDE_ENHANCED.md` with comprehensive documentation
5. User uses enhanced guide to implement consistent styles in production code

**Comparison - Basic vs Enhanced:**

**Basic (Cheerio only):**
```markdown
| `--primary` | `oklch(0.47 0.18 264)` | Primary brand color |
```

**Enhanced (Cheerio + Claude):**
```markdown
| Token | OKLCH | HEX | RGB | Usage |
|-------|-------|-----|-----|-------|
| `--primary` | `oklch(0.47 0.18 264)` | `#3B53D1` | `rgb(59, 83, 209)` | Primary brand, buttons, links, active states |

**Color Analysis:**
- **Hue 264°**: Deep blue in the violet-blue range
- **Lightness 0.47**: Mid-range, ensuring good contrast against white
- **Chroma 0.18**: Moderate saturation for professional appearance
```

## Why Hybrid Approach

| Approach | Pros | Cons |
|----------|------|------|
| **Cheerio Only** | Fast (1-2s), accurate data extraction | No insights, just raw data, no HEX conversion |
| **Claude Only** | Deep analysis, design insights | Slower, may miss CSS patterns |
| **Hybrid (This Skill)** | Fast extraction + intelligent analysis | Requires 2 steps |

The hybrid approach maximizes value: cheerio handles deterministic extraction, Claude provides contextual intelligence.

## Performance

- **Stage 1 (Cheerio)**: 1-3 seconds (depending on template size)
- **Stage 2 (Claude)**: 30-60 seconds
- **Total workflow**: 1-3 minutes end-to-end
- **Output quality**: Professional-grade, production-ready documentation

## Version History

- **v1.0.0 (2025-11-15)**: Initial hybrid implementation with cheerio extraction and Claude analysis integration
