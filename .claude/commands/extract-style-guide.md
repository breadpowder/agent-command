# Extract Style Guide Command

You are a UI design system analyst. Your task is to analyze the provided HTML template files and extract a comprehensive style guide that documents all design patterns, tokens, and styling rules. This style guide will be used to maintain perfect design consistency across future pages.

## Input Files

Please analyze the following HTML template file(s) that the user will provide after this prompt.

## Analysis Process

Follow this systematic approach to extract all styling information:

### Step 1: Read and Parse Templates
- Read all provided HTML files completely
- Identify the structure, components, and styling patterns
- Note any CSS files, style tags, or inline styles
- Identify framework usage (Tailwind, Flowbite, Bootstrap, etc.)

### Step 2: Extract Design Tokens

#### Color System
- Extract ALL colors used in:
  - CSS custom properties (`:root` variables)
  - Tailwind classes (bg-*, text-*, border-*)
  - Inline styles
  - oklch(), hsl(), rgb(), hex values
  - **Gradients**: Linear gradients, radial gradients (extract start/end colors and direction)
- Categorize colors:
  - **Primary palette**: Brand colors
  - **Secondary palette**: Supporting colors
  - **Semantic colors**: Success, error, warning, info
  - **Neutral scale**: Grays, whites, blacks
  - **Background colors**: Page, card, overlay backgrounds
  - **Text colors**: Primary, secondary, muted, disabled
  - **Border colors**: Default, hover, focus states
