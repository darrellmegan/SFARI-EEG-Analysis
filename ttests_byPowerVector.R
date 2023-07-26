
library(gtools)

dataPath = "Z:/Interns/darrellm/EEG Processing/SFARI/ProcessedData/ASSR_oddball/AfterStep6_Freq_analysis/freq-bands"
conditions = c('40Hz','27Hz')
#channels = c('FCz','Cz','Pz','T7','T8')
channels = c('FCz')
bands = c('delta','theta','alpha','beta','gamma','fortyHz','twentysevenHz')
freq_min = c(0.5,4,8,13,30,35,22)
freq_max = c(4,7,12,30,50,45,32)

pval_list<-c()
condition_list<-c()
chan_list<-c()
band_list<-c()
time_window_list<-c()
fold_change_list<-c()

conditions_for_timewindows<-c('beta','gamma','twentysevenHz','fortyHz')

for(myCondition in conditions){
  
  for(myChannel in channels){
    
    for(myBand in bands){
      
      tmp_dataPath <- paste(dataPath,myCondition,myChannel,myBand,sep='/')
      tmp_dataPath_timewindow <-paste(tmp_dataPath,'time_window',sep='/')
      print(tmp_dataPath)

      list_files = list.files(tmp_dataPath)
      
      group_data <- data.frame(matrix(NA,nrow=length(list_files),ncol=2))
      colnames(group_data)<-c('MeanPower','Group')
      
      count=0
      for(myFile in list_files){
        
        count = count+1
        if(myFile!='time_window' && myFile!='group_time_window' ){
          pt_data <- read.csv(paste(tmp_dataPath,myFile,sep='/'),header=FALSE)
          pt_data <- data.frame(t(pt_data))
          colnames(pt_data) <- c('Power','Freq')
          mean_power = mean(pt_data$Power)
          
          group_data$MeanPower[count] <- mean_power
          
          if(substr(myFile, nchar(myBand)+2, nchar(myBand)+3) == '10'){
            # pt is a control
            group_data$Group[count] <- 0
          }
          else{
            group_data$Group[count] <- 1
          }
        }
        
        
      }
      
      fc <- foldchange(mean(subset(group_data,group_data$Group==1)$MeanPower),mean(subset(group_data,group_data$Group==0)$MeanPower))
      
      t_test <- t.test(group_data$MeanPower,group_data$Group)
      pval <- as.numeric(t_test$p.value)
      
      pval_list<-c(pval_list,pval)
      condition_list<-c(condition_list,myCondition)
      chan_list<-c(chan_list,myChannel)
      band_list<-c(band_list,myBand)
      time_window_list<-c(time_window_list,'all')
      fold_change_list<-c(fold_change_list,fc)
      
      if(myBand %in% conditions_for_timewindows){
        list_timewindows = list.files(tmp_dataPath_timewindow)
        for(myTimewindow in list_timewindows){
          
          tmp_tmp_dataPath_timewindow <-paste(tmp_dataPath_timewindow,myTimewindow,sep='/')
          
          list_files = list.files(tmp_tmp_dataPath_timewindow)
          
          group_data_time_window <- data.frame(matrix(NA,nrow=length(list_files),ncol=2))
          colnames(group_data_time_window)<-c('MeanPower','Group')
          
          count=0
          for(myFile in list_files){
            
            count = count+1
            
            pt_data <- read.csv(paste(tmp_tmp_dataPath_timewindow,myFile,sep='/'),header=FALSE)
            pt_data <- data.frame(t(pt_data))
            colnames(pt_data) <- c('Power','Freq')
            mean_power = mean(pt_data$Power)
            
            group_data_time_window$MeanPower[count] <- mean_power
            
            if(substr(myFile, nchar(myBand)+2, nchar(myBand)+3) == '10'){
              # pt is a control
              group_data_time_window$Group[count] <- 0
            }
            else{
              group_data_time_window$Group[count] <- 1
            }
            
          }
          
          fc <- foldchange(mean(subset(group_data_time_window,group_data_time_window$Group==1)$MeanPower),mean(subset(group_data_time_window,group_data_time_window$Group==0)$MeanPower))
          t_test <- t.test(group_data_time_window$MeanPower,group_data_time_window$Group)
          pval <- as.numeric(t_test$p.value)
          
          pval_list<-c(pval_list,pval)
          condition_list<-c(condition_list,myCondition)
          chan_list<-c(chan_list,myChannel)
          band_list<-c(band_list,myBand)
          time_window_list<-c(time_window_list,myTimewindow)
          fold_change_list<-c(fold_change_list,fc)
      }
      
      
        
      }
      
    }
  }
}

