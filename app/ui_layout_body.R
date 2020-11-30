# ----------- text description function ------------ #
intro_func<-function(){
  p("Below you have a list of available commands for translation.
     Just select what you would like to do to see the code in the
     languages you selected in the sidebar.")
}

# ---------- translation boxes and input customization ---------- #
translation_ui_func<-function(){
  fluidRow(
    column(
      width = 7,
     tags$div(class = 'intro','Translate From'),
     br(),
     boxPlus(
        solidHeader = FALSE,
        title = NULL,
        background = "blue",
        width = 12,
        #height = '250px',
        closable = FALSE,
        tags$code(textOutput(outputId = 'first_lang')),
        tags$style(type="text/css", "#first_lang {white-space: pre-line; padding-left: 25px;}")
     ),
     tags$div(class = 'intro','Translate To'),
     br(),
     boxPlus(
        solidHeader = FALSE,
        title = NULL,
        background = "blue",
        width = 12,
        #height = '250px',
        closable = FALSE,
        tags$code(textOutput(outputId = 'second_lang')),
        tags$style(type="text/css", "#second_lang {white-space: pre-line; padding-left: 25px;}")
      )    
    ),
    column(
      width = 5,
      # ---- selecting the function ---- #
      'Select function',
      selectInput(inputId = 'select_func',label = NULL,
                  choices = list_of_funcs),
      # ---- name of df ---- #
      'Name of dataframe or table',
      textInput(inputId = 'name_dataframe',label = NULL,
                value = 'lol_champions'),
      # ---- column selection ---- #
      'Pick your columns (upto 2)',
      pickerInput(inputId = 'name_cols',label = NULL,
                  choices = unique(colnames(lol_champions)),
                  options = list(
                    "max-options" = 2,
                    "max-options-text" = "No more!"
                    ), 
                  multiple = TRUE,
                  selected = c("name","damage")),
      # ---- value selection ---- #
      'Values (upto 2 for each column)',
      uiOutput('ui_values')
    )
  )
}
