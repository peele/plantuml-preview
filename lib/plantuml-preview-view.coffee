{$, ScrollView} = require 'atom-space-pen-views'
{Disposable, BufferedProcess} = require 'atom'
path = require 'path'

setZoomAttr = (imgTag, zoom) ->
  if zoom
    imgTag.attr 'height', '100%'
    imgTag.attr 'width', '100%'
  else
    imgTag.removeAttr 'height'
    imgTag.removeAttr 'width'

module.exports =
class PlantumlPreviewView extends ScrollView
  @content: ->
    @div class: 'plantuml-preview padded pane-item', tabindex: -1, =>
      @div class: 'plantuml-control', outlet: 'control', =>
        @input id: 'zoomToFit', type: 'checkbox', checked: atom.config.get('plantuml-preview.zoomToFit'), outlet: 'zoomToFit'
        @label 'Zoom To Fit'
      @div class: 'plantuml-container', outlet: 'container', =>
        @img outlet: 'image'

  constructor: ({@filePath}) ->
    super

  attached: ->
    imgFile = @filePath.replace path.extname(@filePath), '.png'
    setZoomAttr @image, atom.config.get('plantuml-preview.zoomToFit')

    imgTag = @image
    @on 'change', '#zoomToFit', ->
      setZoomAttr imgTag, @checked

    exit = (code) ->
      imgTag.attr 'src', "#{imgFile}?time=#{Date.now()}"
      imgTag.show

    command = atom.config.get 'plantuml-preview.java'
    args = ['-jar', atom.config.get('plantuml-preview.jarLocation')]
    args = args.concat atom.config.get('plantuml-preview.additionalArgs').split(/\s+/)
    args = args.concat @filePath
    new BufferedProcess {command, args, exit}

  getPath: -> @filePath

  getURI: -> @filePath

  getTitle: -> "#{path.basename(@getPath())} Preview"

  onDidChangeTitle: ->
    new Disposable()

  onDidChangeModified: ->
    new Disposable()
