make.cnames <- function(Labels){
    ## this makes names that work in C, where dots have special meanings.
    Unique.Names <- gsub("[.]","_",make.names(trimws(Labels), unique = TRUE, allow_ = TRUE),useBytes=TRUE)
    return(Unique.Names)
}

.GetTableName <- function(sbtab){
    ## the table title has to be in either one of the columns of row 1
    N <- names(sbtab)
    lN <- length(N)
    pattern <- "TableName='([^']+)'"
    m <- regexec(pattern, sbtab[1,], useBytes=TRUE)
    match <- regmatches(sbtab[1,],m)
    table.name <- ""
    for (i in c(1:lN)){
        if (length(match[[i]])>1){
            table.name <- match[[i]][2] # so the first experssion in parentheses
        } 
    }
    return(table.name)
}

.GetDocumentName <- function(sbtab){
    N <- names(sbtab)
    lN <- length(N)
    pattern <- "Document='([^']+)'"
    m <- regexec(pattern, sbtab[1,], useBytes=TRUE)
    match <- regmatches(sbtab[1,],m)
    document.name <- "Model"
    for (i in c(1:lN)){
        if (length(match[[i]])>1){
            document.name <- make.cnames(match[[i]][2]) # so the first experssion in parentheses
        } 
    }
    return(document.name)
}

.GetConservationLaws <- function(N){
    if (require(pracma)){
        M <- pracma::null(t(N))
        if (is.null(M)){
            return(NULL)
        } else if (all(dim(M)>1)){
            M <- t(pracma::rref(t(M)))
        } else {
            M <- M/max(M)
        }
        nr=M
        count=0
        f <- c(2,3,5,7)
        while (norm(nr-round(nr),type="F") > 1e-6 && count<length(f)){
            count <- count+1
            message(sprintf("nullspace is not represented by integers. \nTo make the mass conservation more readable, we multiply them by %i and round.",f[count]))
            nr <- nr*f[count]
        }
        Laws <- round(nr)
        n <- dim(Laws)[2]
        if (n>1){
            Laws <- Laws[,n:1] # reverse order of laws to avoid dependency issues between the laws.
        }
    } else {
        Laws=NULL
    }
    print(Laws)
    return(Laws)
}

AppendAmounts <- function(S,Quantity,QuantityName,Separator){
    n <- length(QuantityName)
    aq <- abs(as.numeric(Quantity))
    s <- paste(aq,QuantityName,sep="*",collapse=Separator)
    S <- paste0(S,s)
    return(S)
}

.GetLawText <- function(Laws,CompoundName,InitialValue){
    print(Laws)
    nLaws <- dim(Laws)[2]
    print(nLaws)
    nC <- length(CompoundName)
    I <- 1:nC
    ConLaw <- list()
    ConLaw[["Constant"]] <- vector(length=nLaws)
    ConLaw[["Eliminates"]] <- vector(length=nLaws)
    ConLaw[["Formula"]] <- vector(length=nLaws,mode="character")
    ConLaw[["ConstantName"]] <- vector(length=nLaws,mode="character")
    ConLaw[["Text"]] <- vector(length=nLaws,mode="character")
    a <- vector(length=nC,mode="logical")
    a[] <- TRUE # allowed replacement index...everything that is TRUE may be replaced by a conservation law expression
    for (j in 1:nLaws){
        l <- as.integer(round(Laws[,j]))
        p <- l>0
        n <- l<0
        LawTextP <- AppendAmounts("",l[p],CompoundName[p],"+")
        LawTextN <- AppendAmounts("",l[n],CompoundName[n],"-")
        ##message(sprintf("length of LawTextN: %i («%s»)\n",nchar(LawTextN),LawTextN))
        if (nzchar(LawTextN)){
            LawText <- paste(LawTextP,LawTextN,sep="-")
        }else{
            LawText <- LawTextP
        }        
        ## MaximumInitialValue <- max(InitialValue[(p|n)&a]) # the thing to be replaced has to appear in the law, but not replaced by previous laws.
        
        u <- which.max(InitialValue[(p|n)&a])
        k <- I[(p|n)&a][u]
        ##print(k)
        ##message(sprintf("Replacing compound %i («%s») by Conservation Law Expression.\n",k,CompoundName[k]))
        a[k] <- FALSE # this compound may not be replaced in the future
        Const <- as.numeric(l %*% InitialValue)
        ConLaw$ConstantName[j] <- sprintf("%s_ConservedConst",CompoundName[k])
        ConLaw$Text[j] <- paste(ConLaw$ConstantName[j],sub("1[*]","",LawText),sep=" = ")
        m <- (1:nC != k)

        ConLaw$Constant[j] <- Const
        ConLaw$Eliminates[j] <- k

        FormulaP <- AppendAmounts("", l[p&m], CompoundName[p & m],"+")
        FormulaN <- AppendAmounts("", l[n&m], CompoundName[n & m],"-")
        if (nzchar(FormulaN)){
            Formula <- paste(FormulaP,FormulaN,sep="-")
        }else{
            Formula <- FormulaP
        }
        ConLaw$Formula[j] <- gsub("1[*]","",Formula)
        message(LawText)
        message(sprintf("This will comment out compound %i («%s», initial value: %g), Conserved Constant = %f\n",k,CompoundName[k],InitialValue[k],Const))
    }
    return(ConLaw)
}

PrintSteadyStateOutputs <- function(Compound,ODE,Reaction,document.name){
    ss <- Compound$SteadyState
    RN <- row.names(Reaction)
    N <- length(RN)
    if (any(ss)){
        CName <- row.names(Compound)[ss]
        CID <- Compound$ID[ss]
        ODE <- ODE[ss]
        ## for working SBML, replace all flux names with the actual flux expressions:
        for (j in 1:N){
            ODE <- gsub(sprintf("\\<%s\\>",RN[j]),sprintf("(%s)",Reaction$Flux[j]),ODE)
        }
        ## ODE <- gsub("^[+]","",ODE)
        header <- character()
        header[1] <- sprintf("!!SBtabSBtabVersion='1.0'\tTableName='Output' TableTitle='These Outputs describe how well the SteadyState has been achieved' TableType='Quantity' Document='%s'",document.name)
        header[2] <- sprintf("!ID\t!Name\t!Comment\t!ErrorName\t!ErrorType\t!Unit\t!ProbDist\t!Formula")
        Id <- sprintf("YSS%s",CID)
        Name <- sprintf("%s_NetFlux",CName)
        ErrorName <- sprintf("GAMMA_%s",Id)        
        SuggestedMeasureOfEquilibrium <- c(header,sprintf("%s\t%s\tmeasures deviation from steady state\t%s\tWeight\tnM\tNormal\t%s",Id,Name,ErrorName,ODE))
        ssfname <- paste0(document.name,"_SteadyStateMetrics.tsv")
        cat(SuggestedMeasureOfEquilibrium,sep="\n",file=ssfname)
    }
}

.GetLogical <- function(Column){
    n <- length(Column)
    LC <- vector(mode = "logical", length = n)
    l10 <- grepl("^1$|^0$",Column)
    lTF <- grepl("^T(RUE)?$|^F(ALSE)?$",toupper(Column))
    LC[lTF] <- as.logical(Column[lTF])
    LC[l10] <- as.logical(as.numeric(Column[l10]))
    return(LC)
}