- Document both light and dark mode if present
- **CRITICAL**: List color values in MULTIPLE formats:
  - **OKLCH**: Original value from code
  - **HEX**: Use online converter (https://oklch.com/) for approximate HEX equivalent
  - **RGB**: If present in code
  - **HSL**: If present in code
- **CSS Variable Dependencies**: Note which color variables reference other color variables

#### Typography System
- **Font families**: Identify all fonts used
  - Extract Google Fonts import links
  - Note primary, secondary, monospace fonts
- **Font weights**: 100, 200, 300, 400, 500, 600, 700, 800, 900
- **Font sizes**: Extract all used sizes for:
  - Headings (H1-H6)
  - Body text
  - Small text, captions
  - Button labels
- **Line heights**: For each text size
- **Letter spacing**: Normal, tight, wide variations
- **Responsive scaling**: How fonts change at breakpoints

#### Spacing System
- Identify spacing scale (4pt, 6pt, or 8pt base system)
- Extract spacing tokens from:
  - Padding (p-*, px-*, py-*, pt-*, pr-*, pb-*, pl-*)
  - Margins (m-*, mx-*, my-*, mt-*, mr-*, mb-*, ml-*)
  - Gap (gap-*, gap-x-*, gap-y-*)
  - Space-between classes
- Document common spacing patterns (inset, stack, inline)
- List all spacing values in rem and px

#### Layout & Grid
- **Grid systems**: Number of columns, column widths
- **Gutters**: Space between columns
- **Container widths**: Max-width at each breakpoint
- **Breakpoints**: Extract responsive breakpoint definitions
  - Mobile (sm): XXXpx
  - Tablet (md): XXXpx
  - Laptop (lg): XXXpx
  - Desktop (xl): XXXpx
  - Wide (2xl): XXXpx
- **Layout patterns**: Flex, grid, single-column, sidebar layouts

#### Shadows & Elevation
- Extract all box-shadow definitions
- Categorize by elevation level (2xs, xs, sm, md, lg, xl, 2xl)
- Document CSS shadow values exactly
- Note which components use which shadows
- Include drop-shadow filters if used

#### Border Radius
- Extract all border-radius values
- List as tokens (none, sm, md, lg, xl, 2xl, full)
- Document which components use which radius
- Note corner-specific radius if used

#### Borders
- Border widths (1px, 2px, 4px, 8px)
- Border styles (solid, dashed, dotted)
- Border colors and when they're used

#### Z-Index Layering
- Extract all z-index values used
- Create z-index scale/system if present
- Document layering hierarchy:
  - Base content: z-index 0-9
  - Dropdowns/Popovers: z-index 10-99
  - Sticky elements: z-index 100-999
  - Modals/Overlays: z-index 1000-9999
  - Tooltips/Toasts: z-index 10000+
- Note which components use which z-index values

#### Gradients
- Extract all gradient definitions (linear-gradient, radial-gradient)
- Document gradient patterns:
  - Start color, end color, direction
  - Multiple color stops if present
  - Common gradient usages (backgrounds, buttons, icons)

### Step 3: Extract Component Patterns

For EACH component type found, document:

#### Component Structure
- HTML structure and element hierarchy
- CSS classes used
- Tailwind utility patterns

#### Component Variants
- Different visual styles (primary, secondary, ghost, etc.)
- Size variations (xs, sm, md, lg, xl)

#### Component States
- Default/rest state
- Hover state
- Active/pressed state
- Focus state
- Disabled state
- Loading state
- Error state

**Create Component State Matrix**:
For each interactive component, document ALL states in a table format:

| State | Background | Text | Border | Transform | Shadow | Cursor |
|-------|------------|------|--------|-----------|--------|--------|
| Default | [value] | [value] | [value] | none | [value] | pointer |
| Hover | [value] | [value] | [value] | [value] | [value] | pointer |
| Active | [value] | [value] | [value] | [value] | [value] | pointer |
| Focus | [value] | [value] | [value] | [value] | [ring] | pointer |
| Disabled | [value] | [value] | [value] | none | none | not-allowed |

This ensures complete documentation of all visual states.

#### Components to Extract

**Buttons**:
- Extract code for all button variants
- Document class patterns
- Note icon positioning

**Form Elements**:
- Text inputs, textareas, selects
- Checkboxes, radio buttons, toggles
- File uploads
- Label positioning
- Validation states (error, success)
- Helper text patterns

**Cards**:
- Card structure (header, body, footer)
- Card variants (simple, bordered, shadowed)
- Hover effects
- Content patterns

**Navigation**:
- Top navigation bars
- Sidebar navigation
- Breadcrumbs
- Tabs
- Pagination

**Modals & Dialogs**:
- Modal sizes
- Backdrop styles
- Header/body/footer structure
- Close button patterns

**Alerts & Notifications**:
- Alert types (success, error, warning, info)
- Positioning patterns
- Icon usage
- Dismiss buttons

**Tables**:
- Table structure
- Row striping
- Hover states
- Responsive patterns
- Sorting indicators

**Loading States**:
- Spinners
- Skeleton screens
- Progress bars

**Empty States**:
- Icon/illustration
- Messaging
- Call-to-action buttons

**Icons**:
- Icon library used (Lucide, Heroicons, Font Awesome)
- Import method (CDN link)
- Icon sizes used
- Icon color patterns

### Step 4: Extract Interaction Patterns

#### Animations & Transitions
- **Duration scale**: Extract all transition/animation durations
  - Categorize as: extra-fast (100ms), fast (200ms), normal (300ms), slow (500ms), extra-slow (800ms+)
- **Easing functions**: cubic-bezier values, ease, ease-in, ease-out, ease-in-out
- **Animation types**:
  - Fade (opacity)
  - Slide (translateX/Y)
  - Scale (transform scale)
  - Rotate (transform rotate)
  - Blur (filter)
- **Choreography**: Stagger delays for list items
- **Reduced motion**: Check for prefers-reduced-motion support

#### State Transitions
- Hover effects for each component
- Focus indicators (ring, outline)
- Active/pressed visual feedback
- Disabled appearance

### Step 5: Extract Responsive Patterns

- **Mobile-first approach**: Document base mobile styles
- **Breakpoint changes**: How each component adapts
- **Responsive typography**: Font size changes
- **Responsive layout**: Grid columns, flex direction changes
- **Touch targets**: Minimum sizes on mobile
- **Mobile navigation**: Hamburger menus, drawer patterns

### Step 6: Extract Code Conventions

#### Tailwind Patterns
- Class ordering conventions
- Common utility combinations
- Group utilities (group-hover:, group-focus:)
- Arbitrary value usage patterns
- Responsive prefix patterns (sm:, md:, lg:)

#### CSS Custom Properties
- All `:root` variables and their values
- Component-scoped variables
- Theme switching patterns

#### Naming Conventions
- Component class prefixes
- Utility class naming
- BEM patterns if used

### Step 7: Accessibility Features

- **ARIA patterns**: Roles, states, properties found
- **Semantic HTML**: Proper element usage
- **Keyboard navigation**: Focus management, tab order
- **Contrast ratios**: Calculate for text/background combinations
- **Screen reader support**: Alt text, labels, announcements

### Step 8: Extract Theme Configuration

- Complete CSS variables listing from `:root`
- Tailwind config patterns (if visible in code)
- **Dark mode implementation** (if present):
  - Check for `@media (prefers-color-scheme: dark)` rules
  - Check for `.dark` class-based theming
  - Document dark mode color variants
  - Note theme switching JavaScript logic
- Color scheme switching logic
- **CSS Variable Dependencies**: Create a dependency graph showing which variables reference other variables
  - Example: `--primary-foreground` depends on `--primary`

### Step 9: Browser Compatibility Notes

- **OKLCH Color Support**: Note that OKLCH requires modern browsers (Chrome 111+, Safari 15.4+, Firefox 113+)
  - Recommend fallback strategies for older browsers
  - Suggest using color-mix() or CSS custom properties with hex fallbacks
- **CSS Features Used**: Document any modern CSS features that may need fallbacks:
  - CSS Grid, Flexbox, Custom Properties, clamp(), min(), max()
  - Backdrop filters, CSS filters
  - Container queries (if used)
- **JavaScript Dependencies**: Note any polyfills needed

## Output: STYLE_GUIDE.md Structure

Generate a comprehensive markdown file with this exact structure:

```markdown
# UI Design Style Guide

> **Generated**: [Current Date]
> **Analyzed Templates**: [List of HTML files]
> **Version**: 1.0

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Overview](#overview)
3. [Design Tokens](#design-tokens)
   - [Color System](#color-system)
   - [Typography](#typography)
   - [Spacing & Sizing](#spacing--sizing)
   - [Layout & Grid](#layout--grid)
   - [Shadows & Elevation](#shadows--elevation)
   - [Border Radius](#border-radius)
   - [Borders](#borders)
4. [Component Library](#component-library)
   - [Buttons](#buttons)
   - [Form Elements](#form-elements)
   - [Cards](#cards)
   - [Navigation](#navigation)
   - [Modals & Overlays](#modals--overlays)
   - [Alerts & Notifications](#alerts--notifications)
   - [Tables](#tables)
   - [Loading States](#loading-states)
   - [Empty States](#empty-states)
   - [Icons](#icons)
4. [Interaction Patterns](#interaction-patterns)
   - [Animations & Motion](#animations--motion)
   - [Hover States](#hover-states)
   - [Focus States](#focus-states)
   - [Active/Pressed States](#activepressed-states)
   - [Disabled States](#disabled-states)
5. [Responsive Design](#responsive-design)
   - [Breakpoints](#breakpoints)
   - [Mobile-First Patterns](#mobile-first-patterns)
   - [Responsive Typography](#responsive-typography)
   - [Touch Targets](#touch-targets)
6. [Code Patterns & Conventions](#code-patterns--conventions)
   - [Tailwind Patterns](#tailwind-patterns)
   - [CSS Custom Properties](#css-custom-properties)
   - [Naming Conventions](#naming-conventions)
7. [Accessibility](#accessibility)
   - [WCAG Compliance](#wcag-compliance)
   - [ARIA Patterns](#aria-patterns)
   - [Keyboard Navigation](#keyboard-navigation)
   - [Semantic HTML](#semantic-html)
8. [Theme Configuration](#theme-configuration)
   - [CSS Variables Reference](#css-variables-reference)
   - [Tailwind Config](#tailwind-config)
   - [Dark Mode](#dark-mode)
9. [Usage Examples](#usage-examples)
   - [Common Patterns](#common-patterns)
   - [Component Code Examples](#component-code-examples)
   - [Layout Examples](#layout-examples)
10. [Design Insights](#design-insights)
    - [Design Philosophy](#design-philosophy)
    - [Strengths](#strengths)
    - [Recommendations](#recommendations)
11. [Resources & Dependencies](#resources--dependencies)
    - [Required Libraries](#required-libraries)
    - [CDN Links](#cdn-links)
    - [Browser Support](#browser-support)
12. [Migration Guide](#migration-guide)
    - [Applying Styles to New Pages](#applying-styles-to-new-pages)
    - [Component Integration Checklist](#component-integration-checklist)
    - [Common Pitfalls](#common-pitfalls)
13. [Consistency Rules](#consistency-rules)
14. [Quick Reference](#quick-reference)

---

## 1. Executive Summary

Provide a concise 2-3 paragraph summary of the design system's key characteristics and achievements:

**First Paragraph**: Describe the overall design philosophy and approach (e.g., "This professional enterprise workflow management interface demonstrates sophisticated use of modern CSS technologies...")

**Key Achievements** (bullet list):
- ✅ [Number] OKLCH/HEX color tokens for [purpose]
- ✅ [Number] component classes systematically categorized
- ✅ Smooth transitions and animations ([duration range])
- ✅ Responsive [describe layout approach]
- ✅ Full accessibility support (reduced motion, semantic HTML)
- ✅ [Typography approach] with [font family]

---

## 2. Overview

[Brief description of the design system's purpose, visual style, and key characteristics]

**Design Philosophy**: [Describe the overall aesthetic - minimal, neo-brutalist, modern, playful, professional enterprise, etc. - be specific and descriptive]

**Key Features**:
- [Feature 1]
- [Feature 2]
- [Feature 3]

---

## 3. Design Tokens

### 3.1 Color System

#### Color Philosophy

First, describe the overall color approach:
- Color space used (OKLCH, HSL, RGB, HEX)
- Why this approach (e.g., "OKLCH ensures perceptual uniformity")
- Key characteristics (e.g., "All neutrals share hue 264° for color harmony")

#### Primary Brand Colors

| Token | OKLCH Value | HEX Equivalent | RGB Equivalent | Usage |
|-------|-------------|----------------|----------------|-------|
| `--primary` | `oklch(L C H)` | `#XXXXXX` | `rgb(R, G, B)` | Buttons, links, active states, brand identity |
| `--primary-foreground` | `oklch(L C H)` | `#XXXXXX` | `rgb(R, G, B)` | Text on primary backgrounds |

**Color Analysis** (for each primary color):
- **Hue [H]°**: [Describe color family - e.g., "Deep blue in the violet-blue range"]
- **Lightness [L]**: [Describe brightness - e.g., "Mid-range (0.47), ensuring good contrast"]
- **Chroma [C]**: [Describe saturation - e.g., "Moderate saturation (0.18) for professional appearance"]

#### Semantic Color Palette

**Success Colors**:
```css
--success: oklch(L C H);        /* #XXXXXX - [Description] */
--success-light: oklch(L C H);  /* #XXXXXX - [Description] */
```
- **Used for**: Completed tasks, success messages, positive confirmations
- **Lightness progression**: [Base L] → [Light variant L]
- **Color strategy**: [Explain why this color works for success]

**Destructive Colors**:
```css
--destructive: oklch(L C H);              /* #XXXXXX - [Description] */
--destructive-foreground: oklch(L C H);   /* #XXXXXX - [Description] */
```
- **Used for**: Delete actions, error states, critical warnings
- **Higher chroma ([C])** for attention-grabbing effect

**Accent Colors**:
```css
--accent: oklch(L C H);              /* #XXXXXX - [Description] */
--accent-foreground: oklch(L C H);   /* #XXXXXX - [Description] */
--accent-light: oklch(L C H);        /* #XXXXXX - [Description] */
```
- **Used for**: [Specific usage - e.g., "AI message backgrounds, highlights"]
- **Hue [H]°** creates [describe relationship to primary - e.g., "pleasant contrast with primary blue"]

#### Neutral Scale

| Token | OKLCH | HEX | L* | Usage |
|-------|-------|-----|----|-------|
| `--background` | `oklch(L C H)` | `#XXXXXX` | L% | Page background |
| `--card` | `oklch(L C H)` | `#XXXXXX` | L% | Elevated surfaces |
| `--secondary` | `oklch(L C H)` | `#XXXXXX` | L% | Secondary backgrounds |
| `--muted` | `oklch(L C H)` | `#XXXXXX` | L% | Disabled states |
| `--border` | `oklch(L C H)` | `#XXXXXX` | L% | Borders, dividers |
| `--muted-foreground` | `oklch(L C H)` | `#XXXXXX` | L% | Secondary text |
| `--foreground` | `oklch(L C H)` | `#XXXXXX` | L% | Primary text |

**Neutral Strategy**:
- All neutrals share hue [H]° ([describe tint - e.g., "blue-tinted grays"]) for color harmony
- Lightness creates clear hierarchy: [List L values in progression]
- Very low chroma ([C range]) keeps neutrals subtle

#### Gradients

**[Gradient Name/Purpose]**:
```css
background: linear-gradient([direction]deg, #[start] 0%, #[end] 100%);
```
- **Direction**: [degrees]° ([describe - e.g., "diagonal, top-left to bottom-right"])
- **Start**: `#[color]` ([describe color])
- **End**: `#[color]` ([describe color])
- **Usage**: [Where used - e.g., "Agent avatar backgrounds in agent selection panel"]

#### Color Usage Rules
- ✅ **DO**: Use color tokens from the defined palette
- ❌ **DON'T**: Create arbitrary color values
- **Contrast Requirements**: All text must meet WCAG AA (4.5:1 for normal, 3:1 for large)

### 3.2 Typography

#### Font Family

**Primary Font**: [Font Name] ([Source - Google Fonts/System/Other])
```css
--font-sans: '[Font Name]', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
```

**Why [Font Name]**:
- [Reason 1 - e.g., "Designed for screen readability"]
- [Reason 2 - e.g., "Open source, professionally crafted"]
- [Reason 3 - e.g., "Excellent character differentiation"]
- [Reason 4 - e.g., "Wide weight range (300-700)"]

**Import**:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=[Font]:wght@300;400;500;600;700&display=swap" rel="stylesheet">
```

#### Type Scale

**CRITICAL**: Extract the ACTUAL type scale from CSS classes in the template, not theoretical values. Look for:
- Heading classes (`.epic-title`, `.section-title`, `.details-title`)
- Text classes (`.body-text`, `.description`, `.subtitle`, `.caption`)
- Actual `font-size`, `font-weight`, `line-height`, `letter-spacing` values

| Element | Size (rem/px) | Weight | Line Height | Letter Spacing | Color | Usage |
|---------|---------------|--------|-------------|----------------|-------|-------|
| **Epic Title** | [X]rem / [Y]px | 600 | 1.6 | -0.011em | `--foreground` | H1 - Page title |
| **Section Title** | [X]rem / [Y]px | 600 | 1.6 | Normal | `--foreground` | H3 - Card headers |
| **Details Title** | [X]rem / [Y]px | 600 | 1.6 | 0.05em | `--muted-foreground` | Uppercase labels |
| **Body Text** | [X]rem / [Y]px | 400 | 1.6 | Normal | `--foreground` | Main content |
| **Description** | [X]rem / [Y]px | 400 | 1.6 | Normal | `--foreground` | Longer text blocks |
| **Subtitle** | [X]rem / [Y]px | 400 | Normal | Normal | `--muted-foreground` | Secondary info |
| **Small Text** | [X]rem / [Y]px | 400-500 | 1.5 | Normal | varies | Labels, captions |
| **Micro Text** | [X]rem / [Y]px | 400 | 1.5 | Normal | `--muted-foreground` | Timestamps |

**Typography Patterns**:
- Base line-height: **[value]** for readability
- Global letter-spacing: **[value]** for [describe effect - e.g., "modern tightness"]
- Uppercase labels: **[value]** letter-spacing for legibility
- All headings use weight **[value]** ([name - e.g., "semi-bold"])

#### Font Weight Usage

| Weight | CSS Value | Usage |
|--------|-----------|-------|
| **Light** | 300 | [When used - e.g., "Rarely used, reserved for large display text"] |
| **Regular** | 400 | [When used - e.g., "Body text, descriptions, labels, timestamps"] |
| **Medium** | 500 | [When used - e.g., "Buttons, badges, form inputs, emphasized text"] |
| **Semi-bold** | 600 | [When used - e.g., "All headings (H1-H3), section titles"] |
| **Bold** | 700 | [When used - e.g., "Epic title only (H1), strong emphasis"] |

#### Responsive Typography
[Document how font sizes change at breakpoints if responsive scaling is present]

### 3.3 Spacing & Layout

#### Base Spacing Unit

```css
--spacing: [value]rem; /* [value in px]px */
```

All spacing uses **[X]px increments** for visual rhythm and consistency.

#### Spacing Scale

Extract ACTUAL spacing values used in the template from padding, margin, gap properties:

| Multiplier | Value (rem) | Pixels | Common Usage |
|------------|-------------|--------|--------------|
| 1× | [X]rem | [Y]px | [e.g., "Icon gaps, badge dot spacing"] |
| 1.5× | [X]rem | [Y]px | [e.g., "Badge internal gaps"] |
| 2× | [X]rem | [Y]px | [e.g., "Small gaps, breadcrumb separators"] |
| 2.5× | [X]rem | [Y]px | [e.g., "Button padding (vertical), input padding"] |
| 3× | [X]rem | [Y]px | [e.g., "Tab padding, medium gaps, margins"] |
| 4× | [X]rem | [Y]px | [e.g., "Standard gaps, section spacing"] |
| 5× | [X]rem | [Y]px | [e.g., "Card padding, button padding (horizontal)"] |
| 6× | [X]rem | [Y]px | [e.g., "Large gaps, sidebar padding"] |
| 8× | [X]rem | [Y]px | [e.g., "Major section padding"] |

#### Border Radius

**Base Radius**:
```css
--radius: [value]px;
```

**Derived Values**:
- **Small**: `calc(var(--radius) - 2px)` = **[X]px** ([usage - e.g., "badges, pills, small buttons"])
- **Default**: `var(--radius)` = **[Y]px** ([usage - e.g., "buttons, cards, inputs"])
- **Circle**: `50%` ([usage - e.g., "dots, FAB, avatar"])

#### Layout Grid

Extract the ACTUAL layout structure from the template:

**[Grid Type - e.g., "Dynamic 3-Column Grid"]**:
```css
.main-layout {
    display: grid;
    grid-template-columns: [column widths];
    transition: grid-template-columns [duration] ease-out;
}

/* [State variation - e.g., "Chat closed state"] */
.main-layout.[state-class] {
    grid-template-columns: [adjusted columns];
}
```

**Column Structure**:
1. **[Column 1 Name]**: [width] ([description - e.g., "flexible, grows/shrinks"])
2. **[Column 2 Name]**: [width] ([description - e.g., "fixed width"])
3. **[Column 3 Name]**: [width] ([description - e.g., "fixed, collapses to 0px"])

**Responsive Adjustment**:
```css
@media (max-width: [breakpoint]px) {
    .main-layout {
        grid-template-columns: [adjusted columns];
    }
}
```

### 3.4 Shadows & Elevation

#### Shadow Scale

Extract ACTUAL shadow values from CSS variables and component styles:

| Level | Token | Value | Usage |
|-------|-------|-------|-------|
| **Subtle** | `--shadow-sm` | [exact value] | [e.g., "Navigation, breadcrumbs"] |
| **Default** | `--shadow` | [exact value] | [e.g., "Cards at rest"] |
| **Moderate** | `--shadow-md` | [exact value] | [e.g., "Hover states, dropdowns"] |
| **High** | `--shadow-lg` | [exact value] | [e.g., "FAB, modals"] |

**Shadow Strategy**: [Describe approach - e.g., "Two-layer shadows for realistic depth"]

---

## 4. Component Library

**CRITICAL**: For EACH component, provide COMPLETE copy-paste ready code including ALL states (default, hover, active, focus, disabled). Extract from ACTUAL template code, not theoretical examples.

### 4.1 Buttons ([X] Variants)

#### [Variant Name - e.g., "Primary Button"]
```css
.[button-class],
.[other-button-class] {
    padding: [value];                    /* [px comment] */
    background: var(--[token]);
    color: var(--[token]);
    border: [value];
    border-radius: var(--radius);        /* [px comment] */
    font-size: [value];                  /* [px comment] */
    font-weight: [weight];
    cursor: pointer;
    transition: all [duration]s ease-out;
    display: inline-flex;
    align-items: center;
    gap: [value];                        /* [px comment - e.g., "8px between icon and text"] */
}

.[button-class]:hover {
    transform: scale([value]);
    box-shadow: var(--shadow-md);
}

.[button-class]:active {
    transform: scale([value]);
}
```

**HTML Example**:
```html
<button class="[button-class]">
    <i data-lucide="[icon-name]" width="16" height="16"></i>
    [Button Text]
</button>
```

**Usage**: [Describe when to use this button variant]

[Repeat for ALL button variants found - Icon Button, Secondary Button, FAB, etc.]

### 4.2 Cards

Extract ALL card patterns from template with complete HTML structure and CSS.

### 4.3 Forms

Extract ALL form element patterns.

### 4.4 Navigation

Extract navigation patterns.

### 4.5 Modals & Overlays

Extract modal patterns.

### 4.6 Empty States

**IMPORTANT**: Extract empty state patterns with complete structure:

```css
.empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: [value];
    text-align: center;
    border: [value] dashed var(--border);
    border-radius: var(--radius);
    background: var(--background);
    margin-top: [value];
}
```

---

## 5. Animations & Transitions

### 5.1 Transition Timing

Extract ACTUAL transition durations from component styles:

| Duration | Easing | Usage |
|----------|--------|-------|
| [X]s | ease-out | [e.g., "Buttons, tabs, inputs, small elements"] |
| [Y]s | ease-out | [e.g., "Cards, medium elements"] |
| [Z]s | ease-out | [e.g., "Sidebars, grid layout changes"] |

**Default Pattern**: `transition: all [X]s ease-out;`

### 5.2 Keyframe Animation

Extract ALL keyframe animations found:

```css
@keyframes [animationName] {
    from {
        opacity: [value];
        transform: [value];
    }
    to {
        opacity: [value];
        transform: [value];
    }
}

