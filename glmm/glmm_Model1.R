#Model 1 = find effects on response correctness in rating the emotional face

#Load in library
library(lme4)       # mixed, version 1.1-26
library(lmerTest)   # to get p values, version 3.1-3 
library(ggplot2)    # graphics, version 3.3.5
library(interactions) #version 1.1.5
library(tidyverse)  # needed for data manipulation.#needed to view data, version 1.3.1
library(jtools)     # post hoc tests, version 2.1.4
library(readxl)     # read excel, version 1.3.1
library(lme4)      # load mixed model library
library(lmerTest)  # library providing p-values for mixed models in lme4
library(tidyverse) # library with various tools (e.g. ggplot, pivot_long, pipes etc.)
library(emmeans)   # library for post-hoc tests
library(pbkrtest)  # needed for post-hoc tests in mixed models

#Load in dataset
data <- read.csv("C:/Users/juhoffmann/OneDrive - Uniklinik RWTH Aachen/Paper/PilotStudie/Revision/GLMM/GLMM_Model1_data.csv", sep=",")

#Remove missing values and additional column
data$X <- NULL
data <-data[complete.cases(data), ]

#View Data
View(data)

#Get datatype
summary(data) 

#Define variables
data$study_number[data$study_number == "study2"] <- 2
data$study_number[data$study_number == "study1"] <- 1

#data$response[data$response == "neutral"] <- 1
#data$response[data$response == "sad"] <- 2
#data$response[data$response == "happy"] <- 3

data$response[data$response == "8.0"] <- 1                                       #neutral
data$response[data$response == "7.0"] <- 2                                       #sad
data$response[data$response == "9.0"] <- 3                                       #happy

data$response[data$response == "8"] <- 1                                         #neutral
data$response[data$response == "7"] <- 2                                         #sad
data$response[data$response == "9"] <- 3                                         #happy


data$stim[data$stim == "neutral"] <- 3
data$stim[data$stim == "sad"] <- 2
data$stim[data$stim == "happy"] <- 1

data$level[data$level == "141ms"] <- 4
data$level[data$level == "25ms"] <- 3
data$level[data$level == "16ms"] <- 2
data$level[data$level == "8ms"] <- 1


#Transform trail numbers
data$real_trial_number <- as.integer(data$real_trial_number)
data$real_trial_number.z <- data$real_trial_number/sd(data$real_trial_number)    #z transformation


#Factorise variables
data$correct             <- factor(data$correct, ordered = FALSE)
data$level               <- factor(data$level, ordered = FALSE) 
data$subj_idx            <- factor(data$subj_idx, ordered = FALSE)
data$block               <- factor(data$block, ordered = FALSE)
data$study_number        <- factor(data$study_number, ordered = FALSE)
data$response            <- factor(data$response, ordered = FALSE)
#data$real_trial_number.z <- factor(data$real_trial_number.z, ordered = FALSE)
data$stim                <- factor(data$stim, ordered = FALSE)

#Set reference
#data$stim                <- relevel(data$stim , ref = 1)
#data$level               <- relevel(data$level , ref = "141ms")

summary(data)


options('contrasts')

#Use type III analysis of variance
options(contrasts = c("contr.sum", "contr.poly"))

#Plot Density 
#plot(density(data$correct),main="Density estimate of data")


# task_number = study_number


################################ Study 1 #######################################

#remove rows where column 'study_number' is equal to 2
data_study1<- subset(data, study_number != 2) 


#glmm for binary outcome = correct/incorrect -> family = "binomial"
#Model Selection, increase factors

Model1.study1 <- glmer(correct ~  stim + level 
                + (1|subj_idx),
                data = data_study1,
                family = "binomial")

Model2.study1 <- glmer(correct ~  stim * level 
               + (1|subj_idx),
               data = data_study1,
               family = "binomial")


anova(Model1.study1, Model2.study1) 



#include trial number as random intercept
Model3.study1 <- glmer(correct ~  level + stim
                + (1+real_trial_number|subj_idx),
                data = data_study1,
                family = "binomial")

Model3.z.study1 <- glmer(correct ~  level + stim
                + (1+real_trial_number.z|subj_idx),
                data = data_study1,
                family = "binomial")

anova(Model1.study1, Model2.study1, Model3.study1, Model3.z.study1)

#makes no difference if trial number is z transformed





#Get Statistics:
anova(Model3.study1)
summary (Model3.study1)
print(Model3.study1, corr=F)


#Get p-values from logit
fixef(Model3.study1)

 
level1.logit    <-fixef(Model3.study1)[[2]]    
level2.logit    <-fixef(Model3.study1)[[3]]    
level3.logit    <-fixef(Model3.study1)[[4]]  

level4.logit    <- -(fixef(Model3.study1)[[2]]+fixef(Model3.study1)[[3]]+fixef(Model3.study1)[[4]])