.GetReactions <- function(SBtab){    
    ID <- SBtab[["Reaction"]][["!ID"]]
    Formula <- SBtab[["Reaction"]][["!ReactionFormula"]]
    Name <- make.cnames(SBtab[["Reaction"]][["!Name"]])
    Flux <- SBtab[["Reaction"]][["!KineticLaw"]]
    IsReversible <- SBtab[["Reaction"]][["!IsReversible"]]
    ##kin <- strsplit(SBtab[["Reaction"]][["!KineticLaw"]],split="-")
    ##KinMat <- matrix(trimws(unlist(kin)),ncol=2,byrow=TRUE)
    ##Kinetic <- data.frame(forward=KinMat[,1],backward=KinMat[,2])
    ##Unit <- SBtab[["Reaction"]][["!Unit"]]
    Reaction <- data.frame(ID,Formula,Flux,IsReversible,row.names=Name)
    return(Reaction)
}

.GetConstants <- function(SBtab){
    if ("Constant" %in% names(SBtab)){
        ID <- SBtab[["Constant"]][["!ID"]]
        Name <- make.cnames(SBtab[["Constant"]][["!Name"]])
        Value <- SBtab[["Constant"]][["!Value"]]
        Constant <- data.frame(ID,Value,row.names=Name)
        if ("!Unit" %in% names(SBtab[["Constant"]])){
            Unit=SBtab[["Constant"]][["!Unit"]]
        } else {
            Unit=NULL;
        }
        Constant <- data.frame(ID,Value,Unit,row.names=Name)
        return(Constant)
    } else {
        message("There is no «Constant» Table in this model.")
        return(NULL)
    }
}

## this will at first be for logical vectors, not general yet
.OptionalColumn <- function(SBtab,Name,mode="logical"){
    n <- length(SBtab[["!ID"]])
    if (Name %in% names(SBtab)){
        Column <- switch(mode,
                         logical=.GetLogical(SBtab[[Name]]),
                         numeric=as.numeric(SBtab[[Name]]),
                         as.character(SBtab[[Name]])
                         )
    } else {
        Column <- vector(mode,length=n)
    }
    return(Column)
}

.GetCompounds <- function(SBtab){
    nComp <- length(SBtab[["Compound"]][["!ID"]])
    ID <- SBtab[["Compound"]][["!ID"]]
    Name <- make.cnames(SBtab[["Compound"]][["!Name"]])
    message("compound names:")
    print(Name)
    ## replace possible non-ascii "-"
    CleanIV <- gsub("−","-", SBtab[["Compound"]][["!InitialValue"]])
    InitialValue <- as.numeric(CleanIV);
    SteadyState <- .OptionalColumn(SBtab[["Compound"]],"!SteadyState","logical")
    Unit <- SBtab[["Compound"]][["!Unit"]]
    message("Units: ")
    print(Unit)
    message("---")
    Assignment <- .OptionalColumn(SBtab[["Compound"]],"!Assignment","character")
    IsConstant <- .OptionalColumn(SBtab[["Compound"]],"!IsConstant","logical")
    Interpolation <- .OptionalColumn(SBtab[["Compound"]],"!Interpolation","logical")
    Compound <- data.frame(ID,InitialValue,SteadyState,Unit,IsConstant,Assignment,Interpolation,row.names=Name)
    return(Compound)
}

.GetExpressions <- function(SBtab){
    if ("Expression" %in% names(SBtab)){
        ID <- SBtab[["Expression"]][["!ID"]]    
        Name <- make.cnames(SBtab[["Expression"]][["!Name"]])
        Formula <- SBtab[["Expression"]][["!Formula"]]
        Unit <- SBtab[["Expression"]][["!Unit"]]
        Expression <- data.frame(ID,Formula,Unit,row.names=Name)
        return(Expression)
    } else {
        message("There is no «Expression» Table in this model.")
        return(NULL)
    }
}

.GetParameters <- function(SBtab){
    ID <- SBtab[["Parameter"]][["!ID"]]
    nPar <- length(ID);
    if ("!Scale" %in% names(SBtab[["Parameter"]])){
        Scale <- SBtab[["Parameter"]][["!Scale"]]        
    }else{
        Scale <- vector(mode="character",len=nPar)
        Scale[] <- "log"
    }
    Name <- make.cnames(SBtab[["Parameter"]][["!Name"]])
    if ("!DefaultValue" %in% colnames(SBtab[["Parameter"]])){
        Value <- SBtab[["Parameter"]][["!DefaultValue"]]
    } else if ("!Value" %in% colnames(SBtab[["Parameter"]])){
        Value <- SBtab[["Parameter"]][["!Value"]]
    } else if ("!Mean" %in% colnames(SBtab[["Parameter"]])){
        Value <- SBtab[["Parameter"]][["!Mean"]]
    } else if ("!Median" %in% colnames(SBtab[["Parameter"]])){
        Value <- SBtab[["Parameter"]][["!Median"]]
    } else {
        print(colnames(SBtab[["Parameter"]]))
        stop("no usable Value column for Parameters found")
    }

    message("raw parameter values:")
    ##print(Value)
    message("---")
    nValue <- as.double(gsub("−","-",Value));
    print(nValue)
    message("---")
    Value <- nValue
    if (any(Scale %in% c("log","log10","natural logarithm","decadic logarithm","base-10 logarithm","logarithm","ln"))) {
        l <- Scale %in% c("log","logarithm","natural logarithm","ln")
        Value[l]<-exp(Value[l])
        l <- Scale %in% c("log10","decadic logarithm","base-10 logarithm")
        Value[l]<-10^Value[l]
    }
    Unit <- SBtab[["Parameter"]][["!Unit"]]
    Parameter <- data.frame(ID=ID,Value=Value,Unit=Unit,row.names=Name)
    print(names(Parameter))
    return(Parameter)
}

.GetOutputs <- function(SBtab){
    ID <- SBtab[["Output"]][["!ID"]]
    Name <- make.cnames(SBtab[["Output"]][["!Name"]])
    Formula <-  SBtab[["Output"]][["!Formula"]]
    Unit <- SBtab[["Output"]][["!Unit"]]
    Output <- data.frame(ID,Formula,Unit,row.names=Name)
    return(Output)
}

.GetCompartments <- function(SBtab){
    ID <- SBtab[["Compartment"]][["!ID"]]
    Name <- make.cnames(SBtab[["Compartment"]][["!Name"]])
    Size <-  SBtab[["Compartment"]][["!Size"]]
    Unit <- SBtab[["Compartment"]][["!Unit"]]
    Comp <- data.frame(ID,Size,Unit,row.names=Name)
    return(Comp)
}


.GetInputs <- function(SBtab){
    if ("Input" %in% names(SBtab)){
        if ("!ConservationLaw" %in% names(SBtab[["Input"]])){
            Disregard <- .GetLogical(SBtab[["Input"]][["!ConservationLaw"]])
            message("Some input parameters may be earlier detected Conservation Law constants: ")
            print(Disregard)
            message("---")
        } else {
            n <- length(SBtab[["Input"]][["!ID"]])
            Disregard <- vector(mode="logical",length=n)
        }
        ID <- SBtab[["Input"]][["!ID"]][!Disregard]
        Name <- make.cnames(SBtab[["Input"]][["!Name"]][!Disregard])
        DefaultValue <-  SBtab[["Input"]][["!DefaultValue"]][!Disregard]
        Unit <-  SBtab[["Input"]][["!Unit"]][!Disregard]
        
        Input <- data.frame(ID,DefaultValue,Unit,row.names=Name)
        return(Input)
    } else {
        message("There is no «Input» Table in this model.")
        return(NULL)
    }
}

