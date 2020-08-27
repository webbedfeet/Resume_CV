format_teaching <- function(d){
  d %>%
    select(-type) %>%
    mutate(Course = ifelse(is.na(URL),glue::glue("\\textbf{{{Course}}}"),
                           glue::glue("\\href{{{URL}}}{{\\textbf{{{Course}}}}}"))) %>%
    mutate(Notes = ifelse(Notes == '', '', glue::glue("\\emph{{{Notes}}}"))) %>%
    mutate(Description = paste(Course, Location, sep = ', ')) %>%
    select( -Location, -URL) %>%
    group_by(Course) %>%
    tidyr::gather(unit, value, -Start, -Course) %>%
    arrange(desc(Start), Course, unit) %>%
    mutate(Start = ifelse(unit == 'Notes','', Start)) %>%
    filter(value != '') %>%
    ungroup() %>%
    distinct() %>%
    select(Start, value) %>%
    baretable()
}
