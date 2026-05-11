# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

Compile the resume with:
```bash
pdflatex resume.tex
```

For the updated/executive-positioned variant:
```bash
cd updated && pdflatex resume.tex
```

No dependencies beyond a standard LaTeX distribution with `fancyhdr`, `titlesec`, `enumitem`, `hyperref`, `sourcesanspro`, and `xcolor` packages.

## Architecture

This is a LaTeX resume based on the [TLCresume template](https://www.overleaf.com/latex/templates/data-science-tech-resume-template/zcdmpfxrzjhv). Two variants exist:

- **Root (`resume.tex`)** — current working resume (Data Scientist / Statistician positioning)
- **`updated/`** — reframed for Senior Director-level roles; uses `../TLCresume.sty` and `../_header.tex` via relative paths

### Key files

| File | Purpose |
|------|---------|
| `resume.tex` | Main document; defines contact info macros and includes sections |
| `_header.tex` | Page header layout (fancyhdr); uses macros from `resume.tex` |
| `TLCresume.sty` | Style package: fonts, margins, colors, custom environments (`zitemize`, `\subtext`, `\skills`) |
| `sections/*.tex` | Modular content: objective, skills, experience, education, activities |
| `feedback.md` | Positioning feedback for executive-level roles (informs `updated/` variant) |

### Custom commands (defined in TLCresume.sty)

- `\skills{text}` — bold formatting for skill names
- `\subtext{text}` — italic subheading (company/location line)
- `zitemize` environment — tighter itemize for bullet points

### Color

The highlight color (`{61, 90, 128}`) is used for section rules, links, and the role title. Change it in `TLCresume.sty`.

## Workflow notes

- The `updated/` directory mirrors the `sections/` structure but with rewritten content targeting senior leadership positioning per `feedback.md`.
- ATS compatibility: avoid active hyperlinks in final PDFs for older applicant tracking systems (print-to-PDF to flatten).
- Resume should stay at 1–2 pages maximum.
