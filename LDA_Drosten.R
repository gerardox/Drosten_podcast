library(tosca)

#create Textmeta object 

cols=c("id", "text", "date", "title")

corpus <- readTextmeta(path=".", file="drosten.csv", cols= cols, dateFormat = "%d.%m.%Y",idCol = "id", dateCol = "date", titleCol = "title" ,textCol = "text", encoding = "")

install.packages("stringr")
library(stringr)

#remove all non alphanumerical character

temp = names(corpus$text)
corpus$text <- str_replace_all(corpus$text, "[^[:alnum:]]", " ") 
names(corpus$text) = temp

#Have a look at the frequency of documents (=pages of a pdf-transcript) over time

plotScot(corpus, curves = "both", unit="weeks")

#Clean the corpus and get rid of some stop words

corpusClean <- cleanTexts(object = corpus, checkUTF8 = FALSE, sw = c(tm::stopwords("de"), "schon", "mal", "ja", "gibt", "dass", "sagen", "ganz", "natürlich", "anja", "martini", "corinna", "henning", "https", "of", "de", "www", "hennig", "ndr", "coronaupdate", "korinna", "christian", "drosten"))

#Create wordtable

wordtable <- makeWordlist(corpusClean$text)

#Have a look at the most common types

freq_words <- sort(wordtable$wordtable, decreasing = TRUE)
freq_words[1:100]

#Wordcloud of most common types in corpus

freq_words_df <-  data.frame(word=names(freq_words), freq=freq_words, row.names=NULL)

install.packages("wordcloud")
library("wordcloud")
wordcloud(words = freq_words_df$word, freq = freq_words_df$freq, min.freq = 1,
          max.words=500, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Paired"))

#LDA

words5 <- wordtable$words[wordtable$wordtable > 5]
pagesLDA <- LDAprep(text = corpusClean$text, vocab = words5)

result <- LDAgen(documents = pagesLDA, K = 7L, vocab = words5, seed = 123, folder=".")
load(file.path(dirname(rstudioapi::getActiveDocumentContext()$path),".-k7alpha0.14eta0.14i200b70s123.RData"))

# Dendrogram
clustRes <- clusterTopics(ldaresult = result, xlab = "Topic", ylab = "Distance")

plotTopic(object = corpusClean, ldaresult = result, ldaID = ldaID,
          rel = TRUE, curves = "smooth", smooth = 0.4, legend = "topright", ylim = c(0, 0.7), unit = "days")

#topWords and wordclouds

topWords <- topWords(result$topics, numWords=100, values=TRUE)

#For T1
wordcloud(words = topWords$word[,1], freq = topWords$val[,1], min.freq = 1,
          max.words=100, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

#Area-Plot
plotArea(ldaresult = result, ldaID = ldaID, meta = corpus$meta,
         unit = "weeks", sort = FALSE, legend = "topright",select = c(1,2, 3, 5,6,7))

#Heatmap
plotHeat(object = corpus, ldaresult = result, ldaID = ldaID, unit = "weeks",select = c(1,2, 3,4, 5,6,7), tnames= c("I", "II", "III", "IV", "V", "VI", "VII") )