stim1.logit     <-fixef(Model3.study1)[[5]]  
stim2.logit     <-fixef(Model3.study1)[[6]] 
stim3.logit     <- -(fixef(Model3.study1)[[5]]+fixef(Model3.study1)[[6]])


tapply(as.numeric(data_study1$correct)-1,    data_study1$subj_idx, sum) # number of correct responses per subject
tapply(-(as.numeric(data_study1$correct)-2), data_study1$subj_idx, sum) # number of false responses per subject

#Backtransform logit into p value
1/(1+exp(-level1.logit))    # probability of making a correct response during level1 trials
1/(1+exp(-level2.logit))    # probability of making a correct response during level2 trials
1/(1+exp(-level3.logit))    # probability of making a correct response during level3 trials
1/(1+exp(-level4.logit))    # probability of making a correct response during level4 trials





######## Study 2 ########
data_study2<- subset(data, study_number != 1) 

#glmm for binary outcome = correct/incorrect -> family = "binomial"
#Model Selection, increase factors

Model1.study2 <- glmer(correct ~  stim + level 
                + (1|subj_idx),
                data = data_study2,
                family = "binomial")

Model2.study2 <- glmer(correct ~  stim * level 
                + (1|subj_idx),
                data = data_study2,
                family = "binomial")


anova(Model1.study2, Model2.study2) 
#no difference, continue without interaction to get less complex model


#include trial number as random intercept
Model3.study2 <- glmer(correct ~  level + stim
                + (1+real_trial_number|subj_idx),
                data = data_study2,
                family = "binomial")

Model3.z.study2 <- glmer(correct ~  level + stim
                  + (1+real_trial_number.z|subj_idx),
                  data = data_study2,
                  family = "binomial")

anova(Model1.study2,Model2.study2, Model3.study2, Model3.z.study2)

anova(Model3, Model3.z) #makes no difference if trial number is z transformed





#Get Statistics:
anova(Model3.study2)
summary (Model3.study2)
print(Model3.study2, corr=F)


#Get p-values from logit
fixef(Model3.study2)


level1.logit    <-fixef(Model3.study2)[[2]]    
level2.logit    <-fixef(Model3.study2)[[3]]    
level3.logit    <-fixef(Model3.study2)[[4]]  

level4.logit    <- -(fixef(Model3.study2)[[2]]+fixef(Model3.study2)[[3]]+fixef(Model3.study2)[[4]])

stim1.logit     <-fixef(Model3.study2)[[5]]  
stim2.logit     <-fixef(Model3.study2)[[6]] 
stim3.logit     <- -(fixef(Model3.study2)[[5]]+fixef(Model3.study2)[[6]])


tapply(as.numeric(data_study2$correct)-1,    data_study2$subj_idx, sum) # number of correct responses per subject
tapply(-(as.numeric(data_study2$correct)-2), data_study2$subj_idx, sum) # number of false responses per subject

#Backtransform logit into p value
1/(1+exp(-level1.logit))    # probability of making a correct response during level1 trials
1/(1+exp(-level2.logit))    # probability of making a correct response during level2 trials
1/(1+exp(-level3.logit))    # probability of making a correct response during level3 trials
1/(1+exp(-level4.logit))    # probability of making a correct response during level4 trials







######################## look for study number effect ##########################


#include random effect for study number
Model4 <- glmer(correct ~   level + stim
                + study_number
                + (1+real_trial_number|subj_idx),
                data = data,
                family = "binomial")


Model4.z <- glmer(correct ~   level + stim
                  + study_number
                  + (1+real_trial_number.z|subj_idx),
                  data = data,
                  family = "binomial")


anova(Model4, Model4.z) # no difference

#Get Statistics:
anova(Model4)
summary (Model4)
print(Model4, corr=F)


#Get p-values from logit
fixef(Model4)


level1.logit    <-fixef(Model4)[[2]]    
level2.logit    <-fixef(Model4)[[3]]    
level3.logit    <-fixef(Model4)[[4]]  

level4.logit    <- -(fixef(Model4)[[2]]+fixef(Model4)[[3]]+fixef(Model4)[[4]])

stim1.logit     <-fixef(Model4)[[5]]  
stim2.logit     <-fixef(Model4)[[6]] 
stim3.logit     <- -(fixef(Model4)[[5]]+fixef(Model4)[[6]])


tapply(as.numeric(data$correct)-1,    data$subj_idx, sum) # number of correct responses per subject
tapply(-(as.numeric(data$correct)-2), data$subj_idx, sum) # number of false responses per subject

#Backtransform logit into p value
1/(1+exp(-level1.logit))    # probability of making a correct response during level1 trials
1/(1+exp(-level2.logit))    # probability of making a correct response during level2 trials
1/(1+exp(-level3.logit))    # probability of making a correct response during level3 trials
1/(1+exp(-level4.logit))    # probability of making a correct response during level4 trials