pval_mat <- data.frame(cbind(Condition=condition_list,Channel=chan_list,Band=band_list,
                             pvals = pval_list,TimeWindow=time_window_list,
                             FC = fold_change_list))

#------------------------------------------------------------------------
 # PVAL PLOTS
#------------------------------------------------------------------------

    #================================================
     # TIME WINDOW PLOT - pval 
    #================================================

toPlot_timewindow <- pval_mat
toPlot_timewindow <- subset(toPlot_timewindow,toPlot_timewindow$Condition=='40Hz')
toPlot_timewindow <- subset(toPlot_timewindow,toPlot_timewindow$Channel=='FCz')
toPlot_timewindow <- subset(toPlot_timewindow,toPlot_timewindow$TimeWindow!='all')

#Bonferroni correction
toPlot_timewindow$pvals<-as.numeric(toPlot_timewindow$pvals)*nrow(toPlot_timewindow)

toPlot<-cbind(Beta=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='beta')$pvals),
              Gamma=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='gamma')$pvals),
              twentysevenHz=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='twentysevenHz')$pvals),
              fortyHz=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='fortyHz')$pvals))

colnames(toPlot)<-c('Beta','Gamma','twentysevenHz','fortyHz')
myCol_order<-colnames(toPlot)
myRow_order<-c("-200 - 0","0 - 200","200 - 400","400 - 600","600 - 800" )

library(circlize)
library(ComplexHeatmap)

col_fun = colorRamp2(c(0.001, 0.05, 1), c("green", "white", "red"))

Heatmap(as.matrix(toPlot),col_fun,row_split=myRow_order,
        row_dend_reorder = FALSE,row_order=order(myRow_order),
        column_split = myCol_order,column_order=order(myCol_order),
        row_title_rot = 0,
        column_title = "p-values: ASD vs. controls\n at various power bands & time windows\n[40 Hz - FCz]")



    #================================================
      # ENTIRE EPOCH PLOT - pval
    #================================================

pval_mat_all <- subset(pval_mat,pval_mat$TimeWindow=='all')

upd_pval_mat <-data.frame(matrix(NA,nrow=0,ncol=5))
colnames(upd_pval_mat) <- c('Freq','pval','Condition','Channel','myBand')
for(myCondition in conditions){
  tmp_pval_mat<-subset(pval_mat_all,pval_mat_all$Condition==myCondition)
  
  for(myChan in channels){
    tmp_pval_mat<-subset(tmp_pval_mat,tmp_pval_mat$Channel==myChan)
    
    count=0
    for(myBand in bands){
      count=count+1
      
      tmp_range <- seq.int(freq_min[count], freq_max[count], by = 0.5)
      
      tmp_pval <- as.numeric(tmp_pval_mat$pvals[which(tmp_pval_mat$Band == myBand, arr.ind=TRUE)])

      tmp_mat<-data.frame(cbind(Freq=tmp_range,pval=tmp_pval,Condition=myCondition,Channel=myChan,Band=myBand))
      upd_pval_mat<-rbind(upd_pval_mat,tmp_mat)
      
    }
    
  }

}

num_conditions=7
plot_mat<-subset(upd_pval_mat,upd_pval_mat$Condition=='40Hz')
plot_mat<-subset(plot_mat,plot_mat$Channel=='FCz')

plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='delta', 1)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='theta', 2)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='alpha', 3)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='beta', 4)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='gamma', 5)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='fortyHz', 6)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='twentysevenHz', 7)

#Bonferroni correction
plot_mat$pval<-as.numeric(plot_mat$pval)*num_conditions
waves <- matrix(as.numeric(plot_mat$Band))

library(circlize)
library(ComplexHeatmap)

col_fun = colorRamp2(c(0.001, 0.05, 1), c("green", "white", "red"))

toPlot<-as.matrix(as.numeric(plot_mat$pval))
Heatmap(toPlot,col_fun,row_split=waves,
        row_dend_reorder = FALSE,row_order=order(waves),
        row_title = c("delta", "theta", "alpha", "beta","gamma","35-45 Hz","22-32 Hz"),
        column_title = "p-values: ASD vs. controls\n at various power bands\n[40 Hz - FCz]")

