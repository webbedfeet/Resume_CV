######################################################################
# R code to manipulate CSL JSON files to formatted bibliography
#
# Created: 2024-05-08
# Author: Abhijit Dasgupta
######################################################################

# Load necessary libraries
library(jsonlite)
library(tidyverse) |>
  suppressPackageStartupMessages()
library(glue)

format_name <- function(name) {
  parts <- strsplit(trimws(name), "\\s+")[[1]]
  last <- parts[length(parts)]
  initials <- paste0(substr(parts[-length(parts)], 1, 1), collapse = "")
  paste0(last, ", ", initials)
}
fn_concat = function(x) {
  n = length(x)
  if (n == 1) {
    x
  } else {
    paste0(paste0(x[-n], collapse = ', '), " and ", x[n])
  }
}

format_authors <- function(authors) {
  if (length(authors) == 0) {
    return("")
  }
  formatted_names <- authors |>
    glue_data("{given} {family}") |>
    map_chr(format_name) |>
    fn_concat()
  return(formatted_names)
}
extract_year <- function(x) {
  x[[1]] |> map_chr(`[`, 1)
}
format_bib <- function(jsonfile) {
  arts <- fromJSON(jsonfile)

  arts$author <- map_chr(arts$author, format_authors)
  arts$author <- map_chr(arts$author, \(x) {
    str_replace(x, "Dasgupta, A", "**Dasgupta, A**")
  })

  arts$pub_year <- map_chr(arts$issued, \(x) x[[1]][1])
  
  if (!'DOI' %in% names(arts)) {
    arts$DOI <- ""
  } else {
    arts$DOI <- ifelse(
      is.na(arts$DOI),
      "",
      paste0("[DOI](https://doi.org/", arts$DOI, ")")
    )
  }
  
  arts$issue <- ifelse(is.na(arts$issue), "", paste0("(", arts$issue, ")"))
  arts$`container-title` <- ifelse(is.na(arts$`container-title`), "", arts$`container-title`)
  arts$volume <- ifelse(is.na(arts$volume), "", arts$volume)
  arts$page <- ifelse(is.na(arts$page), "", arts$page)
  
  arts <- arts |>
    mutate(
      bib = case_when(
        type == "article-journal" ~ paste0(
          author, " (", pub_year, "). ", title, ". ",
          `container-title`, ", **", volume, "**", issue, ":", page, ". ", DOI
        ),
        type == "book" ~ paste0(author, " (", pub_year, "). *", title, "*"),
        type == "chapter" ~ paste0(
          author, " (", pub_year, "). ", title, ". In *", `container-title`, "*"
        ),
        type == "thesis" ~ paste0(
          author, " (", pub_year, "). ", title, ". [", `publisher`, " thesis]"
        ),
        type == "paper-conference" ~ paste0(
          author, " (", pub_year, "). ", title, ". ", `container-title`
        ),
        type %in% c("webpage", "post-weblog") ~ paste0(
          author, " (", pub_year, "). ", title
        ),
        TRUE ~ paste0(author, " (", pub_year, "). ", title)
      )
    )
  
  arts$bib |> cat(sep = "\n")
}
arts <- fromJSON('zotlib.json')[1:100,]

arts$author <- map_chr(arts$author, format_authors)
arts$author <- map_chr(arts$author, \(x) {
  str_replace(x, "Dasgupta, A", "**Dasgupta, A**")
})

extract_year <- function(x) {
  x[[1]] |> map_chr(`[`, 1)
}
arts$year = extract_year(arts$issued)
arts$DOI = ifelse(is.na(arts$DOI), "", as.character(glue("[DOI]({arts$DOI})")))
arts$issue = ifelse(is.na(arts$issue), "", paste0("(", arts$issue, ")"))
arts$`container-title` = ifelse(
  is.na(arts$`container-title`),
  "",
  arts$`container-title`
)

arts <- arts |> 
    mutate(bib = case_when(
        type == 'article-journal' ~ glue("{author} ({year}). {title} {`container-title`}, **{volume}**{issue}:{page}. {DOI}"),
        type == 'book' ~ glue("{author} ({year}). *{title}*"),
        TRUE ~ ""
    ))
glue_data(
  arts,
  "  1. {author} ({year}). {title} {`container-title`}, **{volume}**{issue}:{page}. {DOI}"
) |>
  cat(sep = "\n")
