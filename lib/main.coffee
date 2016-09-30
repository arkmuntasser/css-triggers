$ = jQuery = require 'jquery'

module.exports = activate: (state) ->
  $.get 'https://raw.githubusercontent.com/GoogleChrome/css-triggers/master/data/blink.json', (res) ->
    csstriggers = JSON.parse(res)

    atom.workspace.observeTextEditors (editor) ->
      _editor = editor
      view = $(atom.views.getView(_editor))
      shadow = $(view[0].shadowRoot)
      shorthands = ['margin', 'padding', 'border', 'font', 'background', 'overflow', 'transform']

      update = ->
        _editor = editor
        view = $(atom.views.getView(_editor))
        shadow = $(view[0].shadowRoot)
        markers = []
        lineHeight = if shadow.find('.line-number').length then shadow.find('.line-number')[0].getBoundingClientRect().height else 0
        hasMarkerContainer = shadow.find('.css-trigger-markers').length
        if hasMarkerContainer is 0
          shadow.find('.scroll-view .lines').append('<div class="css-trigger-markers no-css-triggers" />')
        shadow.find('.css-trigger-markers .css-trigger-marker').remove()
        trueHeight = shadow.find('.vertical-scrollbar .scrollbar-content').height()
        shadow.find('.css-trigger-markers').css({ height : trueHeight + 'px' })
        shadow.find('.css.property-name.support:not(.media), .scss.property-name.support:not(.media), .sass.property-name.support:not(.media)').each (i, el) ->
          line = $(this).closest('.line').attr('data-screen-row')
          top = (parseInt(line)) * lineHeight
          property = $(this).text().toLowerCase()

          for i in shorthands
            if property.indexOf(i) >= 0
              if i is 'border'
                if property isnt 'border-collapse'
                  if property.indexOf('-image') >= 0
                    if property.indexOf('-image-') < 0
                      property += '-repeat'
                  else
                    if property is 'border-radius'
                      property = 'border-bottom-left-radius'
                    else
                      if property is 'border'
                        property = 'border-bottom-width'
                      else
                        if property is 'border-color'
                          property = 'border-bottom-color'
                        else if property is 'border-style'
                          property = 'border-bottom-style'
                        else if property is 'border-width'
                          property = 'border-bottom-width'
              else if i is 'background'
                if property is 'background'
                  property += '-color'
              else if i is 'font'
                if property is 'font'
                  property += '-size'
              else if i is 'overflow'
                if property is 'overflow'
                  property += '-x'
              else if i is 'transform'
                if property isnt 'transform-origin' and property isnt 'transform-style'
                  property = 'transform'
              else
                if property is 'margin' or property is 'padding'
                  property += '-top'
              break

          key = property + '-change'
          triggers = csstriggers.properties[key]
          scrollTop = editor.getScrollTop()
          if triggers isnt undefined
            classes = property + ' '
            if triggers.layout
              classes += 'layout '
            if triggers.paint
              classes += 'paint '
            if triggers.composite
              classes += 'composite'
            marker = $('<div class="css-trigger-marker" data-css-trigger-line="' + line + '"><span></span></div>').addClass(classes).css({ top : top + 'px' })
            isNewMarker = shadow.find('[data-css-trigger-line="' + line + '"]').length
            if(isNewMarker is 0)
              markers.push(marker)
              shadow.find('.scroll-view .lines').addClass('yes-css-triggers')
              shadow.find('.css-trigger-markers').removeClass('no-css-triggers')
            else
              shadow.find('[data-css-trigger-line="' + line + '"]').css({ top : top + 'px' })
        shadow.find('.css-trigger-markers').append(markers)

      scrollUpdate = ->
        _editor = editor
        view = $(atom.views.getView(_editor))
        shadow = $(view[0].shadowRoot)
        scrollTop = editor.getScrollTop()
        update()
        shadow.find('.css-trigger-markers').css({ 'transform' : 'translate3d(0,-' + scrollTop +  'px,0)' });

      editor.onDidChangeScrollTop ->
        scrollUpdate()

      editor.onDidChange ->
        update()

      editor.onDidStopChanging ->
        update()
