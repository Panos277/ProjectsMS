
#              4. Ancova - Linear Mixed Models 

library(haven)
require(nlme)
summary(RatPupWeight)

ratpup <-as.data.frame( read.table("rat_pup.txt", h = T))
head(ratpup, n = 10)  # ����������������� ��������� �� ����� "long format"
                      # ������� ��� ��� ����� �����������
tail(ratpup, n = 10)
summary(ratpup)

attach(ratpup)
names(ratpup)   

apply(ratpup,MARGIN=2,"class")
is.factor(sex)


# ����������� ���������� ��� ���� ��������� ��� �������� ��� ����������
# �� �� ��������� summary
with(ratpup, tapply( weight, interaction(treatment,sex),summary))

round(with(ratpup, tapply( weight, interaction(treatment,sex),sd)),3)

# ���� ����� ������ �� ������� ����������� ���������� ��� ������ ����������
# ����������� ����� ���� ���������� ��� �����������
# � ������ llist ���������� ���� � list �� �� ������� ��� ��������
# ��� ������� ���� ���������� ��� ����� ���������� (variables label attribute).

require(Hmisc)
g <- function(x)c(N=length(x),MIN=min(x,na.rm=TRUE),MAX=max(x,na.rm=TRUE),
                 MEDIAN=median(x,na.rm=TRUE), MEAN=mean(x,na.rm=TRUE),
                 SD=sd(x,na.rm=TRUE))
s1 <- summarize(weight,by=llist(treatment,sex),g) ;s1 
class(s1)
s1.1 <- within(s1, {
  MEAN <- round(MEAN, 3) 
  SD <- round(SD, 3)})
s1.1
s1.2 <- s1.1[order(-s1.1$MEAN), ]
s1.2



# ���������� ���������������
with(ratpup, interaction.plot( treatment,sex,weight))

# ������� ������� �������� ��������� ��� ��� ������ ��� ��������������
# ��� ���� ����������� ����� ��� ������

# � ��������� ��� ��������������� ��� ��� ��������� ��� boxplots,
# ������ ��������� �� �������� �� ���� ���� ���������� TREAT ��� SEX ����
# ���� �� ������� ��� TREAT ��������� ������ ��� ���� �' ����� (within)
# �������������� �� ������� ��� ��������� SEX

library(lattice)  # trellis graphics
library(grid)

