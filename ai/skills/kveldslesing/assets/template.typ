// Phone-shaped dark pages for reading in bed: the page matches a phone screen,
// so fit-to-width gives large text without zooming or sideways scrolling.
#let bg = rgb("#1b1a18")
#let fg = rgb("#d8d0c2")
#let muted = rgb("#968e80")
#let accent = rgb("#d9a75f")
#let panel = rgb("#262420")
#let rule = rgb("#3a3731")

#let horizontalrule = align(center, block(above: 1.4em, below: 1.4em, text(fill: muted, size: 10pt)[#sym.ast.op #h(0.8em) #sym.ast.op #h(0.8em) #sym.ast.op]))
#let horizontalRule = horizontalrule
#let divider() = horizontalrule

#set document(title: [$title$])
#set page(
  width: 90mm,
  height: 190mm,
  margin: (x: 6mm, top: 8mm, bottom: 11mm),
  fill: bg,
  footer: context align(center, text(size: 8pt, fill: muted, counter(page).display("1 / 1", both: true))),
)
#set text(font: "Noto Serif", size: 11pt, fill: fg, lang: "$if(lang)$$lang$$else$nb$endif$", hyphenate: true)
#set par(justify: false, leading: 0.72em, spacing: 1.05em)
#set strong(delta: 200)
#show strong: set text(fill: rgb("#ece4d6"))
#show emph: set text(fill: rgb("#e3dacb"))
#show link: set text(fill: accent)
#show math.equation: set text(font: "New Computer Modern Math", fill: fg)

#set raw(theme: none)
#show raw: set text(font: "DejaVu Sans Mono", size: 8.5pt, fill: rgb("#e6d3ad"))
#show raw.where(block: true): it => block(
  width: 100%, fill: panel, inset: (x: 7pt, y: 6pt), radius: 3pt, breakable: true, it,
)
#show raw.where(block: false): box.with(fill: panel, inset: (x: 2pt), outset: (y: 2pt), radius: 2pt)

#set list(indent: 0.2em, body-indent: 0.5em, marker: text(fill: accent)[•])
#set enum(indent: 0.2em, body-indent: 0.5em)
#set terms(hanging-indent: 1em, separator: [: ])

#show heading: set text(font: "Noto Sans", weight: "semibold", fill: accent, hyphenate: false)
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  block(above: 0.4em, below: 1em, sticky: true, text(size: 16pt, it.body))
}
#show heading.where(level: 2): it => block(above: 1.6em, below: 0.8em, sticky: true, text(size: 13pt, it.body))
#show heading.where(level: 3): it => block(above: 1.3em, below: 0.6em, sticky: true, text(size: 11.5pt, it.body))

// Blockquotes carry analogies and side notes, so they get a quiet panel instead of italics.
#show quote.where(block: true): it => block(
  width: 100%, fill: panel, inset: (left: 9pt, right: 7pt, y: 7pt), radius: 3pt,
  stroke: (left: 2pt + accent), breakable: true, it.body,
)

#set table(inset: 5pt, stroke: 0.5pt + rule)
#show table: set text(size: 9.5pt)
#show figure.where(kind: table): set block(breakable: true)
#show figure.caption: set text(size: 9pt, fill: muted)

// Figures arrive at arbitrary sizes, so fit each inside the text width and a height cap.
#let img(path, caption: none) = align(center, block(above: 1em, below: 1em, breakable: false, layout(size => {
  let natural = measure(image(path))
  let scale = calc.min(1, size.width / natural.width, 9cm / natural.height)
  image(path, width: natural.width * scale)
  if caption != none { v(0.3em); text(size: 9pt, fill: muted, caption) }
})))

// Metadata starting with "6." would parse as a numbered list without the #[] guards.
#block(above: 2.5em, below: 2em)[
  #text(font: "Noto Sans", size: 9pt, fill: muted, tracking: 0.08em)[$if(subtitle)$#upper[$subtitle$]$endif$]
  #v(0.2em)
  #text(font: "Noto Sans", size: 21pt, weight: "semibold", fill: accent, hyphenate: false)[$title$]
$if(date)$
  #v(0.1em)
  #text(size: 9pt, fill: muted)[#[]$date$]
$endif$
$if(abstract)$
  #v(0.9em)
  #text(size: 10.5pt, fill: muted)[#[]$abstract$]
$endif$
]

$body$
