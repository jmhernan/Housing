# Function to set data file variable paths and names in working enviroment 
# inputs: "sha_data", "kcha_data"

 set_data_envr = function(data) {
    lapply(seq_along(METADATA[[data]]), 
           function(x) {
            assign(names(METADATA[[data]][x]), METADATA[[data]][[x]], envir=.GlobalEnv)
        }
    )
 }
 