.[target-class] {
    animation: [animationName] [duration]s ease-out;
}
```

### 5.3 Transform Patterns

Extract ACTUAL transform values used:

**Scale** (Buttons):
- Hover: `scale([value])` ([describe - e.g., "+2%"])
- Active: `scale([value])` ([describe - e.g., "-2%"])
- [Other]: `scale([value])` ([describe])

**Translate** (Cards):
- Hover: `translateY([value])` ([describe - e.g., "lift up"])
- [Other movement]: `translateX([value])` ([describe])

**Rotate**:
- [Component]: `rotate([value]deg)` ([describe])

---

## 6. Responsive Design

### 6.1 Breakpoint

Extract ACTUAL breakpoints from media queries:

```css
@media (max-width: [X]px) {
    /* [describe changes] */
}
```

**Changes at [X]px**:
- [Component 1]: [old value] → [new value]
- [Component 2]: [old value] → [new value]

### 6.2 Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
    * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
    }
}
```

---

## 7. Accessibility

### 7.1 WCAG Compliance

✅ **Color Contrast**: All text meets WCAG AA standards (4.5:1 minimum)
✅ **Focus States**: Visible [X]px focus rings on all interactive elements
✅ **Semantic HTML**: Proper use of `<nav>`, `<main>`, `<aside>`, heading hierarchy
✅ **Reduced Motion**: Respects `prefers-reduced-motion` preference
✅ **Icon Labels**: All icons paired with text labels

