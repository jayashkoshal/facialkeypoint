## Loading the data
missing.types <- c("NA", "")
df.train<-read.csv(file="training.csv", sep=",", stringsAsFactors=F)
df.test<-read.csv(file="test.csv", sep=",", stringsAsFactors=F))

require(doMC)

im.train <- foreach (im = df.train$Image, .combine=rbind) %dopar% {
  as.integer(unlist(strsplit(im, " ")))
}
df.train$Image <- NULL

im.test <- foreach(im = df.test$Image, .combine=rbind) %dopar% {
  as.integer(unlist(strsplit(im, " ")))
}

df.test$Image <- NULL

save(d.train, im.train, d.test, im.test, file='data.Rd')

### Building the model
## Use mean of coordinates to detect facial feature
p           <- matrix(data=colMeans(df.train, na.rm=T), nrow=nrow(df.test), ncol=ncol(df.train), byrow=T)
colnames(p) <- names(df.train)
predictions <- data.frame(ImageId = 1:nrow(df.test), p)

library(reshape2)

submission <- melt(predictions, id.vars="ImageId", variable.name="FeatureName", value.name="Location")

example.submission <- read.csv(paste0(file="SampleSubmission.csv"))
sub.col.names <- names(example.submission)
example.submission$Location <- NULL
submission <- merge(example.submission, submission, all.x=T, sort=F)
submission <- submission[, sub.col.names]
write.csv(submission, file="submission_means.csv", quote=F, row.names=F)