.GetDefaults <- function(SBtab){
    if ("Defaults" %in% names(SBtab)){
        ID <- SBtab[["Defaults"]][["!ID"]]
        Name <- make.cnames(SBtab[["Defaults"]][["!Name"]])
        Unit <-  SBtab[["Defaults"]][["!Unit"]]
    } else {
        ID <- c("time","substance","volume","area","length")
        Name <- ID
        Unit <- c("millisecond","millimole","liter","nanometer^2","nanometer")
    }
    Defaults <- data.frame(ID,Unit,row.names=Name)
    return(Defaults)
}


UpdateODEandStoichiometry <- function(Term,Compound,FluxName,Expression,Input){
    l <- length(Term)
    J <- vector(mode="integer",len=l)
    C <- vector(mode="integer",len=l)
    
    ## TODO: j and n must be vectors, otherwise only the last matching Compound will be returned
    for (i in 1:l){
        ## find possible factors within string
        xb <- unlist(strsplit(trimws(Term[i]),"[* ]"))
        
        if (length(xb)>1){
            n <- round(as.numeric(xb[1]))
            compound <- make.cnames(xb[2])
        } else {
            compound <- make.cnames(xb[1])
            n <- 1
        }
        cat(sprintf("%i × %s",n,compound))
        if (compound %in% row.names(Compound)){
            j <- as.numeric(match(compound,row.names(Compound)))
            message(sprintf("\t\t\t(%s is compound %i)",compound,j))
        } else if (compound %in% row.names(Expression)){
            j <- (-1)
            message(sprintf("\t\t\t«%s» is a fixed expression, it has no influx. ODE will be unaffected, but the expression may be used in ReactionFlux calculations\n",compound))
        }else if (compound %in% row.names(Input)){
            j <- (-1)
            message(sprintf("\t\t\t«%s» is an input parameter (a parameter that represents a constant concentration of a substance outside of the model's scope), it has no influx. ODE will be unaffected, but the expression may be used in ReactionFlux calculations\n",compound))            
        } else if (compound %in% c("null","NULL","NIL","NONE","NA","Ø","[]","{}")) {
            message(sprintf("\t\t\t«%s» (Ø) is a placeholder to formulate degradation in reaction formulae.\n",compound))
            j <- (-2)
        } else {
            stop(sprintf("\t\t\t«%s» is neither in the list of registered compounds nor is it an expression\n",compound))                
        }
        J[i] <- j
        C[i] <- n
    }
    return(list(n=C,compound=compound,J=J))
}

NFlux <- function(n,RName){
    if (n>1){
        NF <- paste(as.character(n),RName,sep="*")
    } else if (n==1) {
        NF <- RName
    } else {
        print(n)
        stop("weird n.")
    }
    return(NF)
}

ParseReactionFormulae <- function(Compound,Reaction,Expression,Input){
    message(class(Reaction$Formula))
    lhs_rhs <- strsplit(as.vector(Reaction$Formula),"<=>")

    nC <- dim.data.frame(Compound)
    nR <- dim.data.frame(Reaction)
    ## stoichiometry matrix:
    N <- matrix(0,nrow=nC[1],ncol=nR[1])
    ##print(N)
    ODE<-vector(mode="character",length=nC[1])
    ## Names
    RName <- row.names(Reaction)
    CName <- row.names(Compound)
    lhs <- vector(mode="character",length=nR[1])
    rhs <- vector(mode="character",length=nR[1])
    
    for (i in 1:nR[1]){
        line=lhs_rhs[[i]]
        lhs[i]=trimws(line[1])
        rhs[i]=trimws(line[2])
        message(sprintf("Reaction %i:",i))
        cat(sprintf("line (a->b): «%s» ←→ «%s»\n",line[1],line[2]))
        a <- unlist(strsplit(line[1],"[+]"))
        b <- unlist(strsplit(line[2],"[+]"))
        message(" where a: ")
        print(a)
        message("   and b: ")
        print(b)

        ## the following two «for» blocks (1,2) operate by adding
        ## things to N and ODE. I don't see how to make them into a
        ## function without copying ODE and N a lot into that function
        ## and back into the caller; Weirdly the <<- operator did not
        ## work at all. But perhaps <<- is also bad practice.

        ## 1
        message("Products:")
        L <- length(b);
        Term <- UpdateODEandStoichiometry(b,Compound,RName[i],Expression,Input)
        for (k in 1:L){
            j <- Term$J[k]
            if (j>0){
                ODE[j] <- paste(ODE[j],NFlux(Term$n[k],RName[i]),sep="+")
                N[j,i] <- N[j,i] + Term$n[k]
            }
        }
        ## 2
        message("Reactants:")        
        L <- length(a);
        Term <- UpdateODEandStoichiometry(a,Compound,RName[i],Expression,Input)        
        for (k in 1:L){
            j <- Term$J[k]
            if (j>0){
                ODE[j] <- paste(ODE[j],NFlux(Term$n[k],RName[i]),sep="-")
                N[j,i] <- N[j,i] - Term$n[k]
            }
        }
    }
    message(sprintf("Number of compounds:\t%i\nNumber of Reactions:\t%i",nC[1],nR[1]))
    ModelStructure <- list(ODE=ODE,Stoichiometry=N,LHS=lhs,RHS=rhs)
    return(ModelStructure) 
}

PrintConLawInfo <- function(ConLaw,CompoundName,document.name){
    nLaws <- length(ConLaw$Text)
    header<-character(length=2)
    header[1] <- sprintf("!!SBtab\tDocument='%s' TableName='Suggested Input' TableTitle='The model has conservation laws that were automatically determined, these are the conserved constants' TableType='Quantity'",document.name)
    header[2] <- sprintf("!ID\t!Name\t!DefaultValue\t!Unit\t!ConservationLaw\t!Comment")
    SuggestedParameters <- c(header,sprintf("CLU%i\t%s\t%g\tnM\tTRUE\t%s",1:nLaws,ConLaw$ConstantName,ConLaw$Constant,ConLaw$Text))
    infname <- paste0(document.name,"_SuggestedInput.tsv")
    cat(SuggestedParameters,sep="\n",file=infname)

    header[1] <- sprintf("!!SBtab\tDocument='%s' TableName='Suggested Output' TableTitle='Automatically determined conservation laws remove state variables, these outputs make them observable' TableType='Quantity'",document.name)
    header[2] <- sprintf("!ID\t!Name\t!Comment\t!ErrorName\t!ErrorType\t!Unit\t!ProbDist\t!Formula")
    k <- ConLaw$Eliminates
    SuggestedOutput=c(header,sprintf("YCL%i\t%s_mon\tmonitors implicit state\tSD_YCL%i\tnot applicable\tnM\tnone\t%s",1:nLaws,CompoundName[k],1:nLaws,CompoundName[k]))
    outfname <- paste0(document.name,"_SuggestedOutput.tsv")
    cat(SuggestedOutput,sep="\n",file=outfname)
    message(sprintf("If you'd like to monitor omitted compounds, add this to the Output table: %s\n",outfname))
}