---

## 8. Code Patterns & Conventions

[Document patterns found in the template]

---

## 9. Usage Examples

Extract complete, copy-paste ready code for common UI patterns from the template.

---

## 10. Design Insights

### 10.1 Design Philosophy

**[Style Name]** ([describe - e.g., "Professional Enterprise"]) with [characteristics]:
- [Characteristic 1 - e.g., "Clean layouts with generous whitespace"]
- [Characteristic 2 - e.g., "Subtle color palette (low chroma neutrals)"]
- [Characteristic 3 - e.g., "Smooth micro-interactions"]
- [Characteristic 4 - e.g., "Task-oriented information hierarchy"]

### 10.2 Strengths

✅ **[Strength 1]**: [Explanation - e.g., "OKLCH Color Space ensures consistent visual weight"]
✅ **[Strength 2]**: [Explanation - e.g., "Systematic spacing creates visual rhythm"]
✅ **[Strength 3]**: [Explanation - e.g., "Transform-based interactions are hardware-accelerated"]
✅ **[Strength 4]**: [Explanation - e.g., "Accessibility-first with focus rings and semantic HTML"]

### 10.3 Recommendations

**Potential Enhancements**:
1. [Recommendation 1 - e.g., "Add explicit disabled button states"]
2. [Recommendation 2 - e.g., "Document hover states systematically in component matrix"]
3. [Recommendation 3 - e.g., "Create dark mode color variants"]
4. [Recommendation 4 - e.g., "Formalize type scale into named tokens"]

