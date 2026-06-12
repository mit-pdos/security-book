# LaTeX → Quarto chapter conversion spec (6.1600 book)

Convert `lectures/lecXX.tex` → `chapters/lecXX.qmd`. Preserve ALL content and
its order. Do not paraphrase, drop, or "improve" prose. Keep LaTeX math
verbatim inside `$…$` / `$$…$$`.

## File skeleton

```
# Chapter Title {#sec-CHAPID}

{{< include /macros/_macros.qmd >}}

…converted body…
```

Use `{#sec-CHAPID}` on the `#` heading ONLY for the two chapters that had
labels: lec06 (`chap:rsa` → `{#sec-rsa}`), lec04 (`lec:mac` → `{#sec-mac}`).
Other chapters: plain `# Title`.

## Construct mapping

| LaTeX | Quarto |
|---|---|
| `\chapter{T}` | `# T` |
| `\section{T}` | `## T` (append `{#sec-…}` if it has a `\label`) |
| `\subsection{T}` | `### T` |
| `\subsubsection{T}` / `\paragraph{T}` | bold run-in at paragraph start: `**T.** ` (the original book renders both as run-in paragraph headings, not display headings) |
| `\textquote{x}` | "x" (curly quotes) |
| `\begin{definition}…\end{definition}` (also `defn` env) | `::: {#def-SLUG}` newline body newline `:::`; if the env has a bracket title `[Name]`, put `## Name` as first line inside the div |
| `\begin{theorem}[Name]` | `::: {#thm-SLUG}` newline `## Name` (only if bracket title) newline body `:::` |
| `\begin{lemma}` | `::: {#lem-SLUG}` … `:::` |
| `\begin{remark}` | `::: {#rem-SLUG}` … `:::` |
| `\begin{claim}` (unnumbered) | paragraph starting `**Claim.** ` |
| `\begin{proof}` … `\end{proof}` | `::: {.proof}` … `:::` (omit `\qed`) |
| `\cref{L}`, `\Cref{L}`, `\ref{L}` | `@new-id` from the label map below |
| `\autocite{K}` | `[@K]` |
| `\autocite[p.~7]{K}` | `[@K, p. 7]` |
| `\cite{K}` | `[@K]` |
| `\sidenote{TEXT}` | `^[TEXT]` (inline footnote; renders in margin) |
| `\footnote{TEXT}` | `^[TEXT]` |
| `\marginnote{TEXT}` | `::: {.column-margin}` TEXT `:::` placed as its own block right after the paragraph containing it |
| `\begin{marginfigure}` | `![CAPTION](/figs/NAME.svg){#fig-SLUG .column-margin}` |
| `\begin{figure}` + `\includegraphics[width=0.X\textwidth]{figs/NAME.pdf}` + `\caption{C}\label{fig:L}` | `![C](/figs/NAME.svg){#fig-L width=X0%}` |
| tikz figure in lec03 | `![caption](/figs/merkle-damgard.svg){#fig-merkle-damgard}` and `![caption](/figs/merkle-damgard-extension.svg){#fig-merkle-damgard-extension}` |
| tikz figure in lec04 (CBC-MAC, empty `\label{fig:}`) | `![The CBC-MAC construction.](/figs/cbc-mac.svg){#fig-cbc-mac}` |
| forest figure in lec05 (`fig:lamport_tree`) | `![caption](/figs/lamport-tree.svg){#fig-lamport-tree}` |
| `\begin{lstlisting}[language=C]` | fenced block ```` ```c ```` (languages used: c, python, sh, html; lowercase) |
| `\begin{lstlisting}[language=C, numbers=left]` | ```` ```{.c code-line-numbers="true"} ```` |
| `\begin{lstlisting}` (no language) | plain ```` ``` ```` fence |
| `\begin{verbatim}` | plain ```` ``` ```` fence |
| verbatim ASCII diagram inside `\begin{figure}` with `\caption` (lec20/lec21) | `::: {#fig-SLUG}` newline fence with diagram newline blank line CAPTION newline `:::` |
| `framed`/pseudocode inside a `\begin{figure}` | NO callout inside figure divs (it breaks PDF rendering) — put the pseudocode/content as plain paragraphs+lists inside `::: {#fig-SLUG}`, caption as last paragraph |
| `\begin{tabular}` | pipe table (grid table if cells hold multiple lines); if it had `\caption`+`\label{tab:L}`, put caption below as `: Caption {#tbl-L}` |
| `\begin{framed}` | `::: {.callout-note appearance="simple" icon=false}` … `:::` |
| `\begin{quote}` | `>` blockquote |
| `\begin{itemize}` / `\begin{enumerate}` | `-` / `1.` `2.` … lists (preserve nesting; `\item[X]` → `- **X** `) |
| `\begin{align*}`, `\[…\]` with `aligned` | `$$\begin{aligned}…\end{aligned}$$` (keep `&` and `\\`) |
| `\begin{equation}\label{eq:L}` or `align` with label | `$$ … $$ {#eq-L}` |
| `\[ … \]` | `$$ … $$` |
| `\emph{x}`, `\textit{x}` | `*x*` |
| `\textbf{x}` | `**x**` |
| `\texttt{x}`, `\ttt{x}` | `` `x` `` |
| `\url{x}` | `<x>` |
| `\todo{X}`, `\hcg{X}` | `[**TODO:** X]{.todo}` (keep visible; `\hcg` → `**TODO (HCG):** X` inside) |
| `` ``x'' `` | "x" (curly quotes) |
| `---` / `--` | `---` / `--` (pandoc smart handles them; leave as-is) |
| `~` (non-breaking space) | plain space |
| `\aa{}` in `Damg\aa{}rd` | å (UTF-8: Damgård) |
| `\&`, `\%`, `\$`, `\_`, `\#` | `&`, `%`, `$`, `_`, `#` (plain UTF-8 in prose) |
| `%`-comment lines | drop (but if they contain real commented-out content, drop silently) |

