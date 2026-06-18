// Reusable building blocks for __PROJECT_NAME__. Imported by main.typ, never compiled directly.

#let report-page(body) = {
  set page(paper: "a4", margin: 2.5cm)
  set text(font: "New Computer Modern", size: 11pt)
  set heading(numbering: "1.")
  body
}

#let title-block(title, author, date) = {
  align(center)[
    #text(size: 20pt, weight: "bold")[#title]
    #v(0.5em)
    #text(size: 12pt)[#author #h(1em) #date]
  ]
  v(1.5em)
}