bwplot(weight ~ sex|treatment, data=ratpup,aspect = 2, ylab="Birth Weights", 
       xlab="SEX",main = "Boxplots of birth weights for levels of treatment 
       by sex")

# ���� ����������� ������� ��������� �� ������ ����� ��� �����������������
# ��������� ��� ������-����� (litter), ���� ��� �� ������� �� �� ������� 
# ������������. ���� �������� �� �������� ��� �������� ��� ����� ��� ����
# ����� ��� ��������� ����� ��� ������. ��� �� ����� ���� ������������� �
# ��������� ranklit, � ���������� ������� ����������� ���� 2 (litsize=1)
# ��� � ����������� 18, (litsize=27).

ranklit <- litsize+0.01*litter
sort(ranklit)
ranklit
ranklit <- factor(ranklit)

levels(ranklit) <- c( "1","2", "3","4","5","6","7","8","9","10", "11","12", 
                      "13","14","15","16","17","18","19","20", "21","22", 
                      "23","24","25","26","27")

ranklit

bwplot(weight ~ ranklit | treatment*sex, data=ratpup, aspect = 0.5, 
       ylab="Birth Weights", xlab="" , groups=litter,
       scales = list(x = list(at=c(4,8,12,16,20,24))))


#------------------------------------------------------------------------
#                      Model 3.1.
#     ������ ������� �� �������� ��� ��������� ����������
#------------------------------------------------------------------------

library(nlme)
library(lme4)

# ������������ ��� �������� ��������� sex1 �� ����� 1 (��� ������) 
# ��� 0 (��������). �� ������ ������������� �� ����� ��������
ratpup$sex1[sex == "Female"] <- 1
ratpup$sex1[sex == "Male"] <- 0
attach(ratpup)

# ��� ��������������� � ���������� treatment ?
str(treatment)

# �� ������ �������
model3.1.fit <- lme(weight ~ treatment + sex1 + litsize + treatment*sex1,
                    random = ~1 | litter, ratpup, method = "REML")

mat1 <- as.data.frame(unique(model.matrix(model3.1.fit)))
names(mat1)
mat2 <- unique(mat1[ , c(-5)])
mat2   # O ������� ���������� ����� ����������� ��� ����� ��� "litsize"

# ������� ���������� �������� ����������
# ��������� ��� ���������� �� 0-1 ����������  (����������-contrasts)
contrasts(ratpup$treatment)
contrasts(ratpup$sex)

# ����� ����� � ������� ���������� �� ��� litsize, ����� ��� �����������
# ��� ������� ��� ��������� ���� ������ ����������� ����� ?
model3.1.matr <- as.matrix(unique(model.matrix(model3.1.fit)))
View(model3.1.matr)
# ��� ����������� �� �� excel ���� ��� ������������� �� ������ txt 
write.table(model3.1.matr, file = "design,matrix.rutpap.txt", row.names = F)
# � ������� ���������� ��� ��� 3� ������
model.matrix( weight ~ treatment + sex1 + litsize + treatment*sex1, 
              ratpup[ ratpup$litter == "3", ])
# � ������� ���������� ��� ��� 25� ������
model.matrix( weight ~ treatment + sex1 + litsize + treatment*sex1, 
              ratpup[ ratpup$litter == "25", ])

# ������������ ��� ��������
ranef(model3.1.fit)
summary(model3.1.fit)
anova(model3.1.fit)

# ������� �������� �� likelihood ratio test 
library(RLRsim)
exactRLRT(model3.1.fit)


# Display the random effects (EBLUPs) from the model.
# � ������ �������� ��� ��������� ��� ������ (27 ��������)
random.effects(model3.1.fit)


#------------------------------------------------------------------------
#                      Model 3.1A.
#         ������ ������� ����� �������� ����������
#------------------------------------------------------------------------

# Model 3.1A.
model3.1a.fit <- gls(weight ~ treatment + sex1 + litsize + treatment*sex1, 
                     data = ratpup)
summary(model3.1a.fit)

# ������� ��� �������� ��� � �������� ��� ������� ��������� ����� ��������
# ���������� ��� 2 ��� p-���� ��� ������� ����� � ������� �-��������� ��� ��� 
# ���� 0 ����� ��� ���� ����� ��� ��������� �������� �� ����� ����� �� 
# ������������ �� ����������� �������.
anova(model3.1.fit, model3.1a.fit)  

# � ������� �� �� ����
-200.5522-(-245.255) # = 44.7028
A1pval<-0.5*(1-pchisq(44.7028,1))+0.5*(1-pchisq(44.7028,2)) # = 1.096142e-10
A1pval


#------------------------------------------------------------------------
#                      Model 3.2.
#         ������� ��� ��� ������� ��� ���������
#------------------------------------------------------------------------


# Model 3.2A. 
# ��� ������������ ������ ��� ���� ����� Control � �������� ���� ��������
# ���� ��� �������� ��� ��� ��� ������ �������� � ���������� treatment
# ��������� ��� ������ ���������-������������ ��� ������� ����������. 

model3.2a.fit <- lme(weight ~ treatment + sex1 + litsize + treatment*sex1, 
                     random = ~1 | litter, ratpup, method = "REML", 
                     weights = varIdent(form = ~1 | treatment))
summary(model3.2a.fit)

# ������� ��� ��� ������� ��� � ������� ���� ��������� ������ ��� 
# ������ ����� �������� (��������� �������).
anova(model3.1.fit, model3.2a.fit)  

# ������������ �������� ������� ���������� ��������� �������
# ������ ��� ������ �� ���� ��� ��������� ��� ���� �� ������
# �����.



#------------------------------------------------------------------------
#                      Model 3.3.
#         ������� ��� ��� ������� ��� ��������� ���� 
#           ������ high ��� low (���������� treatment)
#------------------------------------------------------------------------

# ����������� ��� ����������� �������, �� �������� �� �� ������ 
# high ��� low ����� ���� ���������. ���� �� ����� ��������� ��� ��� ���������
# ���� ����� �� ��� ������ �������� ��� ���������. ��� ��������
# ���� � ��� ��������� �� ��������� ��� ������ ���������-������������
# (pooled variance)

ratpup$trtgrp[treatment == "Control"] <- 1
ratpup$trtgrp[treatment == "Low" | treatment == "High"] <- 2

# � ��� ��������� "trtgrp" �� �������� ��� ������ "weights" ������������
# �� �������� �� ����� ��� ��������� ������������ ��� ������� ���������,

model3.2b.fit <- lme(weight ~ treatment + sex1 + litsize +
                      treatment*sex1, random = ~1 | litter, ratpup, 
                     method = "REML",
                     weights = varIdent(form = ~1 | trtgrp))

# ����������� ��� ���� ��� ������ (likelihood ratio test) ��� �� ���������
# �� �� ��� ������� ����� �������� � ��������� �� �� �����������

anova(model3.2a.fit, model3.2b.fit) 

# �� ���������� ��� ����� ���������� ��������� �������� �������� �� ����������
# �� ������� �� ��� ����������� �������� (pooled ��� ��� ������ high ��� low 2�) 
# ��� �������� �� ��������� �� ���� �� ������� ����� ����������� ��� ���� �� 
# ��� ��������� �������� (homogeneous  error variance model, Model 3.1)

anova(model3.1.fit, model3.2b.fit)  
# �� ���������� ����� ���������� ��������� �������� �� ���������� �� �������
# �� ��� ����������� �������� .
summary(model3.2b.fit)

# ��� ������ ���� ����� �� ���������� ��� ������� ��� ���������� �������� ������
# ���������� ��� ���������������. ������� ���������� ���� ���� �����
# � ������� ����� ������� �� ����� ��� ML ��������� ��� ��� ��� REML

#Fixed effects: weight ~ treatment + sex1 + litsize + treatment * sex1 
#                      Value   Std.Error  DF   t-value p-value
#(Intercept)         8.350351 0.27567833 292 30.290196  0.0000
#treatmentHigh      -0.901844 0.19140146  23 -4.711793  0.0001
#treatmentLow       -0.466596 0.15999337  23 -2.916347  0.0078
#sex1               -0.408195 0.09303540 292 -4.387529  0.0000
#litsize            -0.130383 0.01856367  23 -7.023574  0.0000
#treatmentHigh:sex1  0.092026 0.12461723 292  0.738473  0.4608
#treatmentLow:sex1   0.076397 0.10939797 292  0.698337  0.4855

# ����������� ���  ������������� "treatment*sex1" ��� ����� 
# ���������� ��������� ��� �� �������, �������� �� �������������� 
# �� ������������ ������� ��� �� �� ����������� ��� ��������.
# �������� �� ����������� ��� �� ������� ����� ��� ��������� 
# treatment ���� ��� ���� ����������� ������ �������� ��� ���� 
# ����� � ��������� ��������.


#------------------------------------------------------------------------
#                      Model 3.4 - 5.
#         ������� ��� ��� �� ���������� ������ ���������� ��� 
#           ��������������� ��� �������� ����������
#                �� ����� ��������� ML
#------------------------------------------------------------------------

# Test Hypothesis 3.5.
anova(model3.2b.fit)

#Model 3.3, ����� ��� ������������� �� ����� ��������� ML (method = "ML") 
model3.3.ml.fit <- lme(weight ~ treatment + sex1 + litsize,
                         random = ~1 | litter, ratpup, method = "ML", weights =
                           varIdent(form = ~1 | trtgrp))
summary(model3.3.ml.fit)


#------------------------------------------------------------------------
#               ��������� ���� ��� �� Model 3.2 �
#         ����������� ��� ���������� �� �������� REML 
#           ��� ����� ���������� ��� ���������� ���������
#------------------------------------------------------------------------
 
#������������ �� ����� ��������� REML �� ������� (�������: � �����
#��������� ��� ���������� ���� ������� ������ ����, �� ���������� ����������
# ����� Type I, ������ ���������, �� ������� �������� ����� �� ����������� 
# ���� ���� ��� ������ ����������)
# Model 3.3: Final Model.
  model3.3.reml.fit <- lme(weight ~  litsize + sex1 + treatment,
                             random = ~1 | litter, ratpup, method = "REML",
                             weights = varIdent(form = ~1 | trtgrp))
 summary(model3.3.reml.fit)
 intervals(model3.3.reml.fit)
 anova(model3.3.reml.fit)
 
#�������� �� ������� ������������ ��� ��� ��������� ������������ 
#��� �� �� ��������� getVarCov
   getVarCov(model3.3.reml.fit, individual="27", type="marginal")

#������������ (��� ������������)
# �� ���������� ��� ��������� ��� ���� �������� ����������
# ������������� ���� ��������
# ������� �� ����� ��� �������������
#  Random effects:
   #   Formula: ~1 | litter
   #(Intercept)  Residual
   #StdDev:   0.3146374 0.5144324
   #
   #Variance function:
   #   Structure: Different standard deviations per stratum
   #Formula: ~1 | trtgrp 
   #Parameter estimates:
   #   1         2 
   #1.0000000 0.5889108 
# Var(litter) = 0.3146374^2 =0.10
# Var(high/low) = (0.5889108*0.5144324)^2 = 0.09
# Var(Control) = (0.5144324*1.000)^2 = 0.26

# ���������� �������� ������������� ��� ������������ ������� �� ��� ����� word



#------------------------------------------------------------------------
#               ������������ �������
#              ��� �� �������� �������L 
#------------------------------------------------------------------------

   
library(lattice)
trellis.device(color=F)

res <- resid(model3.3.reml.fit)
ratred <- data.frame(ratpup, res) #����� ������ ��������� ���������� �� 
                                  # ������� ���������
View(ratred)

## ���������� ��� ��������� ���� �������� �������� (����������� �����
# ��� ��������� �������������� ��� ���������)
histogram(~res | factor(trtgrp), data=ratred, layout=c(2,1), 
          aspect = 2 , xlab = "Residual") 
   
qqnorm(model3.3.reml.fit, ~resid(.) | factor(trtgrp), layout=c(2,1), 
       aspect = 2, id = 0.05)

by(res,factor(ratpup$trtgrp),shapiro.test)

# ���� �������� �� ��������� ������ ��� ������ �������������� � 
# ������� ������������ ��� �� ������ �� ����������

# �������������������
plot(model3.3.reml.fit, resid(.) ~ fitted(.) | factor(trtgrp), 
     layout=c(2,1), aspect=2, abline=0)
# �������� �������� ������������ ��� ����� �������� ������
   
# ��� �������� ��������
   
attach(ratpup)
   
   bwplot(resid(model3.3.reml.fit) ~ ranklit, data=model3.3.reml.fit, 
          ylab="residual", xlab="litter")
# � ������ ��� ������ ��� ������������ �������� ��� ��� ���������� 
# (������� ���������������)
   
plot(model3.3.reml.fit)


#------------------------------------------------------------------------



#----------------------------------------------------------------------
#                     ������� ��������������
#                         Ancova
#----------------------------------------------------------------------

#���������������� ������ ��� ��� �������� ��� �������� ���� ������������ ���
#������ S, B. ��� ������ �Ancova� ������������������ : � ������ ��� ������ 
#������� ����� ��� � ���������� �����. �� ��������� �� ���������:
#  
#  �� ����� �� ��������� ��  ���� �� ������������ ���� ��� �������� ��� 
#�������� (baseline �������).

#��� ���� ����� ��� ������� ������� ������ ������� ��� ������� �������� 
#(� ������� ��� ���������� ��� ������������ ��� ������).
#
#� ���������� ��� �������� ��� ���� ����������� �������� �� ���� ����� 
#(� �������� ��� ��������� ��� �� �����).
#
#�� ��������� �� ���������� �� ������ �������������� p<0.05

library(haven)

library(Hmisc)
Ancova <- spss.get("Ancova.sav", use.value.labels=TRUE)

names(Ancova)
levels(Ancova$group)
class(Ancova)
#View(Ancova)      # ������ ��� �� ����� �� ������� ���������
head(Ancova)
tail(Ancova)
Ancova

#----------------------------------------------------------------------
#                     ����������� ����������
#                      ������� �����������
#----------------------------------------------------------------------
attach(Ancova)
names(Ancova)
# require(Hmisc) # �� ��������� ��� ��� ����� ������
g <- function(x)c(N=length(x),MIN=min(x,na.rm=TRUE),MAX=max(x,na.rm=TRUE),
                  MEDIAN=median(x,na.rm=TRUE), MEAN=mean(x,na.rm=TRUE),
                  SD=sd(x,na.rm=TRUE))
summarize(preer,by=llist(group),g)
summarize(poster,by=llist(group),g)

library(lattice)  # trellis graphics
library(grid)

par(mfrow=c(1,2))
boxplot(preer ~ group, data=Ancova,
        cex.axis=0.7, cex.lab=1.5,
        pch = 1,
        xlab="Group", ylab="Er",
        id=list(labels=rownames(Ancova)))
boxplot(poster ~ group, data=Ancova,
        cex.axis=0.7, cex.lab=1.5,
        pch = 1,
        xlab="Group", ylab="Er",
        id=list(labels=rownames(Ancova)))
par(mfrow=c(1,1))

# ������� ��������� ���������
by(preer,group,shapiro.test) 
by(poster,group,shapiro.test) 

library(car)
anc1 <- lm(cbind(preer, poster) ~  group, 
           data=Ancova)
# MANOVA �� ����������, ��� ���������� � ������� univariate
Manova(anc1)

summary(Anova(anc1), univariate=FALSE, multivariate=TRUE,
        p.adjust.method=TRUE)
# ������������ ��� repeated measures (�������:univariate)
time<-factor(rep(c("pre", "post"), c(1,1)))
idata<-data.frame(time)
ancovaN <- Anova(anc1, idata=idata, idesign= ~ time)
summary(ancovaN,multivariate = FALSE)


# ������������� ��� ������������ ���������� ��������� ��������
# ������ ��� ������ ���� ���� ������ ������ �������� ��� ��� ���� ��
# ����� ��� ����������. ������ ������������ ���������� ��������� ������� 
# ������ ������� ��� ������� �������� ��� ��� �� ��� �����

# ������ ����� ��������� ���� ���� ����������� ������������� ���� ���� ������
# �� ������� ������� ������ ��� ������ ���� �� ������� ���� ���� ��� �������.
# ���� ��������� ���� �� ������ ���� �� �� ������� ����� ���� ��� �������.
# ��������� ������� ����� ���� ��� �������� �������������� ANCOVA


#----------------------------------------------------------------------
#                     ������� ��������������
#                        ������������
#----------------------------------------------------------------------

#1#�� ��������� ���������� �������� �������� (��� ���� ��������� ��� ����������)
# ���������

#2# ��� ������� ������� ������ ��� ������ �� ���� �� ��������.

leveneTest(unclass(preer)  ~ group, data=Ancova, center=mean)
leveneTest(unclass(poster) ~ group, data=Ancova, center=mean)

#3# ����������� ��� �������: �� ������ �� ������� �������� ����� ������
# ��� ��������� ���� ��� ���� ��� �� ������� ��� ������� ��� ������������� 
# ��� �� ������� ��� ��������� �� ������� ��� ������ ���������� �������
# ������ �� ��� ������� ������������� ������ ��� ������


nfd<-Ancova
detach(Ancova)
names(nfd)
attach(nfd)

# ����������� ������ ���������� ������� ��� ��������� ��� ������� ���
# ������� ��� ���������� ������� ��� ������ �������� ���� ������ �������
plot(preer,poster,
     pch=16+as.numeric(group),col=c("blue","red")[as.numeric(group)])
abline(lm(poster[group=="S"]~preer[group=="S"]),lty=2,col="blue")
abline(lm(poster[group=="B"]~preer[group=="B"]),lty=2,col="red")
legend(x = "topleft", lty = 2, col = c("blue","red"),
       legend = c("Group S", "Group B"))

# � ����������� ������� ��� ��� ������� ��� ������������ ��� ���������
# ������� �� �� ������ ������� ��������� �������������. ������ ���� ��� ��
# ����������� ���� ��� ������ ������� (preer), ��� ����� (group) ����� ��� ���
# ������������� preer*group. �� � ������������� ��� ����� ���������ܴ���������
# ���� ������������� ��� ������ � ������� ��� ����������� ��� �������.

a0<-lm(poster ~ preer*group, data=nfd) 
summary(a0)
anova(a0)
# �������� ����������� ��� ��� ��� ������������� preer:group p=0.5595 > 0.05
# �������� ������� ��� � ����� ����������. ��� �� ������� ��� Ancova ����� 
# ��������� ��� �� ������� ��� ������� ��� ��� ������� ������� ������ ��� 
# ����� ���� ��� ������ ���� �� ������� �������.
# ��� ������� ��� Ancova ��� �������������� � ���� ��� �������������� (���
# ������ �������� �������)
# �� ��������� ��� ��� ����� "poster ~ 1+preer+group1" ��� ���������
# � ���� 1 ����������� ��� ������� ��� ��� ����� ���������� �� ������, 
# ���� ���� ��������� ��� �� ������� ������� ��� �������� -1.

a1<-lm(poster ~ 1+preer+group, data=nfd)
summary(a1)
anova(a1)

# ������� �� �� ���������� ��� �������� �1, ����������� ��� ��� ������� 
# ���������� ��������� ������� ������ ��� ��� ������ ���� ��
# ���������� ��������.

# ��������� �, �)
t.test(preer ~ group, data=nfd, var.equal = TRUE)
t.test(poster ~ group, data=nfd, var.equal = TRUE)
with(nfd, t.test(preer[group=='S'], poster[group=='S'], paired = TRUE,
                 var.equal = TRUE))
with(nfd, t.test(preer[group=='B'], poster[group=='B'], paired = TRUE,
                 var.equal = TRUE))
###########################################################################