#------------------------------------------------------------------------
# FOLD-CHANGE PLOTS
#------------------------------------------------------------------------
    
    #================================================
     # TIME WINDOW PLOT - fold-change 
    #================================================

toPlot_timewindow <- pval_mat
toPlot_timewindow <- subset(toPlot_timewindow,toPlot_timewindow$Condition=='40Hz')
toPlot_timewindow <- subset(toPlot_timewindow,toPlot_timewindow$Channel=='FCz')
toPlot_timewindow <- subset(toPlot_timewindow,toPlot_timewindow$TimeWindow!='all')
toPlot_timewindow$FC<-foldchange2logratio(as.numeric(toPlot_timewindow$FC), base = 2)


toPlot<-cbind(Beta=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='beta')$FC),
              Gamma=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='gamma')$FC),
              twentysevenHz=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='twentysevenHz')$FC),
              fortyHz=data.frame(subset(toPlot_timewindow,toPlot_timewindow$Band=='fortyHz')$FC))

colnames(toPlot)<-c('Beta','Gamma','twentysevenHz','fortyHz')
myCol_order<-colnames(toPlot)
myRow_order<-c("-200 - 0","0 - 200","200 - 400","400 - 600","600 - 800" )

library(circlize)
library(ComplexHeatmap)

col_fun = colorRamp2(c(-2, 0, 2), c("orange", "white", "blue"))

Heatmap(as.matrix(toPlot),col_fun,row_split=myRow_order,
        row_dend_reorder = FALSE,row_order=order(myRow_order),
        column_split = myCol_order,column_order=order(myCol_order),
        row_title_rot = 0,
        column_title = "Log Fold Change: ASD vs. controls\n at various power bands & time windows\n[40 Hz - FCz]")


    #================================================
    # ENTIRE EPOCH PLOT - fold-change
    #================================================

pval_mat_all <- subset(pval_mat,pval_mat$TimeWindow=='all')

upd_FC_mat <-data.frame(matrix(NA,nrow=0,ncol=5))
colnames(upd_FC_mat) <- c('Freq','FC','Condition','Channel','myBand')
for(myCondition in conditions){
  tmp_FC_mat<-subset(pval_mat_all,pval_mat_all$Condition==myCondition)
  
  for(myChan in channels){
    tmp_FC_mat<-subset(tmp_FC_mat,tmp_FC_mat$Channel==myChan)
    
    count=0
    for(myBand in bands){
      count=count+1
      
      tmp_range <- seq.int(freq_min[count], freq_max[count], by = 0.5)
      
      tmp_FC <- as.numeric(tmp_FC_mat$FC[which(tmp_FC_mat$Band == myBand, arr.ind=TRUE)])
      
      tmp_mat<-data.frame(cbind(Freq=tmp_range,FC=tmp_FC,Condition=myCondition,Channel=myChan,Band=myBand))
      upd_FC_mat<-rbind(upd_FC_mat,tmp_mat)
      
    }
    
  }
  
}

num_conditions=7
plot_mat<-subset(upd_FC_mat,upd_FC_mat$Condition=='40Hz')
plot_mat<-subset(plot_mat,plot_mat$Channel=='FCz')

plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='delta', 1)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='theta', 2)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='alpha', 3)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='beta', 4)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='gamma', 5)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='fortyHz', 6)
plot_mat$Band<-replace(plot_mat$Band, plot_mat$Band=='twentysevenHz', 7)

plot_mat$FC<-foldchange2logratio(as.numeric(plot_mat$FC), base = 2)
waves <- matrix(as.numeric(plot_mat$Band))


library(circlize)
library(ComplexHeatmap)

col_fun = colorRamp2(c(-2, 0, 2), c("orange", "white", "blue"))

toPlot<-as.matrix(as.numeric(plot_mat$FC))
Heatmap(toPlot,col_fun,row_split=waves,
        row_dend_reorder = FALSE,row_order=order(waves),
        row_title = c("delta", "theta", "alpha", "beta","gamma","35-45 Hz","22-32 Hz"),
        column_title = "Log Fold Change: ASD vs. controls\n at various power bands\n[40 Hz - FCz]")