.make.vfgen <- function(H,Constant,Parameter,Input,Expression,Reaction,Compound,Output,ODE,ConLaw){
    vfgen <- list()    
    fmt <- list(const=" <Constant Name=\"%s\" Description=\"constant %s\" Value=\"%s\"/>",
                par=" <Parameter Name=\"%s\" Description=\"independent parameter %s\" DefaultValue=\"%g\"/>",
                input=" <Parameter Name=\"%s\" Description=\"input parameter %s\" DefaultValue=\"%s\"/>",
                total=" <Parameter Name=\"%s\" Description=\"conserved quantity eliminates %s as a state variable\" DefaultValue=\"%f\"/>",
                ConservationLaw=" <Expression Name=\"%s\" Description=\"derived from conservation law %i\" Formula=\"%s\"/>",
                expression=" <Expression Name=\"%s\" Description=\"defined expression %s\" Formula=\"%s\"/>",
                flux=" <Expression Name=\"%s\" Description=\"flux %s\" Formula=\"%s\"/>",
                comment="<!-- <StateVariable Name=\"%s\" Description=\"compound %s\" DefaultInitialCondition=\"%s\" Formula=\"%s\"/> -->",
                ode=" <StateVariable Name=\"%s\" Description=\"compound %s\" DefaultInitialCondition=\"%s\" Formula=\"%s\"/>",
                output=" <Function Name=\"%s\" Description=\"output %s\" Formula=\"%s\"/>")
    vfgen[["header"]] <- "<?xml version=\"1.0\" ?>"
    vfgen[["model"]] <- sprintf("<VectorField Name=\"%s\" Description=\"model created by an R script «sbtab_to_vfgen.R» (https://github.com/a-kramer/SBtabVFGEN)\">",H)
    ## Constants
    vfgen[["const"]] <- sprintf(fmt$const,row.names(Constant),Constant$ID,Constant$Value)
    ## Parameters
    vfgen[["par"]] <- sprintf(fmt$par,row.names(Parameter),Parameter$ID,Parameter$Value)
    ## Inputs
    vfgen[["input"]] <- sprintf(fmt$input,row.names(Input),Input$ID,Input$DefaultValue)
    ## Conservation Laws
    if (is.null(ConLaw)){
        vfgen[["ConservationLaw"]] <- NULL
        vfgen[["ConservationInput"]] <- NULL
        nLaws <- 0
    }else{                
        k <- ConLaw$Eliminates
        CName <- row.names(Compound)[k]
        vfgen[["ConservationInput"]] <- sprintf(fmt$total,ConLaw$ConstantName,CName,ConLaw$Constant)
        F <- sprintf("%s - (%s)",ConLaw$ConstantName,ConLaw$Formula)
        nLaws <- length(F)
        vfgen[["ConservationLaw"]] <- sprintf(fmt$ConservationLaw,CName,c(1:nLaws),F)
    }
                                        # Expressions and Reaction Fluxes
    vfgen[["expression"]] <- sprintf(fmt$expression,row.names(Expression),Expression$ID,Expression$Formula)
    vfgen[["flux"]] <- sprintf(fmt$flux,row.names(Reaction),Reaction$ID,Reaction$Flux)
                                        # ODE right-hand-sides
    nC <- dim.data.frame(Compound)
    CName <- row.names(Compound)
    for (i in 1:nC[1]){
        if (nLaws>0 && i %in% ConLaw$Eliminates){
            message(sprintf("StateVariable %s will be commented out as it was already defined as a Mass Conservation Law Expression.",CName[i]))
            vfgen[["ode"]][i] <- sprintf(fmt$comment,CName[i], Compound$ID[i], Compound$InitialValue[i],ODE[i])
        }else{
            vfgen[["ode"]][i] <- sprintf(fmt$ode,CName[i], Compound$ID[i], Compound$InitialValue[i],ODE[i])
        }
    }
    ## Output Functions
    vfgen[["function"]] <- sprintf(fmt$output,row.names(Output),Output$ID,Output$Formula)
    vfgen[["endmodel"]] <- "</VectorField>"
    return(vfgen)
}

NeuronUnit<-function(unit){
    unit <- gsub("^[ ]*1/","/",unit)
    unit <- gsub("[()]","",unit)
    unit <- gsub("[ ]*[*][ ]*","-",unit)
    return(unit)
}

OneOrMoreLines <- function(Prefix,Table,Suffix){
    if (!is.null(Table) && nrow(Table)>0){
        Names <- sprintf("%s %s %s",Prefix,paste0(row.names(Table),collapse=", "),Suffix)
    }else{
        return(character())
    }
    if (nchar(Names)<76){
        return(Names)
    }else{
        return(sprintf("%s %s %s",Prefix,row.names(Table),Suffix))
    }
}

