library(stringr)
`%n%` = knitr:::`%n%`

eng_bash = function(options) 
{
  engine = options$engine

  pre = paste("cd", options$root)

  code = paste('-c', shQuote(paste(c(pre,options$code), collapse = '\n')))
  
  code = paste(options$engine.opts, code)
  cmd = options$engine.path %n% engine
  out = if (options$eval) 
        {
          #message('running: ', cmd, ' ', code)
          system2(cmd, code, stdout = TRUE, stderr = TRUE)
        } else {
          ''
        }
  # chunk option error=FALSE means we need to signal the error
  if (!options$error && !is.null(attr(out, 'status')))
    stop(paste(out, collapse = '\n'))
  
  if (!is.null(options$reppat))
    out = str_replace(out,options$reppat,"")

  if (length(out) > 25)
    out = c(out[1:25], "", "...")

  knitr:::engine_output(options, options$code, out)
}

knit_engines$set(bash = eng_bash)