install.packages("rstudioapi")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) ## sets your working directory to the file location if you use RStudio

#create links
urls <- paste("https://www.ndr.de/nachrichten/info/coronaskript", 100:200, ".pdf", sep="")


#download pdf-transcripts
for (url in urls) {
  tryCatch({
    download.file(url, destfile = basename(url), mode="wb")
  }, error=function(e){})
}

#list pdfs in directory
pdfs <- list.files(path = ".", pattern = "*.pdf")


#read pdf-files - returns a character vector of equal length to the number of pages

install.packages("pdftools")
library("pdftools")


for (i in 1:length(pdfs)) {
  tryCatch({
    assign ((paste("pdf", i, sep="")),  pdf_text(pdfs[i]))
  }, error=function(e){})
}

#remove pdf from non-podcast-transcripts (how to make a mask, corona-timeline)

rm(pdf30)
rm(pdf33)

#create dataframes with texts, date (regex out of pdf) and title (edition nr of podcast)


for (i in 1:length(pdfs))
{
  tryCatch({
    assign ((paste("df", i, sep="")), data.frame(text=get(paste("pdf", i, sep="")), date=sub(".*Stand *(.*?) *\r\n.*", "\\1", get(paste("pdf", i, sep=""))[[1]]), id= paste(i), title=sub(".*FOLGE *(.*?) *\r\n.*", "\\1", get(paste("pdf", i, sep=""))[[1]])))
  }, error=function(e){})
}

#merge dataframes

list <- lapply(ls(pattern="^df"), get)

df = do.call(rbind, list)

#save it as csv

write.csv(df, "drosten.csv")
