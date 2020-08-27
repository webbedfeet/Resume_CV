my_EUtilsQuery <- function (query, type = "esearch", db = "pubmed", ...)
{
  require(RISmed)
  PubMedURL <- RISmed:::EUtilsURL(type, db)
  Query <- gsub(" ", "+", query)
  OPTIONS <- c("retstart", "retmax", "rettype", "field", "datetype",
               "reldate", "mindate", "maxdate")
  ArgList <- list(...)
  if (length(ArgList) == 0) {
    ArgList$retmax <- 1000
  }
  else {
    WhichArgs <- pmatch(names(ArgList), OPTIONS)
    if (any(is.na(WhichArgs)) || sapply(WhichArgs, length) >
        1)
      stop("Error in specified limits.")
    names(ArgList) <- OPTIONS[WhichArgs]
    if (all(names(ArgList) != "retmax"))
      ArgList$retmax <- 1000
  }
  ArgList$tool <- "RISmed"
  ArgList$email <- "aikidasgupta@gmail.com"
  ArgStr <- paste(names(ArgList), unlist(ArgList), sep = "=")
  ArgStr <- paste(ArgStr, collapse = "&")
  paste(PubMedURL, "term=", Query, "&", ArgStr, sep = "", collapse = "")
}
