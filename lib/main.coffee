$ = jQuery = require 'jquery'

module.exports = activate: (state) ->
  $.get 'https://raw.githubusercontent.com/GoogleChrome/css-triggers/master/data/blink.json', (res) ->
    csstriggers = JSON.parse(res)

    atom.workspace.observeTextEditors (editor) ->
      update = ->
        _editor = editor
        view = $(atom.views.getView(_editor))
        shadow = $(view[0].shadowRoot)
        markers = []
        lineHeight = shadow.find('.line-number')[0].getBoundingClientRect().height
        hasMarkerContainer = shadow.find('.css-trigger-markers').length
        if hasMarkerContainer is 0
          shadow.find('.scroll-view .lines').append('<div class="css-trigger-markers" />')
        trueHeight = shadow.find('.vertical-scrollbar .scrollbar-content').height()
        shadow.find('.css-trigger-markers').css({ height : trueHeight + 'px' })
        shadow.find('.css.property-name.support').each (i, el) ->
          line = $(this).closest('.line').attr('data-screen-row')
          top = (parseInt(line)) * lineHeight
          property = $(this).text().toLowerCase() + '-change'
          triggers = csstriggers.properties[property]
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

      update()
