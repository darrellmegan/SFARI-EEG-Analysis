

data <- read.csv("Z:/Interns/darrellm/EEG Processing/SFARI/ProcessedData/ASSR_oddball/AfterStep8_ML/mean_accuracies.txt",header=FALSE)
colnames(data)<-c('Band','Condition','Channel','Accuracy')

library(ggplot2)

forty_data<-subset(data,data$Condition=='40Hz')
ggplot(forty_data, aes(x=Band, y=Accuracy, fill=Channel)) +
  geom_bar(stat="identity", position=position_dodge())+
  ggtitle('Classification Accuracy (ASD vs. control) Using Various Power Features\n [40 Hz Condition]',)+
  theme(plot.title = element_text(hjust = 0.5))+ylim(0,0.8)


twentyseven_data<-subset(data,data$Condition=='27Hz')
ggplot(twentyseven_data, aes(x=Band, y=Accuracy, fill=Channel)) +
  geom_bar(stat="identity", position=position_dodge())+
  ggtitle('Classification Accuracy (ASD vs. control) Using Various Power Features\n [27 Hz Condition]',)+
  theme(plot.title = element_text(hjust = 0.5))+ylim(0,0.8)