if(!require(psymonitor)) install.packages("psymonitor")
library(psymonitor)
library(MultipleBubbles)
library(dplyr)
library(readxl)
library(xlsx)
library(ggplot2)
library(urca)


d <- read_excel("bubbles.xlsx", col_types = c("date", "numeric"))
colnames(d)<-c("date", "prices")

d$date<-as.Date(d$date)

fig1_prices <- ggplot(d, aes(x=date, y=prices)) +
  geom_line()+
  labs(x="", y="USD/Barrel")+
  theme_classic(base_size = 10)+
  theme(axis.text.x = element_text(hjust = .8), text = element_text(family = "serif"))+
  scale_y_continuous(labels=scales::number_format(decimal.mark = ','))
fig1_prices

ggsave("fig1_prices.png")

y<-log(d$prices)

adf_y <-ur.df(y, type="drift", selectlags = "BIC")

obs <- length(y)
r0 <- 0.01 + 1.8/sqrt(obs)
swindow0 <- floor(r0*obs)
dim <- obs - swindow0 + 1
Tb <- round(0.20*obs,0) #My choice was to set 20% of the dataset to run the simulation
IC <- 2 # 1 for AIC, 2 for BIC, or 0 for fixed
adflag <- 10 #if IC = 0, set fixed lag size
alfa <- 1  # 1 for 10%, 2 for 5%, and 3 for 1%


# BSADF statistics calculation 
inicio<-Sys.time()
bsadf <- PSY(y, swindow0, IC, adflag = 1)
# CV simulation: Use cvPSYwmboot for bootstrap, and cvPSYmc for MC
quantilesBsadf <- cvPSYwmboot(y, swindow0, Tb=Tb, nboot = 1000, nCores = 2)
quantile_alfa <- quantilesBsadf %*% matrix(alfa, nrow = 1, ncol = dim)
tempo<-Sys.time()-inicio

if(max(bsadf)>quantilesBsadf[alfa]){
  bubbles <- (bsadf > t(quantile_alfa[alfa, ])) * 1
  monitorDates <- d$date[swindow0:obs]
  periods <- locate(bubbles, monitorDates)
  test <-is.null(periods)
  
  if(test == FALSE)
  {
    bubbleDates <- disp(periods, obs)  #generate table that holds crisis periods
    print(bubbleDates)
    write.csv(bubbleDates, "bubbleDates.csv")
    
    
    fig2_bubbles<-ggplot() + 
      geom_rect(data = bubbleDates, aes(xmin = start, xmax = end, 
                                        ymin = -Inf, ymax = Inf), alpha = 0.5) + 
      geom_line(data = d, aes(date, prices)) +
      labs(title = "",
           subtitle = "",
           caption = "",
           x = "", y = "USD/Barrel")+
      theme_classic(base_size = 10)+
      theme(axis.text.x = element_text(hjust = .8), text = element_text(family = "serif"))+
      scale_y_continuous(labels=scales::number_format(decimal.mark = ','))
    fig2_bubbles
    
  } else {
    cat("There are no periods with bubbles")
  }
}
tempo

date_bubbles<-cbind(as.data.frame(monitorDates), t(bubbles))
colnames(date_bubbles)<-c("data", "bolha")
date_bubbles
write.csv(date_bubbles, "date_bubbles.csv")

