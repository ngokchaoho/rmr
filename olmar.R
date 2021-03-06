olmar_run <- function(fid,data_matrix)
{
  datamatrix1=data_matrix
  n = nrow(datamatrix1)
  m = ncol(datamatrix1)
  cum_ret = 1
  cumpro_ret = NULL
  daily_ret = NULL
  epsilon=10
  alpha=0.5
  tc=0
  sumreturn=1
  day_weight = as.matrix(rep(1/m,m))
  day_weight_o = as.matrix(rep(0,m))
  daily_portfolio = as.vector(rep(NULL,m))
  phi=t(as.matrix(rep(1,m)))
  
  
  for(i in seq(from=1, to=n))
  {data<-t(as.matrix(datamatrix1[i,]))
  if(i>=2){
    phi=alpha+(1-alpha)*phi/datamatrix1[i-1,]
    ell=max(0,epsilon-phi%*%day_weight)
    xbar=mean(phi)
    denominator=(phi-xbar)%*%t(phi-xbar)
    if(denominator!=0){
      lambda=ell/denominator
    }else{
      lambda=0
    }
    day_weight<-day_weight+as.numeric(lambda)*(t(phi)-xbar)
    day_weight<-simplex_projection(day_weight,1)
  }
  day_weight<-day_weight/sum(day_weight)
  if(i==1)
  {
    daily_portfolio=day_weight
  }else{
    daily_portfolio=cbind(daily_portfolio,day_weight)
  }
  daily_ret=cbind(daily_ret,(data%*%day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o))))
  cum_ret=cum_ret*daily_ret[i]
  cumpro_ret=cbind(cumpro_ret,cum_ret)
  day_weight_o = day_weight*t(data)/daily_ret[i]
  }
  return(list(cum_ret,cumpro_ret,daily_ret))
}


#install.packages('R.matlab')
library("R.matlab")
#install.packages("readxl")
#install.packages("stats")
#library(stats)
#library(readxl)
path <- ('Data')
#input
pathname <- file.path(path,'sp500.mat')
data_1 <- as.vector(readMat(pathname))
#data_matrix <- read_excel(pathname, sheet = "P4", skip=4, col_names = FALSE)
#data_matrix <- data.matrix(data_matrix[,2:ncol(data_matrix)])
#data_matrix <- data_matrix[complete.cases(data_matrix),]
#data_matrix <- read.csv(pathname,sep=',',stringsAsFactors = FALSE,skip=3,header=TRUE)
#class(data_1)
#print(data_1)
data_matrix <- as.matrix(as.data.frame(data_1))
#class(data_matrix)
fid = "olmar.txt"
#implementation
result = olmar_run(fid,data_matrix)
write.csv(file = "olmar.csv",result)
source("ra_result_analyze.R")
ra_result_analyze(paste(pathname,"olmar.csv",sep = '_'),data_matrix,as.numeric(result[[1]]),as.numeric(result[[2]]),as.numeric(result[[3]]))
