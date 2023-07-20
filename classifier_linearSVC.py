from sklearn.svm import LinearSVC
from sklearn.datasets import load_iris
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.model_selection import cross_val_score
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report
import os
import numpy as np

mySavePath = '//data2.einsteinmed.edu/home/cnl-interns-lab/Interns/darrellm/EEG Processing/SFARI/ProcessedData/ASSR_oddball/AfterStep8_ML/'
num_iter = 100

myBands = ['delta','theta','alpha','beta','gamma','fortyHz','twentysevenHz']
freq_range = [3.5,3,4,17,20,10,10]
myChans = ['FCz','Cz','Pz','T7','T8']
myConditions = ['40Hz','27Hz']

condition_count=-1
for myCondition in myConditions:
    condition_count = condition_count+1
    
    chan_count=-1
    for myChan in myChans:
        chan_count = chan_count+1  
        
        band_count=-1
        for myBand in myBands:
            myPath = '//data2.einsteinmed.edu/home/cnl-interns-lab/Interns/darrellm/EEG Processing/SFARI/ProcessedData/ASSR_oddball/AfterStep6_Freq_analysis/freq-bands/'+myCondition+'/'+myChan+'/'+myBand
            myDir = os.listdir(myPath) 
            
            band_count = band_count+1
            
            num_freq_windows = int(freq_range[band_count]*100+1)
            
            num_patients = len(myDir)
            power_x = np.ndarray([num_patients,num_freq_windows])
            groups_y = np.zeros(num_patients)
            
            count=-1
            for myFile in myDir:
                count = count+1
                f = open(myPath + '/' + myFile, "r")
                currentline = f.readline()
                power = currentline.split(",")
                power = [eval(i) for i in power]
                power_x[count,:] = power
                
                if myFile[(len(myBand)+1):(len(myBand)+3)]!='10':
                    groups_y[count] = 1
            
            accuracies = np.empty(num_iter)
            count=-1
            for iter in range(num_iter):
                count=count+1
                
                xtrain, xtest, ytrain, ytest = train_test_split(power_x, groups_y, test_size=0.2)
                
                lsvc = LinearSVC(verbose=0)
                #print(lsvc)
                
                lsvc.fit(xtrain, ytrain)
                train_score = lsvc.score(xtrain, ytrain)    
                
                ypred = lsvc.predict(xtest)
                
                #cm = confusion_matrix(ytest, ypred)
                #print(cm)
                
                test_score = lsvc.score(xtest, ytest)
                accuracies[count] = test_score
                
            mean_accuracy = accuracies.mean()
            print(mean_accuracy)
            
            with open(mySavePath + 'mean_accuracies.txt', 'a') as f:
                f.write(myBand + ',' +myCondition+ ',' +myChan+ ',' +str(mean_accuracy)+ '\n')
                
