# Frontend UX Polish

## Intent

Improve UI readability, hierarchy, motion, and responsiveness without changing product intent.

## Inputs

- `ui_description`: Current layout, user pain points, responsive issues, and hierarchy problems. Example: "Card-based dashboard; cards stack on mobile but horizontal scroll on 768-1024px tablets; primary metrics buried."
- `constraints`: WCAG level, brand palette, CSS framework, max animation duration, supported browsers. Example: "WCAG AA, Material 3, Tailwind CSS, 200ms max animation, Chrome 90+, iOS 13+."

## Instructions

1. Audit typography, spacing rhythm, and visual hierarchy.
2. Suggest a coherent color and contrast strategy that meets the specified WCAG level.
3. Add meaningful motion only for state transitions — not decorative. Respect prefers-reduced-motion.
4. Ensure layout quality on both mobile and desktop breakpoints.
5. Verify contrast ratios meet target accessibility standard.

## Examples

Input: Card-based dashboard; cards stack on mobile but horizontal scroll on 768-1024px; primary metrics buried. Constraints: WCAG AA, Tailwind, 200ms max animation.

Output: Typography: bump heading from 1.25rem to 1.5rem, body stays 1rem (contrast ratio 4.8:1 verified). Spacing: adopt 8px grid, cards get 16px gap. Layout: <=768px single column, 769-1024px 2-col grid (no scroll), >=1025px 3-col. Motion: 150ms fade-in for primary metric cards on mount, respect prefers-reduced-motion. Hierarchy: primary metrics pinned top row with accent border-left.
