---
name: frontend-ux-polish
description: Use when improving an existing UI's readability, hierarchy, accessibility, responsiveness, interaction feedback, or motion without changing product intent.
---

# Frontend UX Polish

## Intent

Improve an existing interface while preserving the product workflow and information architecture. The result must be specific enough to implement and verify.

## When to Use

- UI polish, layout density, hierarchy, responsive behavior, interaction states, accessibility, contrast, or motion cleanup.
- Existing screens, components, dashboards, forms, editors, tools, games, or marketing pages.
- Do not use for net-new product strategy or changing the core workflow unless requested.

## Inputs

- `ui_description`: Current layout, user pain points, responsive issues, and hierarchy problems. Example: "Card-based dashboard; cards stack on mobile but horizontal scroll on 768-1024px tablets; primary metrics buried."
- `constraints`: WCAG level, brand palette, CSS framework, max animation duration, supported browsers. Example: "WCAG AA, Material 3, Tailwind CSS, 200ms max animation, Chrome 90+, iOS 13+."

## Surface Types

Classify the UI before proposing polish. A dashboard, editor, and marketing page need different density and visual rules.

| Surface | Primary Goal | Polish Priorities | Avoid |
|---------|--------------|-------------------|-------|
| Dashboard/ops tool | Scan, compare, act repeatedly | Density, hierarchy, table/card balance, filters, status states | Oversized hero blocks and decorative cards |
| Form/settings | Accurate input and recovery | Labels, grouping, validation, focus order, error placement | Hiding required context behind motion |
| Editor/canvas/tool | Direct manipulation | Toolbars, selection states, keyboard flow, stable dimensions | Layout shift from labels or hover states |
| Commerce/content | Evaluate item and decide | Media clarity, comparison, price/spec hierarchy, trust signals | Cropped/atmospheric assets when inspection matters |
| Game/interactive | Immediate feedback and play loop | Controls, hit targets, motion feedback, responsive canvas | Static explanatory screens as first experience |
| Marketing/hero | Understand offer quickly | First-viewport signal, media relevance, conversion path | Generic gradient/SVG hero with no real subject |

## Audit Dimensions

| Dimension | Concrete Checks |
|-----------|-----------------|
| Hierarchy | Primary task visible first, secondary actions subdued, headings fit surface density |
| Layout | Grid tracks, min/max widths, overflow, wrapping, stable dimensions, no overlap |
| Typography | Type scale, line height, weight contrast, no viewport-width font scaling |
| Color/contrast | WCAG target, semantic color use, disabled/error/success states |
| Interaction | Hover/focus/active/disabled/loading states, hit targets, keyboard path |
| Responsiveness | Mobile/tablet/desktop breakpoints, orientation, safe areas, content reflow |
| Motion | State-change purpose, duration/easing, reduced-motion equivalent |
| Assets | Real product/place/person/gameplay images when inspection matters |

## Instructions

1. Classify surface type using `Surface Types` and state the primary user task.
2. Identify the top three information priorities and preserve that order in the proposed layout.
3. Audit each relevant `Audit Dimension`; skip dimensions only when they truly do not apply.
4. Define concrete layout rules: grid/flex behavior, min/max widths, touch target size, overflow handling, sticky/fixed behavior, and breakpoint behavior for mobile, tablet, and desktop.
5. Define accessibility requirements: WCAG target, contrast ratios, visible focus, semantic labels, reduced motion, keyboard reachability, and error messaging.
6. Use motion only for state changes, feedback, or continuity. Specify duration/easing and reduced-motion behavior.
7. Keep visual style consistent with the existing design system. If no system exists, choose a small palette and type scale with explicit token names.
8. Provide verification steps: viewport sizes, contrast checks, keyboard path, screen-reader label checks when relevant, and regression risks.

## Output Standard

- Include `Surface Classification`, `Priority Order`, and `Audit Findings`.
- Recommendations must name selectors, components, tokens, or layout regions when known.
- Include measurable values for spacing, font sizes, breakpoints, contrast, animation duration, and hit targets.
- Include a `Do Not Change` note for product intent, data model, or workflow boundaries.
- Do not suggest decorative gradients, oversized hero treatments, or card-heavy redesigns unless they fit the existing product and task.
- Do not say "make it cleaner" without implementation-level details.

## Examples

Input: Card-based dashboard; cards stack on mobile but horizontal scroll on 768-1024px; primary metrics buried. Constraints: WCAG AA, Tailwind, 200ms max animation.

Output: Typography: bump heading from 1.25rem to 1.5rem, body stays 1rem (contrast ratio 4.8:1 verified). Spacing: adopt 8px grid, cards get 16px gap. Layout: <=768px single column, 769-1024px 2-col grid (no scroll), >=1025px 3-col. Motion: 150ms fade-in for primary metric cards on mount, respect prefers-reduced-motion. Hierarchy: primary metrics pinned top row with accent border-left.