.make.mod <- function(H,Constant,Parameter,Input,Expression,Reaction,Compound,Output,ODE,ConLaw){
    Mod <- list()    
    fmt <- list(const="\t%s = %s (%s) : a constant",
                par="\t%s = %g (%s): a kinetic parameter",
                input="\t%s  = %g (%s) : an input",
                total="\t%s = %g : the total amount of a conserved sub-set of states",
                ConservationLaw="\t%s = %s : conservation law",
                expression="\t%s : a pre-defined algebraic expression",
                flux="\t%s : a flux, for use in DERIVATIVE mechanism",
                comment="\t: Compound %s with ID %s and initial condition %g had derivative %s, but is calculated by conservation law.",
                state="\t%s (%s) : a state variable",
                ode="\t%s' = %s : affects compound with ID %s",
                reactigon="\t %s <-> %s (%s, %s)",
                output="\t%s = %s : Output ID %s",
                assignment="\t%s = %s : assignment for expression %s")
    ##    Mod[["header"]] <- "TITLE Mod file for componen"
    Mod[["TITLE"]] <- sprintf("TITLE %s",H)
    Mod[["COMMENT"]] <- sprintf("COMMENT\n\tautomatically generated from an SBtab file\n\tdate: %s\nENDCOMMENT",date())

    Range <- character()
    Range <- c(Range,OneOrMoreLines("\tRANGE",Input,": input"))
    Range <- c(Range,OneOrMoreLines("\tRANGE",Output,": output"))
    Range <- c(Range,OneOrMoreLines("\tRANGE",Expression,": assigned"))
    Range <- c(Range,OneOrMoreLines("\tRANGE",Compound,": compound"))

    Mod[["NEURON"]] <- c("NEURON {",
                         sprintf("\tSUFFIX %s : OR perhaps POINT_PROCESS ?",H),
                         Range,
                         ": USEION ca READ cai VALENCE 2 : sth. like this may be needed for ions you have in your model",
                         "}")
    
    l <- grepl("0$",row.names(Compound))
    if (any(l)) {
        message(sprintf("possibly problematic names: %s.",paste0(row.names(Compound)[l],collapse=", ")))
        stop("Compound names should not end in '0'. \nNEURON will create initial values by appending a '0' to the state variable names. \nShould your variables contain var1 and var10, NEURON will also create var10 and var100 from them, which will be in conflict with your names. Please choose different names in the source files (SBtab).")
    }
    ## Conservation Laws
    if (is.null(ConLaw)){
        ConservationLaw <- NULL
        ConservationInput <- NULL
        CName <- NULL
        nLaws <- 0
    }else{                
        k <- ConLaw$Eliminates
        CName <- row.names(Compound)[k]
        ConservationInput <- sprintf(fmt$total,ConLaw$ConstantName,ConLaw$Constant)
        F <- sprintf("%s - (%s)",ConLaw$ConstantName,ConLaw$Formula)
        nLaws <- length(F)
        ConservationLaw <- sprintf(fmt$ConservationLaw,CName,F)
    }
    Mod[["CONSTANT"]] <- c("CONSTANT {",
                           sprintf(fmt$const,row.names(Constant),Constant$Value, NeuronUnit(Constant$Unit)),
                           "}")
    l=grepl("/.*\\<second\\>",Parameter$Unit)
    if (any(l)){
        Parameter$Unit[l] <- gsub("\\<second\\>","millisecond",Parameter$Unit[l])
        Parameter$Value[l] <- Parameter$Value[l]/1e3;
    }
    Mod[["PARAMETER"]] <- c("PARAMETER {",                            
                            sprintf(fmt$par,row.names(Parameter),Parameter$Value, NeuronUnit(Parameter$Unit)),
                            sprintf(fmt$input,row.names(Input),Input$DefaultValue, NeuronUnit(Input$Unit)),
                            ConservationInput,
                            "}")

    
                                        # Expressions and Reaction Fluxes
    Mod[["ASSIGNED"]] <- c("ASSIGNED {",
                           "\ttime (millisecond) : alias for t",
                           sprintf(fmt$expression,row.names(Expression)),
                           sprintf(fmt$flux,row.names(Reaction)),
                           sprintf("\t%s : computed from conservation law",CName),
                           sprintf("\t%s : an observable",row.names(Output)),
                           "}")
    Assignment <- sprintf(fmt$assignment,row.names(Expression),Expression$Formula,Expression$ID)
    ##Mod[["flux"]] <- c("KINETIC kin",sprintf(fmt$flux,row.names(Reaction),Reaction$ID,Reaction$Flux)
                                        # ODE right-hand-sides
    nC <- dim.data.frame(Compound)
    CName <- row.names(Compound)
    STATE=vector(mode="character",length=nC[1])
    DERIVATIVE=vector(mode="character",length=nC[1])
    IVP=vector(mode="character",length=nC[1])
    for (i in 1:nC[1]){
        if (nLaws>0 && i %in% ConLaw$Eliminates){
            message(sprintf("MOD: StateVariable %s will be commented out as it was already defined as a Mass Conservation Law Expression.",CName[i]))
            STATE[i] <- sprintf("\t: %s is calculated via Conservation Law",CName[i])
            DERIVATIVE[i] <- sprintf(fmt$comment,CName[i], Compound$ID[i], Compound$InitialValue[i],ODE[i])
            IVP[i] <- sprintf("\t: %s cannot have initial values as it is determined by conservation law",CName[i])
        }else{
            STATE[i] <- sprintf(fmt$state,CName[i],NeuronUnit(Compound$Unit[i]))
            Right.Hand.Side <- sub("^[[:blank:]]*[+]","",ODE[i]) # remove leading plus signs, if present
            DERIVATIVE[i] <- sprintf(fmt$ode,CName[i], Right.Hand.Side,Compound$ID[i])
            IVP[i] <- sprintf("\t %s = %s : initial condition",CName[i],Compound$InitialValue[i])
        }
    }
    Mod[["EXPRESSION"]] <- c("PROCEDURE assign_calculated_values() {",
                             "\ttime = t : an alias for the time variable, if needed.",
                             ConservationLaw,
                             Assignment,
                             sprintf("\t%s = %s : flux expression %s",row.names(Reaction),Reaction$Flux,Reaction$ID),
                             "}")

    Mod[["STATE"]] <- c("STATE {",STATE,"}")
    Mod[["INITIAL"]] <- c("INITIAL {",IVP,"}")
    Mod[["BREAKPOINT"]] <- c("BREAKPOINT {","\tSOLVE ode METHOD cnexp",
                             "\tassign_calculated_values() : procedure",
                             "}") 
    Mod[["DERIVATIVE"]] <- c("DERIVATIVE ode {",DERIVATIVE,"}")
    ## Output Functions
    Mod[["FUNCTION"]] <- c("PROCEDURE observables_func() {",sprintf(fmt$output,row.names(Output),Output$Formula,Output$ID),"}")
    return(Mod)
}


.unit.kind <- function(kind){
    stopifnot(is.character(kind) && length(kind)==1)
    if (grepl("^(l|L|litre|liter)$",kind)){
        k <- "litre"
    } else if (grepl("^(mole?)$",kind)) {
        k <- "mole"
    } else if (grepl("^(m|meter|metre)$",kind)) {
        k <- "metre"
    } else if (grepl("^(kg|kilogram)$",kind)){
        k <- "kilogram"
    } else if (grepl("^(g|gram)$",kind)){
        k <- "gram"
    } else if (grepl("^(A|ampere)$",kind)){
        k <- "ampere"
    } else if (grepl("^(cd|candela)$",kind)){
        k <- "candela"
    } else if (grepl("^(s|second)$",kind)){
        k <- "second"
    } else if (grepl("^(K|kelvin)$",kind)){
        k <- "kelvin"
    } else {
        k <- "dimensionless"
    }
    return(k)
}

.unit.scale <- function(prefix){
    stopifnot(is.character(prefix) && length(prefix)==1)
    if (grepl("^G$|^giga$",prefix)){
        s <- 9
    } else if (grepl("^M$|^mega$",prefix)){
        s <- 6
    } else if (grepl("^k$|^kilo$",prefix)){
        s <- 3
    } else if (grepl("^h$|^hecto$",prefix)){
        s <- 2
    } else if (grepl("^d$|^deci$",prefix)){
        s <- -1
    } else if (grepl("^c$|^centi$",prefix)){
        s <- -2
    } else if (grepl("^m$|^milli$",prefix)){
        s <- -3
    } else if (grepl("^u$|^µ$|^micro$",prefix)){
        s <- -6
    } else if (grepl("^n$|^nano$",prefix)){
        s <- -9
    } else if (grepl("^p$|^pico$",prefix)){
        s <- -12
    } else if (grepl("^f$|^femto$",prefix)){
        s <- -15
    } else {
        s <- 0
    }
    return(s)
}

.unit.id.from.string <- function(unit.str,prnt=FALSE){
    uid <- unit.str
    uid <- sub("^1$","dimensionless",uid)
    uid <- gsub("1/","one_over_",uid)
    uid <- gsub("/","_per_",uid)
    uid <- gsub("[*[:blank:]]","_",uid)
    uid <- gsub("[()]","",uid)
    uid <- gsub("\\^2","_square",uid)
    uid <- gsub("\\^3","_cube",uid)
    uid <- gsub("\\^([0-9]+)","_to_the_power_of_\1",uid)
    uid <- make.names(uid,unique=FALSE)
    if (prnt){
        message("units in «!Unit» column:")
        print(unit.str)
        message("automatically created sbml unit ids:")
        print(uid)
    }
    return(uid)
}

