# source the helper script which contains required libraries etc.
source('crypt_helper.R')
source('ui_layout_body.R')

# ---------- HEADER ---------- #

dbHeader <- dashboardHeaderPlus(
                title = tags$b("CRYPT"),
                titleWidth = 328,
                tags$li(img(src = 'full_logo_white-01.png',
                            height="40px",
                            style="margin:10px 540px 0px 100px"),
                            class = "dropdown"),
                tags$li(tags$a(href = "https://github.com/bytecastle/crypt2",
                               img(src = "github_icon.png",height = "35px",
                                   style="margin:10px")), class = "dropdown")
) #header end


# ---------- SIDEBAR ---------- #

sidebar <- dashboardSidebar(
  width = 370,
  br(),
  br(),
  fluidRow(tags$div(id = "title-icon",column(width=8,offset = 1,icon("wrench"),"Customization"))),
  br(),
  fluidRow(column(width = 9,offset = 1,
                  selectInput('select_lang1', 'Select Language',
                              choices = languages),
                  uiOutput('ui_select_module'),
                  uiOutput('ui_select_target'),
                  uiOutput('ui_select_target_module')
  )),
  tags$hr(),
  div(id = "feedback",
  p("If you would like to know more about ByteCastle or Crypt or would like to 
    contribute, feel free to email me at",
  tags$a("bytecastle2019@gmail.com",href = "mailto:bytecastle2019@gmail.com")))
) #sidebar end


# ---------- BODY ---------- #

body<-dashboardBody( # body start
  
  # ---------- INCLUDING CSS & SHINYJS ---------- #
  
  includeCSS('crypt_style.css'),
  useShinyjs(),

  # ---------- TRANSLATION CENTAL ---------- #
  
  fluidRow(
    tags$div(id = "title-icon",
    column(width=5,icon(name="transfer",lib = "glyphicon"),"Translation")
    #column(width=2,icon(name="info-sign","glyphicon-3x",lib = "glyphicon"))
  )), #row end for headings
  br(),
  fluidRow(
    boxPlus(
      #box - design
      solidHeader = FALSE,
      title = NULL,
      background = NULL,
      width = 12,
      status = "primary",
      br(),
      tags$div(class = "intro",intro_func()),
      tags$div(class = "intro-divider"),
      br(),
      translation_ui_func()
     ) #box end
  ),  #row end

  # ---------- OUTPUT AREA ---------- #
  
  fluidRow(
    tags$div(id = "title-icon",
    column(width=9,icon(name="edit"),"Output"),
    column(width=2,icon("lightbulb-o"),"Tips"))
  ), 
  br(),
  fluidRow(
    boxPlus(title = "Expected Output",
            status = "primary",
            width = 9,
            collapsible = FALSE,
            closable = FALSE,
            height = 400,
            formattableOutput('output_one')),
    boxPlus(title = NULL,
            status = "primary",
            width = 3,
            height = 400,
            tags$br(uiOutput('tips_text')))
  )
) #1 body end


# ---------- UI ---------- #
ui<-dashboardPagePlus(dbHeader,sidebar,body,skin = "black",
                      enable_preloader = TRUE,
                      sidebar_fullCollapse = TRUE,
                      title = "ByteCastle")


# ---------- SERVER ---------- #
server<-function(input,output,session){

  #select module for the 1st lang
  output$ui_select_module <- renderUI({
    req(input$select_lang1)
    choices <- lang_pack(input$select_lang1)
    selectInput('select_mod1', 'Select Library', 
                choices = choices)
  })
  
  #select 2nd lang
  output$ui_select_target <- renderUI({
    req(input$select_lang1)
    choices<-languages[!(languages %in% input$select_lang1)]
    selectInput('select_lang2','Translate To',
                choices = choices)
  })
  
  #select module for the 2nd lang
  output$ui_select_target_module <- renderUI({
    req(input$select_lang2)
    choices <- lang_pack(input$select_lang2)
    selectInput('select_mod2','Select Library',
                choices = choices)
  })
  
 #select values for display
  output$ui_values <- renderUI({
      choice_s<-get_values(input$name_cols[1],input$name_cols[2])
      names(choice_s)<-c(input$name_cols[1],input$name_cols[2])
      pickerInput(
      inputId = "name_values",
      label = NULL, 
      choices = choice_s,
      options = list(
        "max-options-group" = 2),
      multiple = TRUE,
      selected = c("'Ahri'","'Akali'",2,3)
    )    
  })
  
  #display appropriate tips
  output$tips_text<-renderUI({
    cryptdata_filtered<-cryptdata %>% 
      filter(func == input$select_func, 
             lang %in% c(input$select_lang1,input$select_lang2), 
             mod %in% c(input$select_mod1,input$select_mod2)) %>% 
      select(tips) %>% distinct()
    tip<-cryptdata_filtered$tips
    tags$ul(
      tags$br(),
      if(!is.na(tip[1])){
        tags$li( tip[1])
      },
      tags$br(),
      if(!is.na(tip[2])){
        tags$li( tip[2])
      }
    )
  })
  
  # display code for 1st language 
  output$first_lang<-renderText({
    req(input$select_func,input$select_lang1,input$select_mod1,
          input$name_values,input$name_dataframe,
          input$name_cols[1],input$name_cols[2])
    x<-lock_and_load_syntax(funct = input$select_func,
                          language = input$select_lang1,
                          module = input$select_mod1,
                          values = input$name_values,
                          nameFrame = input$name_dataframe,
                          nameCol1 = input$name_cols[1],
                          nameCol2 = input$name_cols[2])
    choices<-get_values(input$name_cols[1],input$name_cols[2])
      if(input$select_lang1 == 'Postgresql'){
      x<-ifelse(is.numeric(choices$first_choice),gsub('type1','INTEGER',x),gsub('type1','VARCHAR',x))
      x<-ifelse(is.numeric(choices$second_choice),gsub('type2','INTEGER',x),gsub('type2','VARCHAR',x))
      return(x)
    } else {
      return(x)
    }
  })

  # display code for 2nd language
  output$second_lang<-renderText({
    req(input$select_func,input$select_lang2,input$select_mod2,
        input$name_values,input$name_dataframe,
        input$name_cols[1],input$name_cols[2])
    x<-lock_and_load_syntax(funct = input$select_func,
                         language = input$select_lang2,
                         module = input$select_mod2,
                         values = input$name_values,
                         nameFrame = input$name_dataframe,
                         nameCol1 = input$name_cols[1],
                         nameCol2 = input$name_cols[2])
    choices<-get_values(input$name_cols[1],input$name_cols[2])
    if(input$select_lang2 == 'Postgresql'){
      x<-ifelse(is.numeric(choices$first_choice),gsub('type1','INTEGER',x),gsub('type1','VARCHAR',x))
      x<-ifelse(is.numeric(choices$second_choice),gsub('type2','INTEGER',x),gsub('type2','VARCHAR',x))
      return(x)
    } else {
      return(x)
    }
  })
  
  # 1st output
  output$output_one<-renderFormattable({
    x <- lock_and_load_syntax(funct = input$select_func,
                            language = "R",
                            module = "dplyr",
                            values = input$name_values,
                            nameFrame = "lol_champions",
                            nameCol1 = input$name_cols[1],
                            nameCol2 = input$name_cols[2])
    df <- eval(parse(text = x))
    formattable(head(df),align = c("l",rep("r",ncol(df)-1)))
  })
  
  
} #end of server function


# TO RUN THE APP
shinyApp(ui,server)