---

## 11. Resources & Dependencies

### 11.1 Required Libraries

- **Tailwind CSS**: [version/CDN]
- **Icon Library**: [library name and CDN]
- **Fonts**: [Google Fonts links]
- **Other**: [Any other frameworks]

### 11.2 CDN Links

```html
<!-- Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="[Google Fonts URL from template]" rel="stylesheet">

<!-- Icons -->
<script src="[icon library CDN]"></script>
```

### 11.3 Browser Support

- **OKLCH Colors**: Requires modern browsers (Chrome 111+, Safari 15.4+, Firefox 113+)
  - Consider fallbacks for older browsers
- **CSS Custom Properties**: Widely supported (IE 11 needs fallback)
- **CSS Grid/Flexbox**: Modern browser support required

---

## 12. Migration Guide

### 12.1 Applying Styles to New Pages

**Step 1: Include Required Dependencies**
```html
<head>
    <!-- Fonts - MUST include preconnect for performance -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="[Google Fonts URL from template]" rel="stylesheet">

    <!-- Icons -->
    <script src="[Icon library CDN]"></script>
</head>
```

**Step 2: Copy CSS Variables**
- Copy the complete `:root` CSS variables block to your page's `<style>` or external stylesheet
- Ensure all custom properties are available globally
- **CRITICAL**: Verify all color tokens include both OKLCH and fallback HEX values if targeting older browsers