Inline math `$…$` stays untouched. Macros from latexdefs.tex stay as-is in
math (they're defined for both formats); EXCEPT text-mode usages outside math
of `\ttt`/`\texttt` (→ backticks).

## Theorem-div slugs

Use the label when present (map below). For unlabeled theorem-family envs,
invent a short content-based slug, e.g. `::: {#thm-prg-implies-owf}`.

## Label map (old → new)

| old | new |
|---|---|
| chap:rsa | sec-rsa |
| lec:mac | sec-mac |
| def:crhf | def-crhf |
| def:mac-sec | def-mac-sec |
| def:owf | def-owf |
| def:sig-once | def-sig-once |
| def:sig-sec | def-sig-sec |
| def:signatures_random_security | def-signatures-random-security |
| defn:cca | def-cca |
| defn:cdh | def-cdh |
| defn:cpa | def-cpa |
| defn:ddh | def-ddh |
| defn:prf | def-prf |
| eq:lamport | eq-lamport |
| eq:time | eq-time |
| fig: (empty, lec04) | fig-cbc-mac |
| fig:auth-active | fig-auth-active |
| fig:auth-attacks | fig-auth-attacks |
| fig:auth-direct | fig-auth-direct |
| fig:auth-eaves | fig-auth-eaves |
| fig:buggy | fig-buggy |
| fig:codec | fig-codec |
| fig:lamport_tree | fig-lamport-tree |
| fig:md | fig-md |
| fig:merkle-damgard | fig-merkle-damgard |
| fig:merkle-damgard-extension | fig-merkle-damgard-extension |
| fig:ntp | fig-ntp |
| fig:packet | fig-packet |
| fig:taint | fig-taint |
| lemma:inv | lem-inv |
| sec:dh | sec-dh |
| sec:dp:defn | sec-dp-defn |
| sec:enc:ctr | sec-enc-ctr |
| sec:enc:gcm | sec-enc-gcm |
| sec:fact | sec-fact |
| sec:fact:bg | sec-fact-bg |
| sec:hvzk | sec-hvzk |
| sec:intro:xcode | sec-intro-xcode |
| sec:lamport | sec-lamport |
| sec:lec8:weakenc | sec-lec8-weakenc |
| sec:mac:cw | sec-mac-cw |
| sec:overflow:nx | sec-overflow-nx |
| sec:sig | sec-sig |
| sec:sig:manytime | sec-sig-manytime |
| sec:split:codec | sec-split-codec |
| sec:zkdefn | sec-zkdefn |
| tab:isolationtypes | tbl-isolationtypes |
| tab:sig_schemes | tbl-sig-schemes |
| thm:euler | thm-euler |
| tab:exp-work, tab:exp-probability | commented out in source; drop |

Cross-chapter references are expected (e.g. lec03 refs `sec-intro-xcode` in
lec01); rendering a single chapter alone will warn about them — that's fine,
verify the target id against this map instead.

## Per-chapter verification (run after writing the .qmd)

1. `quarto render chapters/lecXX.qmd --to html` completes; only acceptable
   warnings are unresolved refs to OTHER chapters' ids that match the map.
2. Residue check — this must print nothing:
   `command grep -nE '\\\\(cref|Cref|ref\{|cite|autocite|marginnote|sidenote|footnote|emph|textit|textbf|texttt|ttt|url|chapter|section\{|subsection|item |begin\{(itemize|enumerate|figure|framed|quote|verbatim|lstlisting|definition|theorem|lemma|claim|remark|proof|tabular|center)\})' chapters/lecXX.qmd`
3. Sanity counts vs the source .tex: number of figures, code fences
   (lstlisting+verbatim), margin notes/sidenotes, display-math blocks, and
   section headings should match.