## this will try its best to interpret strings like
## liter/(nmol ms)
## rules: 1. only one slash is allowed
##        2. M can be mega or mol/l
##        3. prefixes and units can be words or single letters
##        4. everything after a slash is the denominator
##        5. u is an accepted replacement for μ
## this retruns a data.frame with components as in the sbml standard:
## kind, multiplier, scale and exponent
## since there is only one slash,parentheses do nothing
## everything after a slash is the denominator, so: l/mol s is the same as (l)/(mol s)
## Remark: not very many units are understood.
.interpret.unit.from.string <- function(unit.str){
    stopifnot(length(unit.str)==1)
    .kind <- NULL
    .multiplier <- NULL
    .scale <- NULL
    .exponent <- NULL
    message(sprintf("---%11s---",unit.str))
    print(unit.str)
    a <- gsub("[()]","",unit.str)
    a <- gsub("molarity","mol l^-1",a);
    if (grepl("/",unit.str)){
        a <- unlist(strsplit(a,split="/",fixed=TRUE))
        message(sprintf("«%s» is interpreted as:\n\tNumerator «%s»\n\tDenominator: «%s»\n",unit.str,a[1],a[2]))
    }
    n <- length(a)
    stopifnot(n==1 || n==2)

    for (j in 1:n){
        b <- unlist(strsplit(a[j],split="[* ]"))
        for (u in b){
            pat <- paste0("^(G|giga|M|mega|k|kilo|c|centi|m|milli|u|μ|micro|n|nano|p|pico|f|femto)?",
                          "(l|L|liter|litre|g|gram|mole?|s|second|m|meter|metre|K|kelvin|cd|candela|A|ampere)",
                          "\\^?([-+]?[0-9]+)?$")
            ##print(pat)
            r <- regexec(pattern=pat,text=u) #,perl=TRUE)

            if (u == "1"){
                .u.s <- 0
                .u.k <- "dimensionless"
                x <- 1
            } else if (r[[1]][1] > 0){
                m <- unlist(regmatches(u, r))
                print(m)
                .u.s <- .unit.scale(m[2])
                .u.k <- .unit.kind(m[3])
                if (nchar(m[4])>0){
                    x <- switch(j,as.numeric(m[4]),-as.numeric(m[4]))
                }else{
                    x <- switch(j,1,-1)
                }
            } else {
                warning(sprintf("unit «%s» didn't match any pre-defined unit, because of «%s». (According to the limited [dumb] rules defined in this R script)",unit.str,u))
                .u.s <- 0
                .u.k <- "dimensionless"
                x <- 1
            }
            .multiplier <- c(.multiplier,1.0)
            .scale <- c(.scale,.u.s)
            .kind <- c(.kind,.u.k)
            .exponent <- c(.exponent,x)

            message(sprintf("«%s» has been interpreted as: (%s×10^(%i))^(%i)",u,.u.k,.u.s,x))
        }
    }
    ## print(.multiplier)
    ## print(.kind)
    ## print(.scale)
    ## print(.exponent)
    
    unit <- data.frame(scale=.scale,multiplier=.multiplier,exponent=.exponent,kind=.kind)
    print(unit)
    message(sprintf("---%-11s---","done"))

    return(unit)
}

.create.sbml.unit <- function(sbml,unit,id){
    n <- nrow(unit)
    unitdef <- Model_createUnitDefinition(sbml);
    UnitDefinition_setId(unitdef,id);
    for (i in 1:n){
        u <- UnitDefinition_createUnit(unitdef);
        Kind <- switch(unit$kind[i],litre="UNIT_KIND_LITRE",metre="UNIT_KIND_METRE",second="UNIT_KIND_SECOND",mole="UNIT_KIND_MOLE",gram="UNIT_KIND_GRAM","UNIT_KIND_DIMENSIONLESS")
        Unit_setKind(u, Kind);
        Unit_setExponent(u,unit$exponent[i]);
        Unit_setMultiplier(u,unit$multiplier[i]);
        Unit_setScale(u,unit$scale[i]);
    }
}

.unique.units <- function(sbml,Unit){
    U <- unique(Unit)
    uid <- .unit.id.from.string(U,prnt=TRUE)
    unit <- list()
    for (i in 1:length(uid)){
        unit[[i]] <- .interpret.unit.from.string(U[i])
        .create.sbml.unit(sbml,unit[[i]],uid[i])
    }
    names(unit) <- uid
    return(unit)
}


.sbtab.parameter.to.sbml <- function(sbml,Parameter){
    all.uid <- .unit.id.from.string(Parameter$Unit)
    num.parameters <- nrow(Parameter)
    Name <- row.names(Parameter)
    
    if ("Value" %in% names(Parameter)){
        Value <- as.numeric(Parameter$Value)
    } else if ("DefaultValue" %in% names(Parameter)) {
        Value <- as.numeric(Parameter$DefaultValue)
    } else {
        stop("Parameters have no Value column")
    }    
    for (i in 1:num.parameters){
        message(sprintf("adding SBtab parameter %i: «%s»",i,Name[i]))
        para <- Model_createParameter(sbml)
        Parameter_setId(para,Name[i])
        Parameter_setName(para,Name[i])
        
        this.unit.id <- all.uid[i]
        message(sprintf("unit of parameter %i (%s): «%s»",i,Name[i],this.unit.id))
        Parameter_setUnits(para,this.unit.id)
        Parameter_setValue(para,Value[i])
    }
}

.sbtab.compound.to.sbml <- function(sbml,Compound,CompName,SubstanceUnitID){
    all.uid <- .unit.id.from.string(Compound$Unit)
    num.species <- nrow(Compound)
    Name <- row.names(Compound)
    for (i in 1:num.species){
        print(Name[i])
        sp <- Model_createSpecies(sbml)
        this.unit.id <- all.uid[i]
        message(sprintf("unit of species %i (%s): «%s»",i,Name[i],this.unit.id))
        Species_setId(sp, Name[i])

        Species_setCompartment(sp, CompName)
        Species_setUnits(sp,SubstanceUnitID)
        Species_setInitialConcentration(sp, Compound$InitialValue[i])
        Ai <- Compound$Assignment[i]
        if (Compound$IsConstant[i]){
            Species_setBoundaryCondition(sp,"true")
            Species_setName(sp, Name[i])
        } else if (!grepl("^(0|FALSE|NONE|NULL)?$",Ai)){
            Species_setBoundaryCondition(sp,"true")
            Species_setName(sp, Ai)
        } else {
            Species_setName(sp, Name[i])
        }
    }
}

.sbtab.constant.to.sbml <- function(sbml,Constant){
    all.uid <- .unit.id.from.string(Constant$Unit)
    num.constants <- nrow(Constant)
    print(num.constants)
    Name <- row.names(Constant)
    for (i in 1:num.constants){
        message(sprintf("adding SBtab Constant %i: «%s»",i,Name[i]))
        print(Name[i])
        const <- Model_createParameter(sbml)
        Parameter_setId(const,Name[i])
        Parameter_setName(const,Name[i])
        this.unit.id <- all.uid[i]
        message(sprintf("unit of constant %i (%s): «%s»",i,Name[i],this.unit.id))
        Parameter_setUnits(const, this.unit.id)
        Parameter_setValue(const, as.numeric(Constant$Value[i]))
    }
}

