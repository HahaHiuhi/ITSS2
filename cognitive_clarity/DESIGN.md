---
name: Cognitive Clarity
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#464554'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#767586'
  outline-variant: '#c7c4d7'
  surface-tint: '#494bd6'
  primary: '#4648d4'
  on-primary: '#ffffff'
  primary-container: '#6063ee'
  on-primary-container: '#fffbff'
  inverse-primary: '#c0c1ff'
  secondary: '#5c5f61'
  on-secondary: '#ffffff'
  secondary-container: '#e0e3e5'
  on-secondary-container: '#626567'
  tertiary: '#b10e6b'
  on-tertiary: '#ffffff'
  tertiary-container: '#d23284'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e1e0ff'
  primary-fixed-dim: '#c0c1ff'
  on-primary-fixed: '#07006c'
  on-primary-fixed-variant: '#2f2ebe'
  secondary-fixed: '#e0e3e5'
  secondary-fixed-dim: '#c4c7c9'
  on-secondary-fixed: '#191c1e'
  on-secondary-fixed-variant: '#444749'
  tertiary-fixed: '#ffd9e4'
  tertiary-fixed-dim: '#ffb0cd'
  on-tertiary-fixed: '#3e0022'
  on-tertiary-fixed-variant: '#8c0053'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-max: 800px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
---

## Brand & Style

The design system is anchored in the philosophy of "Deep Work"—reducing cognitive load to foster focus and efficiency. The style is **Minimalist** with a **Corporate Modern** edge, prioritizing utility over decoration. 

The aesthetic is characterized by expansive whitespace, a restrained color palette, and high-precision typography. It seeks to evoke a sense of calm control, turning the chaotic nature of task management into a structured, rhythmic experience. Elements should feel intentional and lightweight, never overwhelming the user's primary focus: their work.

## Colors

This design system utilizes a high-clarity light mode palette to maximize readability. 

- **Primary (#6366F1):** An energetic Indigo used for primary actions, active states, and brand identifiers. It represents focus and momentum.
- **Secondary (#F8FAFC):** A very soft slate-gray used for background surfaces and structural grouping, providing a subtle contrast against white task cards.
- **Tertiary (#EC4899):** A vibrant pink reserved exclusively for "High Priority" indicators or urgent alerts.
- **Neutral (#64748B):** A balanced gray for secondary text and icons, ensuring hierarchy without competing with the content.

Priority levels should be represented by subtle semantic accents:
- **High:** Tertiary Pink.
- **Medium:** Primary Indigo.
- **Low:** Neutral Slate.

## Typography

The typography utilizes **Inter** for all roles, leveraging its systematic and neutral characteristics to maintain a professional, tool-like feel. 

- **Hierarchical Scale:** Large headlines are reserved for section titles (e.g., "Today" or "Upcoming"). 
- **Task Titles:** Use `title-lg` for primary task names to ensure they are the first thing a user scans.
- **Details & Metadata:** Descriptions and dates use `body-md` and `label-sm` to maintain a clear visual separation from the task title.
- **Caps & Tracking:** Labels (like task tags or priority badges) should use uppercase with increased letter spacing for distinct readability at small sizes.

## Layout & Spacing

This design system uses a **Fixed Grid** approach for productivity, centering the content to minimize eye strain. 

- **Main Column:** On desktop, the task list is constrained to a maximum width of 800px to maintain optimal line lengths for reading.
- **The 8px Grid:** All spacing between elements (paddings, margins) must be increments of 8px. Use `stack-md` (12px) for spacing within a task item and `stack-lg` (24px) for spacing between logical groups of tasks.
- **Mobile Adaptivity:** On mobile, margins reduce to 16px. Interactive elements like checkboxes and "Add Task" buttons must maintain a minimum hit target of 44px regardless of visual size.

## Elevation & Depth

To maintain a clean, "flat-ish" aesthetic, depth is communicated through **Tonal Layers** and **Low-contrast Outlines** rather than heavy shadows.

- **Background:** Uses the Secondary color (`#F8FAFC`).
- **Surface (Cards):** Individual tasks or modules are pure white (`#FFFFFF`) with a subtle 1px border (`#E2E8F0`).
- **Active State Elevation:** When a task is being edited or dragged, apply a very soft ambient shadow (Blur: 12px, Y: 4px, Color: `rgba(100, 116, 139, 0.08)`) to lift it from the stack.
- **Glassmorphism:** Use a subtle backdrop blur on top navigation bars or floating action button backgrounds to maintain context of the list scrolling beneath.

## Shapes

The design system uses a **Rounded** (Level 2) shape language to balance the professional tone with approachable usability. 

- **Standard Elements:** Buttons, input fields, and task cards use a 0.5rem (8px) radius.
- **Large Containers:** Modals or side panels use 1rem (16px) for a more modern, integrated feel.
- **Interactive Indicators:** Checkboxes transition from a rounded-square (4px radius) to a fully filled state upon completion.

## Components

### Buttons
- **Primary:** Solid `#6366F1` with white text. High contrast, 8px radius.
- **Ghost:** Transparent background with `#64748B` text, turning into a light gray background on hover. Used for secondary actions like "Cancel" or "Add Subtask".

### Task List Items
- A horizontal layout: Checkbox on the left, followed by the task title and description, with metadata (tags/date) on the right or tucked underneath.
- **Hover State:** The background should shift slightly or the 1px border should darken to `#CBD5E1`.

### Checkboxes
- Circular or slightly rounded squares. When checked, the border and background animate to the Primary color with a white checkmark. The associated task text should strike through and dim to Neutral color.

### Input Fields
- Minimalist style: No heavy borders. Use a subtle bottom border or a light gray fill. On focus, the border transitions to Primary Indigo.

### Priority Chips
- Small, uppercase labels with a very light background tint of the priority color (e.g., light pink for high priority) and dark text of the same hue.

### Progress Indicators
- Thin, 4px tall bars using a neutral background and Primary Indigo for the fill, showing percentage of completion for task lists.