**Step 3: Copy CSS Reset & Base Styles**
```css
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: var(--font-sans) !important;
    background: var(--background) !important;
    color: var(--foreground) !important;
    line-height: [value] !important;
    letter-spacing: [value];
}
```

**Step 4: Include Component Styles**
- Copy ONLY the CSS for components you're using
- Maintain class naming consistency
- **CRITICAL**: Preserve the COMPLETE state definitions (hover, focus, active, disabled)
- Include inline comments showing px values for clarity

**Step 5: Initialize Icon Library**
```html
<script>
    // At end of <body>, after DOM is ready
    lucide.createIcons(); // or equivalent for your icon library
</script>
```

### 12.2 Component Integration Checklist

When adding a component to a new page:

- [ ] Copy the exact HTML structure from the style guide
- [ ] Copy the complete CSS for that component (including all states)
- [ ] Verify all CSS custom properties referenced by the component are defined
- [ ] Test all interactive states (hover, focus, active, disabled)
- [ ] Check responsive behavior at all breakpoints
- [ ] Verify icons are initializing correctly
- [ ] Test keyboard navigation and accessibility

### 12.3 Common Pitfalls

**❌ Pitfall**: Copying only the default state CSS
**✅ Solution**: Always copy hover, focus, active, and disabled states

**❌ Pitfall**: Using similar but not exact color values
**✅ Solution**: Always use the CSS custom property tokens (e.g., `var(--primary)`)

