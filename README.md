# Templates

Templates is a jade template prepackager for [Express](http://expressjs.com), inspired by [Jammit](http://documentcloud.github.com/jammit)
Templates is written in coffeescript by [Marcel Miranda](http://reaktivo.com).

[Source Code](https://github.com/reaktivo/templates)

## Installation

    npm install templates


## Usage

Considering your project directory structure is like the following:

    app.js
    views/
    templates/
      notification/
        panel.jade
      profile.jade
    
### Server

    var templates = require 'templates'

    // Create express app
    var app = express.createServer()

    app.use(templates({
      
      // src is the directory where jade template files are stored
      src: __dirname + "/templates",
      
      // url is the url the request will respond to
      url: "/templates.js",
      
      // namespace is the javascript object the 
      // templates will be attached to
      namespace: "window.templates"
      
    }))

### Client
  
    <!-- Add templates script to page -->
    <script src="/templates.js"></script>
    
    <!-- Use templates -->
    <script>
      
      templates.profile({name: "John", age: 25})
      // Will return a html string based on templates/profile.jade
      
      templates.notification.panel({title: "Error", message: "Could not log in"})
      // Will return a html string based on templates/notification/panel.jade
      
    </script>
  
## Production

Templates will look for the process.env.NODE_ENV to see if working on production environment.
When running on production, Templates will automatically compress the templates file using uglify-js.
When not running on production, Templates will leave jade's compileDebug option to true, which leaves line numbers for debugging purposes.

Copyright © 2012 Marcel Miranda. See LICENSE for further details.