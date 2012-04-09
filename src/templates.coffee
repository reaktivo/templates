jade = require 'jade'
fs = require 'fs'
path = require 'path'

production = (process.env.NODE_ENV is not "production")

module.exports = (options) ->
  options.namespace or= "window.templates"
  options.url or= "/templates.js"
  options.src or= path.join process.cwd(), "templates"
  runtimePath = path.join __dirname, 'runtime.js'
  runtime = fs.readFileSync(runtimePath).toString()
  
  templates = null  
  
  refresh = (dir = "", templates = {}) ->
    prevDir = process.cwd()
    process.chdir(options.src)
    dirpath = path.join options.src, dir
    fs.readdirSync(dirpath).forEach (filename) ->
      filepath = path.join options.src, dir, filename
      if fs.statSync(filepath).isDirectory()
        templates[filename] = {}
        refresh path.join(dir, filename), templates[filename]
      else
        template = fs.readFileSync filepath
        basename = path.basename filename, path.extname(filename)
        key = basename
        opts = 
          client: true
          compileDebug: not production
          filename: path.join dir, filename
        templates[key] = jade.compile(template, opts).toString()
    process.chdir prevDir
    templates
  
  build = ->
    str = runtime + "\n"
    str += "#{options.namespace} || (#{options.namespace} = {})\n"
    walk = (prefix, templates) ->  
      for key, template of templates
        p = "#{prefix}['#{key}']"
        str += "#{p} = "
        if typeof template is "string"
          str += "#{template}\n"
        else
          str += "{}\n"
          walk(p, template)
    walk("#{options.namespace}", refresh())
    str = unescape str
    if production
      parser = require('uglify-js').parser
      uglify = require('uglify-js').uglify
      ast = parser.parse(str)
      ast = uglify.ast_mangle(ast)
      ast = uglify.ast_squeeze(ast)
      str = uglify.gen_code(ast)
    str
      
    
  get = ->
    if templates is null or not production
      templates = do build
    templates
  
  (req, res, next) ->
    if req.url == options.url
      res.send get(), {'Content-Type': 'application/javascript'}
    else
      do next