**❌ Pitfall**: Forgetting to initialize icon library
**✅ Solution**: Call `lucide.createIcons()` after DOM is ready

**❌ Pitfall**: Missing the preconnect for Google Fonts
**✅ Solution**: Always include `<link rel="preconnect">` for faster font loading

**❌ Pitfall**: Modifying spacing values arbitrarily
**✅ Solution**: Use only spacing values from the defined scale

**❌ Pitfall**: Creating new shadow patterns
**✅ Solution**: Use only shadows from the elevation scale (--shadow-sm, --shadow, etc.)

**❌ Pitfall**: Using OKLCH colors without browser compatibility check
**✅ Solution**: Include HEX fallbacks or test on target browsers

---

## 13. Consistency Rules

### ✅ DO
- Use spacing tokens from the defined scale
- Use colors from the defined palette only
- Stick to the type scale for font sizes
- Use defined shadow levels
- Follow the border radius system

### ❌ DON'T
- Create arbitrary spacing values (avoid `p-[13px]`)
- Use random colors outside the palette
- Create custom font sizes not in the type scale
- Mix different shadow patterns inconsistently
- Use inconsistent border radius values

---

## 14. Quick Reference

### 14.1 Most Used Colors

```css
--primary: oklch([L] [C] [H]);      /* #[HEX] - [Description] */
--accent: oklch([L] [C] [H]);       /* #[HEX] - [Description] */
--background: oklch([L] [C] [H]);   /* #[HEX] - [Description] */
--foreground: oklch([L] [C] [H]);   /* #[HEX] - [Description] */
--border: oklch([L] [C] [H]);       /* #[HEX] - [Description] */
```

