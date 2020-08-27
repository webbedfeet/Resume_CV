library(RISmed)

query = EUtilsSummary('Abhijit Dasgupta [au]')
fetch = EUtilsGet(query)

library(rentrez)

library(RefManageR)
blah = ReadPubMed('Abhijit Dasgupta [au]', retmax=100)
not_mine_ID <- as.character(c(31793973,    30541962 ,29954288,27225801,26367460,    24825957,
                 24339588,    24101837,    21150063,    20739801))
blah <- blah[-match(not_mine_ID, map_chr(blah, function(x) x$eprint))]
toBiblatex(blah)
WriteBib(blah, file = 'from_pubmed.bib')
