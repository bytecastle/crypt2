# This a helper script for the application which means that any functions,dfs etc. created 
# are done here first and the final version is referenced in the shiny app

# ---------- LIBRARIES ---------#
# Installation & Loading of packages
if (!require("tidyverse")){
  install.packages("tidyverse",dependencies = T)
  library(tidyverse)
}

if (!require("shinydashboard")){
  install.packages("shinydashboard",dependencies = T)
  library(shinydashboard)
}

if (!require("shinydashboardPlus")){
  install.packages("shinydashboardPlus",dependencies = T)
  library(shinydashboardPlus)
}

if (!require("shinyjs")){
  install.packages("shinyjs",dependencies = T)
  library(shinyjs)
}

if (!require("data.table")){
  install.packages("data.table",dependencies = T)
  library(data.table)
}

if (!require("plotly")){
  install.packages("plotly",dependencies = T)
  library(plotly)
}

if (!require("pool")){
  install.packages("pool",dependencies = T)
  library(pool)
}

if (!require("RPostgres")){
  install.packages("RPostgres",dependencies = T)
  library(RPostgres)
}

if (!require("yaml")){
  install.packages("yaml",dependencies = T)
  library(yaml)
}

if (!require("glue")){
  install.packages("glue",dependencies = T)
  library(glue)
}

if (!require("shinythemes")){
  install.packages("shinythemes",dependencies = T)
  library(shinythemes)
}

if (!require("shinyWidgets")){
  install.packages("shinyWidgets",dependencies = T)
  library(shinyWidgets)
}

if (!require("shinyjs")){
  install.packages("shinyjs",dependencies = T)
  library(shinyjs)
}

if (!require("DT")){
  install.packages("DT",dependencies = T)
  library(DT)
}

if (!require("formattable")){
  install.packages("formattable",dependencies = T)
  library(formattable)
}

if (!require("reticulate")){
  install.packages("reticulate",dependencies = T)
  library(reticulate)
}

# ---------- DATASETS & CONNECTIONS ---------#

cryptdata<-read_csv("cryptdata.csv")
lol_champions<-read_csv("lol_champions.csv")
another_df <- read_csv("another_df.csv")

# functions to add quotes to the character vectors in a dataset
addQuotes <- function(x) sprintf("'%s'", paste(x))

# Here we split the lol_champions into lol_champ*_code and the normal one. 
# The reason is so that in the output display we don't have the character 
# vectors with quotes. However the code display requires it so hence two sets.
lol_champions_code<-lol_champions
lol_champions_code$name<-addQuotes(lol_champions_code$name)
lol_champions_code$class<-addQuotes(lol_champions_code$class)
lol_champions_code$damagetype<-addQuotes(lol_champions_code$damagetype)

# List of available functions for translation
list_of_funcs<-unique(cryptdata$func)

# ---------- LANGUAGES & PACKAGES ---------#
languages <- unique(cryptdata$lang)
packages_r <- c('dplyr','data.table')
packages_py <- c('pandas')

# ---------- CUSTOM FUNCTIONS ---------#
# select the relevant packages
lang_pack <- function(x){
  if(x == 'R'){
    return(packages_r)
  } else if(x == 'Python'){
    return(packages_py)
  } else {
    return("No Library")
  }
}

# translation between two languages with function selection
lock_and_load_syntax<-function(funct,language,module,
                               values,nameFrame,
                               nameCol1,nameCol2){
  #this step filters the cryptdata dictionary to that particular 
  #language,function and module
  cryptdata_filtered<-cryptdata %>% 
    filter(func == funct, lang == language, mod == module) %>% 
    select(syntax)
  # list of all values that need renaming
  syn<-cryptdata_filtered$syntax
  language = language
  df = nameFrame
  col1 = nameCol1
  col2 = nameCol2
  values = values
  logical_ops_1 = ifelse(language == "Postgresql",
                         ifelse(str_detect(values[1],"\\d+"),">=","="),
                         ifelse(str_detect(values[1],"\\d+"),">=","=="))
  logical_ops_2 = ifelse(language == "Postgresql",
                         ifelse(str_detect(values[3],"\\d+"),"<","="),
                         ifelse(str_detect(values[3],"\\d+"),"<","=="))
  value_1 = values[1]
  value_2 = values[3]
  
  #here we split the vector of values to finally assign them to 
  #placeholders namely df,col1 etc.
  #here we have an if-else statement because it was discovered while testing 
  #that for the specific funct below, the original syntax contained {} brackets.
  #since the way for glue to identify what elements need to be replaced it also
  # {} that needed to be changed as this very specific situation.
  final_syn<-ifelse(funct=="rename columns" & language=="Python" & module=="pandas",
                    glue(syn,df=df,
                         col1=col1, col2=col2,
                         val1=values[1], val2=values[2], 
                         val3=values[3], val4=values[4],
                         logical_ops_1=logical_ops_1,
                         logical_ops_2=logical_ops_2,
                         value_1= value_1,
                         value_2= value_2,
                         .open = "<",.close = ">"),
                    glue(syn,df=df,
                         col1=col1, col2=col2,
                         val1=values[1], val2=values[2], 
                         val3=values[3], val4=values[4],
                         logical_ops_1=logical_ops_1,
                         logical_ops_2=logical_ops_2,
                         value_1= value_1,
                         value_2= value_2)
                    ) #closing bracket of if-else statement 
  #final_syn<-as.character(final_syn)
  # the foll statement is required as there was an issue with html recognising
  # a new line.
  final_syn<-gsub('<br/>','\n',final_syn)
  return(final_syn)
}

# To get the values of selected columns
get_values<-function(x,y){
  col1 <- x
  col2 <- y
  df<-lol_champions_code %>% select(col1,col2)
  choice1 = unique(df[,col1][[1]])
  choice2 = unique(df[,col2][[1]])
  choices = list('first_choice'=choice1,'second_choice'=choice2)
  return(choices)
}


# display output tables 
# table_output <- function(funct) {
#   df <- lol_champions %>% filter(func == funct, lang == "R", mod == "dplyr") %>%
# }