.sbtab.reaction.to.sbml <- function(sbml,Reaction,Compartment){
    num.reactions <- nrow(Reaction)
    Name <- row.names(Reaction)
    OneCompartmentModel=FALSE;
    if (is.na(Compartment) || length(Compartment$ID==1)){
        OneCompartmentModel=TRUE;
    }
    AB <- strsplit(Reaction$Formula,split="<=>")
    for (i in 1:num.reactions){
        message(sprintf("adding reaction %i: «%s»",i,Name[i]))
        reaction <- Model_createReaction(sbml);

        Reaction_setId(reaction,Name[i]);
        Reaction_setName(reaction,Name[i]);
        Reaction_setReversible(reaction, Reaction$IsReversible[i]);
        
        message(sprintf("converting flux to mathml: «%s»",Reaction$Flux[i]))
        kl <- Reaction_createKineticLaw(reaction);
        Flux <- Reaction$Flux[i]
        if (OneCompartmentModel){
            Flux <- sprintf("(%s)*%s",Flux,Compartment$ID[1]);
            message("reaction rates in SBML need to have the unit «substance/time» rather than «concentration/time».\nSo conventional kinetics need to be multiplied by compartment volumes.");
            message("Since this model has only one Compartment, all kinetics will be multiplied by its volume for the SBML model.");
        }
        astMath <- parseL3Formula(Flux); # or: readMathMLFromString(mathXMLString);
        KineticLaw_setMath(kl, astMath);

        A <- trimws(strsplit(AB[[i]][1],"+",fixed=TRUE)[[1]])
        B <- trimws(strsplit(AB[[i]][2],"+",fixed=TRUE)[[1]])
        message("Reactants: ")
        print(A)
        message("Products: ")
        print(B)
        message("---")
        for (a in A){
            r<-regexec(pattern="([0-9]*)\\s*[*]?\\s*(\\w+)",text=a)
            m <- unlist(regmatches(a,r))
            print(m)
            RefName <- m[3]
            spr  <-  Reaction_createReactant(reaction)
            SimpleSpeciesReference_setSpecies(spr, RefName)
            if (nchar(m[2])>0){
                SpeciesReference_setStoichiometry(spr,as.numeric(m[2]))
            }
        }
        for (b in B){
            r<-regexec(pattern="([0-9]*)\\s*[*]?\\s*(\\w+)",text=b)
            m <- unlist(regmatches(b,r))
            print(m)
            RefName <- m[3]
            spr  <-  Reaction_createProduct(reaction)
            SimpleSpeciesReference_setSpecies(spr, RefName)
            if (nchar(m[2])>0){
                SpeciesReference_setStoichiometry(spr,as.numeric(m[2]))
            }
        }
    }
}

.sbtab.expression.to.sbml <- function(sbml,Expression,CompartmentName,Compound){
    all.uid <- .unit.id.from.string(Expression$Unit)
    num.species <- nrow(Expression)
    ExpressionName <- row.names(Expression)
    for (i in 1:num.species){
        print(ExpressionName[i])
        this.unit.id <- all.uid[i]
        message(sprintf("unit of expression %i (%s): «%s»",i,ExpressionName[i],this.unit.id))
        F <- Expression$Formula[i]
        if (grepl("^\\s*[+-]?[0-9]+\\s*$",F)){
            message("this expression is a constant, mapping it to a parameter")
            par <- Model_createParameter(sbml)
            Parameter_setId(par,ExpressionName[i]);
            Parameter_setName(par,ExpressionName[i]);
            Parameter_setValue(par, as.numeric(F));
            Parameter_setUnits(par, this.unit.id);        
        } else {
            pat <- paste0("^",ExpressionName[i],"$")
            if (any(grepl(pat,Compound$Assignment))){
                j <- grep(pat,Compound$Assignment)
                stopifnot(length(j)==1)
                VarName <- row.names(Compound)[j]
                if (is.na(VarName)) {
                    print(ExpressionName[i])
                    print(pat)
                    print(j)
                    print(row.names(Compound)[j])
                    print(row.names(Compound))
                    stop("Assignment not understood correctly.")
                }
            } else {
                sp <- Model_createSpecies(sbml);
                Species_setId(sp, ExpressionName[i]);
                Species_setName(sp, ExpressionName[i]);
                Species_setCompartment(sp, CompartmentName);
                Species_setBoundaryCondition(sp, "true")
                VarName <- ExpressionName[i]
            }
            astMath <- parseL3Formula(F);
            ##print(F)

            rule <- Model_createAssignmentRule(sbml)
            Rule_setVariable(rule,VarName)
            Rule_setMath(rule,astMath)
        }
    }
}

.sbtab.output.to.sbml <- function(sbml,Output,CompName,OutputUnitID){
    all.uid <- .unit.id.from.string(Output$Unit)
    num.species <- nrow(Output)
    Name <- row.names(Output)
    for (i in 1:num.species){
        message(sprintf("output %i:",i))
        print(Name[i])
        sp <- Model_createSpecies(sbml)
        this.unit.id <- all.uid[i]
        message(sprintf("unit of output %i (%s): «%s»",i,Name[i],this.unit.id))
        Species_setId(sp, Name[i])
        
        Species_setCompartment(sp, CompName)
        Species_setUnits(sp,OutputUnitID)
        Species_setInitialConcentration(sp, 0.0)
        Species_setBoundaryCondition(sp,"true")
        Species_setName(sp, Name[i])
##        SBase_appendAnnotation(sp,"<annotation>Output</annotation>")

        F <- Output$Formula[i]
        astMath <- parseL3Formula(F)
        #print(astMath)
        message(sprintf("output %i has formula:",i))
        print(F)
        message(formulaToString(astMath))
        rule <- Model_createAssignmentRule(sbml)
        Rule_setVariable(rule,Name[i])
        Rule_setMath(rule,astMath)
    }
}


.make.sbml <- function(H,Defaults,Constant=NULL,Parameter,Input=NULL,Expression=NULL,Reaction,Compound,Output,ODE,Comp){
    Doc <- SBMLDocument(2,4); # (LEVEL,VERSION)
    sbml  <-  SBMLDocument_createModel(Doc);
    Model_setId(sbml,H);
    ## default units
    ## substance
    for (i in 1:nrow(Defaults)){
        message(sprintf("default unit «%s» (%s)",Defaults$ID[i],Defaults$Unit[i]))
        unit <- .interpret.unit.from.string(Defaults$Unit[i])
        .create.sbml.unit(sbml,unit,Defaults$ID[i])
    }
    
    u.units <- .unique.units(sbml,c(Expression$Unit,Compound$Unit,Parameter$Unit,Constant$Unit,Input$Unit,Output$Unit,Comp$Unit))
    CompName <- row.names(Comp)
    print(CompName)
    for (i in 1:nrow(Comp)){
        this.unit.id <- .unit.id.from.string(Comp$Unit[i])
        comp <- Model_createCompartment(sbml)
        Compartment_setId(comp,Comp$ID[i])
        Compartment_setName(comp,CompName[i])
        Compartment_setUnits(comp,this.unit.id)
        Compartment_setVolume(comp,as.numeric(Comp$Size[i]))
    }
    if(!is.null(Constant)){
        .sbtab.constant.to.sbml(sbml,Constant)
    }
    .sbtab.compound.to.sbml(sbml,Compound,Comp$ID[1],"substance")
    .sbtab.parameter.to.sbml(sbml,Parameter)
    if (!is.null(Input)){
        .sbtab.parameter.to.sbml(sbml,Input)
    }
    .sbtab.reaction.to.sbml(sbml,Reaction,Comp)
    if (!is.null(Expression)){
        .sbtab.expression.to.sbml(sbml,Expression,Comp$ID[1],Compound)
    }
    if (!is.null(Output)){
        .sbtab.output.to.sbml(sbml,Output,Comp$ID[1],"substance")
    }

    return(Doc)
}


sbtab_from_ods <- function(ods.file){
    M <- readODS::read.ods(ods.file)    
    lM <- length(M)
    SBtab <- list(length=lM)
    document.name <- .GetDocumentName(M[[1]])
    table.name <- vector(length=lM)
    for (i in 1:lM){
        table.name[i] <- .GetTableName(M[[i]])        
        ## table.title <- .GetTableTitle(M[[i]])
        SBtab[[i]] <- M[[i]][-c(1,2),]
        names(SBtab[[i]]) <- M[[i]][2,]
    }
    
    names(SBtab) <- table.name
    print(names(SBtab))
    message(table.name)
    return(list(Document=document.name,Table=SBtab))
}