### 14.2 Common Spacing

```css
[X]rem  = [Y]px   /* [Usage - e.g., "Tight gaps"] */
[X]rem  = [Y]px   /* [Usage - e.g., "Medium gaps"] */
[X]rem  = [Y]px   /* [Usage - e.g., "Standard gaps"] */
[X]rem  = [Y]px   /* [Usage - e.g., "Card padding"] */
[X]rem  = [Y]px   /* [Usage - e.g., "Section padding"] */
```

### 14.3 Component Count

- **[X] Buttons**: [list variant names]
- **[X] Cards**: [list card types]
- **[X] Forms**: [list form elements]
- **[X] Navigation**: [list navigation types]
- **[X] Chat/Messages**: [list message components]
- **[X] Layout**: [list layout components]
- **Total**: [X] component classes

---

**End of Style Guide**

*Generated by: Claude Code `/extract-style-guide` command*
*Date: [Current Date]*
*Version: 1.0.0*
```

## Important Instructions for High-Quality Output

### Extraction Principles

1. **Be Comprehensive**: Don't skip sections - document everything found in the template
2. **Extract ACTUAL Values**: Never use placeholder or theoretical values - extract from real CSS
3. **Include Code**: Provide copy-paste ready code examples with ALL states (hover, focus, active, disabled)
4. **Be Accurate**: Extract exact values, colors, sizes from templates - don't make assumptions
5. **Be Consistent**: Use consistent formatting throughout the guide
6. **Be Practical**: Focus on what designers need to create NEW pages with the SAME style

### Critical Requirements

7. **Multi-Format Colors** (CRITICAL):
   - Always include OKLCH (source of truth from template)
   - Always include HEX equivalent (use https://oklch.com/ for conversion)
   - Include RGB if present in template
   - Add color analysis explaining hue/lightness/chroma

8. **Complete Type Scale** (CRITICAL):
   - Extract from ACTUAL CSS classes (`.epic-title`, `.section-title`, etc.)
   - Include rem/px, weight, line-height, letter-spacing, color, usage
   - Document font weight usage patterns

9. **Component Documentation** (CRITICAL):
   - Full CSS code with inline px comments (e.g., `padding: 0.625rem; /* 10px */`)
   - ALL states: default, hover, active, focus, disabled
   - HTML usage examples
   - Usage guidance (when to use this component)

10. **Spacing Scale** (CRITICAL):
    - Extract ACTUAL spacing values used (not theoretical scale)
    - Document common usage for each value
    - Include multiplier system if present

11. **Transform Patterns**:
    - Document ALL transform values (scale, translateX/Y, rotate)
    - Include descriptions (e.g., "scale(1.02) = +2% enlargement")

12. **Design Context**:
    - Add Executive Summary with key achievements
    - Add Design Philosophy description
    - Add Design Insights section (strengths, recommendations)
    - Explain WHY design decisions were made

13. **Gradients**: Extract all gradients with direction, start/end colors, usage

14. **Migration Guide**: Make it actionable with step-by-step checklist

15. **Browser Compatibility**: Note OKLCH support requirements (Chrome 111+, Safari 15.4+, Firefox 113+)

## Quality Checklist

Before finalizing the style guide, verify:

- [ ] Executive Summary includes key achievements and design philosophy
- [ ] All colors have OKLCH + HEX + analysis
- [ ] Type scale extracted from ACTUAL CSS classes (not theoretical)
- [ ] ALL components have complete code examples with ALL states
- [ ] Spacing scale shows ACTUAL values used
- [ ] Transform patterns documented with exact values
- [ ] Shadows documented with usage mapping
- [ ] Gradients extracted with full specifications
- [ ] Migration Guide is actionable and step-by-step
- [ ] Design Insights section explains philosophy, strengths, recommendations
- [ ] Quick Reference includes most-used values
- [ ] Browser compatibility notes included
- [ ] All code examples are copy-paste ready with inline comments

## Output Location

Save the generated style guide to:
- **Default**: `STYLE_GUIDE.md` in project root
- **Alternative**: `.superdesign/STYLE_GUIDE.md` if the `.superdesign/` directory exists

After generation, inform the user:

```
✅ Style guide generated successfully

📄 **Location**: [file path]
📊 **Source**: [number of templates] template file(s) analyzed
📏 **Size**: [file size] KB

🎨 **Extracted**:
   - [X] OKLCH color tokens (with HEX equivalents)
   - [X] component classes systematically categorized
   - [X] keyframe animations
   - Complete type scale
   - Spacing system
   - Shadow elevation scale

✨ **Includes**:
   - Executive Summary
   - Multi-format colors with analysis
   - Complete component code examples (all states)
   - Transform patterns
   - Design Insights & Philosophy
   - Migration Guide
   - Quick Reference

Ready for use in creating consistent UI designs across new pages.
```

Now, please provide the HTML template file path(s) you want to analyze.
