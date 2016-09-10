$ = jQuery = require 'jquery'

module.exports = activate: (state) ->
  # Attach to editors
  $.get "https://raw.githubusercontent.com/GoogleChrome/css-triggers/master/data/blink.json", (res) ->
    csstriggers = JSON.parse(res)
    console.log(csstriggers)
    atom.workspace.observeTextEditors (editor) ->
      _editor = editor
      editor.onDidChange ->
        console.log("change")
        # Get Shadow DOM
        view = $(atom.views.getView(_editor))
        shadow = $(view[0].shadowRoot)
        # HEX and RGB values
        shadow.find(".css.property-name.type:not(.csstrigger-loaded)").each (i, el) ->
          console.log($(this))
          property = $(this).text().toLowerCase() + "-change"
          details = csstriggers.properties[property]
          console.log(details)
          if details isnt undefined
            console.log("here")
            values = ""
            if details.layout
              values += "csstrigger-layout "
            if details.paint
              values += "csstrigger-paint "
            if details.composite
              values += "csstrigger-composite"
            console.log(values)
            console.log("final this", $(this))
            $(this).html("<span class='csstrigger " + values + "'><span></span></span>" + $(this).text())
            $(this).addClass("csstrigger-loaded")
