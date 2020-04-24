# Code to download and manipulate Google Scholar citations
#

library(pacman)
p_load(char = 'scholar','tidyverse','glue')

gs <- get_publications('EgaGUCwAAAAJ') # Read the citations


#' The tasks we need to extract the citation components are
#'
#' - Split the "number" component into volume, number and pages
#' - Create a bibtex key
#'
#' The principle of key generation I use is <first_author><year><[a-z]>
#' So I extract the surname of the first author, and the year, and then, in
#' instances where the same author/year combination has multiple papers, attach
#' a lower-case letter to the key.
#'
gs_processed <- gs %>%
  separate(number, c('vol1','page'), sep = ', ', fill = 'right') %>%
  separate(vol1, c('vol','num'), sep = ' \\(', fill = 'right') %>%
  mutate(num = str_squish(str_remove(num, '\\)')),
         page = str_squish(page),
         author = str_replace_all(author, ',',' and'),
         journal = str_to_title(journal),
         first_author = str_match(author, '[A-Z]+ ([:alpha:]+)')[,2]) %>%
  group_by(first_author, year) %>%
  mutate(key = paste(first_author, year, letters[1:n()], sep = '')) %>%
  ungroup() %>%
  arrange(key)

#' Doing some text processing to avoid non-ASCII characters and reserved
#' LaTeX symbols
#'
gs_processed <- gs_processed %>%
  mutate(title = str_replace(title, '\\\\# 946;','beta'),
         title = str_replace(title, '&', '\\\\&'),
         title = str_replace(title, '#','')) %>%
  filter(!is.na(year))

#' Create bibtex entries using `glue`. Almost all GScholar entries are journal
#' articles, so I use that.
writeLines(
  glue_data(bl2,
            "@Article{{ {key},
          title = {{ {title} }},
          author = {{ {author} }},
          journal = {{ {journal} }},
          year = {{ {year} }},
          volume = {{ {vol} }},
          number = {{ {num} }},
          pages = {{ {page} }},
          note = {{Citations: {cites}}}
          }}

          ",
            .na = '') , 'gscholar.bib')
