---
name: doc-to-slides
description: >
  Generate a polished PowerPoint slide deck (.pptx) from a source document. Use this skill
  whenever the user uploads or references a Word doc (.docx), plain text, or Markdown file
  and wants to turn it into a presentation, slide deck, or PowerPoint. Triggers include:
  "make slides from this", "create a presentation from this file", "build a deck",
  "turn this into a PowerPoint", "generate slides", or any request to convert a document
  into slides — even phrased casually like "make this a deck" or "can you slidify this?"
  Always use this skill when a document is provided alongside any mention of slides or
  a presentation, even if the user doesn't say "skill" or seem to expect a structured workflow.
---

# Doc-to-Slides Skill

Converts a Word doc (.docx), plain text, or Markdown file into a polished PowerPoint
presentation (.pptx) — with user approval of the outline and style before building.

## Workflow Overview

Always follow these four stages in order. Never skip to building without outline approval.

1. **Read** — Extract content from the source file
2. **Propose** — Present a slide-by-slide outline and wait for approval
3. **Style** — Ask about colors/theme if not already specified
4. **Build** — Generate the .pptx using the PPTX skill

---

## Stage 1: Read the Source File

### Word doc (.docx)

```bash
pip install python-docx --break-system-packages -q
python3 - << 'EOF'
from docx import Document
doc = Document('/mnt/user-data/uploads/yourfile.docx')
for para in doc.paragraphs:
    if para.text.strip():
        print(f"[{para.style.name}] {para.text}")
EOF
```

This surfaces heading hierarchy and body text so you can map document structure to slides.
Also check for tables — they often contain data worth a dedicated slide.

### Plain text / Markdown

```bash
cat /mnt/user-data/uploads/yourfile.md
```

Markdown headings (`#`, `##`, `###`) map naturally to slide titles and sections.

---

## Stage 2: Propose an Outline

Analyze the extracted content and propose a numbered outline. Present it clearly:

```
Here's a proposed outline for your deck (12 slides):

 1. Title Slide       — [Document title] + [Subtitle or author]
 2. Overview / Agenda — High-level topics covered
 3. [Section title]   — Key points from this section
 4. [Section title]   — ...
...
N. Summary            — Key takeaways + closing thought

Would you like to adjust anything before I start building?
```

**Outline rules:**
- **One idea per slide.** Split dense sections rather than cramming bullet points.
- **Minimum 6 slides** (title + content + close). Aim for 8–15 for typical documents.
- Always open with a title slide and close with a summary/takeaways slide.
- If the source has data, comparisons, or processes — plan a visual/chart slide for them.
- If the source is structured (e.g. report with named sections), mirror that structure.

**Wait for the user to approve or request changes before proceeding.**

---

## Stage 3: Confirm Style

If the user has not specified colors, a theme, or a style preference, ask before building:

> "What style are you going for? For example:
> - Brand colors or a hex palette you'd like me to use
> - A mood: professional, bold, minimal, energetic, academic
> - Or describe the audience and I'll suggest something fitting"

**Handling vague answers:**
- "Professional" → Midnight Executive or Charcoal Minimal
- "Bold / energetic" → Coral Energy or Cherry Bold
- "Clean / minimal" → Charcoal Minimal or Sage Calm
- "Nature / environment" → Forest & Moss or Teal Trust
- "You choose" → pick the palette that best fits the document's topic; briefly name it

Always tell the user which palette you're using before building. The color table lives in
the PPTX skill (`/mnt/skills/public/pptx/SKILL.md` → Color Palettes section).

---

## Stage 4: Build the Presentation

Read the PPTX skill for full technical instructions:

```
/mnt/skills/public/pptx/SKILL.md   ← read this before writing any code
```

Use **pptxgenjs** (creating from scratch path). Then follow these content rules:

### Content rules
- Apply the approved color palette consistently across all slides
- Every slide must have a visual element — icon shape, color block, chart, or illustration;
  no text-only slides
- Vary layouts — don't use the same column/bullet layout back-to-back
- Use font pairing and size guidelines from the PPTX skill's Typography section

### Speaker notes
Include speaker notes **only if the user requests them.** When included:
- Write 2–4 sentences per slide
- Expand on the bullet points — say what a presenter would say aloud
- Do not just repeat the slide text verbatim

---

## Stage 5: QA

Run the visual QA steps from the PPTX skill after generating:
1. Convert slides to images
2. Check for text overflow, element overlaps, missing content
3. Fix any issues, re-verify affected slides
4. Present the final `.pptx` to the user with `present_files`
