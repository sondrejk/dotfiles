#set terms(hanging-indent: 1.5em)
#set table(inset: 6pt, stroke: 0.5pt + luma(180))

#let horizontalRule = line(length: 100%, stroke: 0.5pt + luma(170))
#let divider = horizontalRule

$if(highlighting-definitions)$
$highlighting-definitions$

$endif$
#set document(title: [$title$])
#set page(
  paper: "a4",
  margin: (x: 2.4cm, top: 2.2cm, bottom: 2.4cm),
  numbering: "1 / 1",
  number-align: center,
)
#set text(font: "Libertinus Serif", size: 11pt, lang: "$if(lang)$$lang$$else$en$endif$")
#set par(justify: true, leading: 0.62em, spacing: 0.9em)
#show math.equation: set text(font: "New Computer Modern Math")
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)
#show raw.where(block: true): it => block(
  width: 100%, fill: luma(245), inset: (x: 9pt, y: 7pt), radius: 3pt, it,
)
#show raw.where(block: false): box.with(fill: luma(243), inset: (x: 2pt), outset: (y: 2pt), radius: 2pt)
#set list(indent: 0.4em, body-indent: 0.5em)
#set enum(indent: 0.4em, body-indent: 0.5em)
#show heading: set text(weight: "bold")
#show heading.where(level: 1): it => block(above: 1.6em, below: 0.9em, sticky: true, text(size: 15pt, it.body))
#show heading.where(level: 2): it => block(above: 1.5em, below: 0.8em, sticky: true, text(size: 13pt, it.body))
#show heading.where(level: 3): it => block(above: 1.3em, below: 0.7em, sticky: true, text(size: 11.5pt, it.body))
#show heading.where(level: 4): it => block(above: 1.2em, below: 0.6em, sticky: true, text(size: 11pt, it.body))
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.where(kind: table): set block(breakable: true)

#let question(number, body) = block(above: 1.3em, below: 0.75em, breakable: false, sticky: true, width: 100%)[
  #set text(weight: "semibold")
  #set par(justify: false)
  #if number == "" { body } else {
    grid(columns: (auto, 1fr), column-gutter: 0.45em, number, body)
  }
]

// Screenshots and diagrams arrive at arbitrary pixel sizes, so fit each one
// inside the text width and a height cap instead of trusting its natural size.
#let img(path, width: none) = align(center, block(above: 0.9em, below: 0.9em, layout(size => {
  let natural = measure(image(path))
  let max-w = if width == none { size.width } else { calc.min(width, size.width) }
  let max-h = 11cm
  let scale = calc.min(1, max-w / natural.width, max-h / natural.height)
  image(path, width: natural.width * scale)
})))

$if(title)$
#block(below: 1.4em)[
  #text(size: 19pt, weight: "bold")[$title$]
$if(author)$
  #v(-0.35em)
  #text(size: 11pt)[$author$ #h(1fr) $date$]
$endif$
  #v(-0.3em)
  #line(length: 100%, stroke: 0.6pt + luma(150))
]
$endif$

$body$