sbtab_from_tsv <- function(tsv.file){
    SBtab=list();
    
    header <- readLines(tsv.file[1],n=1);
    mD <- regexec("Document='([^']+)'", header)
    match <- regmatches(header,mD)
    document.name=make.cnames(match[[1]][2])
    message(sprintf("[tsv] file[1] «%s» belongs to Document «%s»\n\tI'll take this as the Model Name.\n",tsv.file[1],document.name))
    
    for (f in tsv.file){
        header <- readLines(f,n=1);
        mTN <- regexec("TableName='([^']+)'", header)
        match <- regmatches(header,mTN)
        TableName=match[[1]][2]
        SBtab[[TableName]] <- read.delim(f,as.is=TRUE,skip=1,check.names=FALSE,comment.char="%",blank.lines.skip=TRUE)
    }
    return(list(Document=document.name,Table=SBtab))
}

sbtab_to_vfgen <- function(SBtabDoc,cla=TRUE){
    options(stringsAsFactors = FALSE)
    ## message("The names of the SBtab list:")
    ## message(cat(names(SBtab),sep=", "))
    document.name <- SBtabDoc[["Document"]]
    message(sprintf("Document Name: %s.",document.name))
    
    SBtab <- SBtabDoc[["Table"]]
    cat(sprintf("SBtab has %i tables.\n",length(SBtab)))
    
    message("The names of SBtab[[1]]:")
    message(cat(colnames(SBtab[[1]]),sep=", "))
    Reaction <- .GetReactions(SBtab)
    Constant <- .GetConstants(SBtab)
    Expression <- .GetExpressions(SBtab)
    Compound <- .GetCompounds(SBtab)
    Parameter <- .GetParameters(SBtab)
    Output <- .GetOutputs(SBtab)
    Input <- .GetInputs(SBtab)
    Defaults <- .GetDefaults(SBtab)
    Comp  <- .GetCompartments(SBtab)
    if (require(libSBML)){
        ## definitely without conservation laws
        SBML <- .make.sbml(document.name,Defaults,Constant,Parameter,Input,Expression,Reaction,Compound,Output,ODE,Comp)
        file.xml <- sprintf("%s.xml",document.name)
        writeSBML(SBML,file.xml);
        stopifnot(file.exists(file.xml))
        sbml.text <- readLines(file.xml)
        sbml.text <- gsub('<ci>\\s*t(ime)?\\s*</ci>','<csymbol encoding="text" definitionURL="http://www.sbml.org/sbml/symbols/time"> time </csymbol>',sbml.text)
        cat(sbml.text,sep="\n",file=file.xml)
        message(sprintf("The sbml file has been named «%s».",file.xml))
    }

    
    ## some biological compounds are better represented as expressions/assignments or constants
    ## most will be state variables
    if ("IsConstant" %in% names(Compound)){
        IsConstant <- Compound$IsConstant
        message(sprintf("class(IsConstant): %s.\n",class(IsConstant)))
        CC <- Compound[IsConstant,]
        NewExpression <- data.frame(ID=CC$ID,Formula=CC$InitialValue,Unit=CC$Unit,row.names=row.names(CC))
        print(NewExpression)
        Expression=rbind(Expression,NewExpression)
        print(Expression)
        Compound <- Compound[!IsConstant,]
        print(row.names(Expression))
    }
    message("---")
    if ("Assignment" %in% names(Compound)){
        A <- Compound$Assignment
        U <- Compound$Unit
        l <- vector(mode="logical",len=length(A))
        F <- vector(mode="character",len=length(A))
        
        for (i in 1:length(A)){

            a <- A[i]
            if (a==""){
                ex<-NA
            }else{
                ex <- charmatch(a,Expression$ID)
            }
            ##print(a)
            ##print(ex)
            if (!is.na(ex)){
                l[i] <- TRUE
                F[i] <- row.names(Expression[ex,])
                message(sprintf("Compound «%s» is mapped to expression %i «%s» (matched by ID).\n",a,ex,Expression[ex,"Name"]))
            } else if (!is.na(Expression[a,"Formula"])){
                l[i] <- TRUE
                F[i] <- a
                message(sprintf("Compound «%s» is mapped to expression «%s» (matched by Name).\n",a,Expression[a,"Name"]))
            } #else {
                                        #    message(sprintf("«%s» is not an assignment.\n",a))
                                        #}
        }
        if (any(l)){
            NewExpression <- data.frame(ID=Compound[l,"ID"],Formula=F[l],Unit=U[l],row.names=row.names(Compound[l,]))
            print(NewExpression)
            Expression <- rbind(Expression,NewExpression)
            Compound <- Compound[!l,]
        }        
    }  
    
    ModelStructure <- ParseReactionFormulae(Compound,Reaction,Expression,Input)
    ODE <- ModelStructure$ODE    
    Laws <- .GetConservationLaws(ModelStructure$Stoichiometry)
    Reaction[["lhs"]] <- ModelStructure$lhs
    Reaction[["rhs"]] <- ModelStructure$rhs
    
    if (is.null(Laws) || cla==FALSE){
        nLaws <- 0
        ConLaw <- NULL
    } else {
        nLaws <- dim(Laws)[2]
        N <- ModelStructure$Stoichiometry
        message("Stoichiometric Matrix:")
        print(N)
        message("---")
        message(sprintf("Conservation Law dimensions:\t%i × %i\n",dim(Laws)[1],dim(Laws)[2]))
        message(sprintf("To check that the conservation laws apply: norm(t(StoichiometryMatrix) * ConservationLaw == %6.5f)",norm(t(N) %*% Laws),type="F"))
        ConLaw <- .GetLawText(Laws,row.names(Compound),Compound$InitialValue)
        PrintConLawInfo(ConLaw,row.names(Compound),document.name)
        if (require("hdf5r")){
            f5 <- h5file("ConservationLaws.h5",mode="w")
            f5[["ConservationLaws"]] <- t(Laws); # hdf5 will transpose this matrix again
            f5[["/Stoichiometry"]] <- N
            f5[["/Description"]]<-ConLaw$Text
            f5[["/Document"]]<-document.name
            f5[["/Constant"]]<-ConLaw$Constant
            f5[["/ConstantName"]]<-ConLaw$ConstantName
            f5[["/EliminatedCompounds"]]<-(ConLaw$Eliminates-1); # this is intended for C
            h5close(f5)
        } else {
            rownames(Laws)<-rownames(Compound)
            write.table(t(Laws),file="ConservationLaws.tsv",sep="\t",col.names=FALSE,row.names=FALSE)
            colnames(N)<-rownames(Reaction)
            rownames(N)<-rownames(Compound)
            write.table(N,file="Stoichiometry.tsv",sep="\t",col.names=FALSE,row.names=FALSE)            
        }
        ##print(t(Laws))
    }    
    PrintSteadyStateOutputs(Compound,ODE,Reaction,document.name)
    H <- document.name
    H <- sub("-",'_',H)
    vfgen <- .make.vfgen(H,Constant,Parameter,Input,Expression,Reaction,Compound,Output,ODE,ConLaw)
    fname<-sprintf("%s.vf",H)
    cat(unlist(vfgen),sep="\n",file=fname)
    message(sprintf("The vf content was written to: %s\n",fname))

    Mod <- .make.mod(H,Constant,Parameter,Input,Expression,Reaction,Compound,Output,ODE,ConLaw)
    fname<-sprintf("%s.mod",H)
    cat(unlist(Mod),sep="\n",file=fname)
    message(sprintf("The mod content was written to: %s\n",fname))

    
    return(vfgen)
}
