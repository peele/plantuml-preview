{$, ScrollView} = require 'atom-space-pen-views'
{Disposable, CompositeDisposable, BufferedProcess} = require 'atom'
path = require 'path'

setZoomAttr = (imgTag, zoom) ->
  if zoom
    imgTag.attr 'height', '100%'
    imgTag.attr 'width', '100%'
  else
    imgTag.removeAttr 'height'
    imgTag.removeAttr 'width'

editorForId = (editorId) ->
  for editor in atom.workspace.getTextEditors()
    return editor if editor.id?.toString() is editorId.toString()
  null

module.exports =
class PlantumlPreviewView extends ScrollView
  @content: ->
    @div class: 'plantuml-preview padded pane-item', tabindex: -1, =>
      @div class: 'plantuml-control', outlet: 'control', =>
        @input id: 'zoomToFit', type: 'checkbox', checked: atom.config.get('plantuml-preview.zoomToFit'), outlet: 'zoomToFit'
        @label 'Zoom To Fit'
      @div class: 'plantuml-container', outlet: 'container', =>
        @img outlet: 'image'

  constructor: ({@editorId}) ->
    super
    @editor = editorForId @editorId
    @disposables = new CompositeDisposable

  destroy: ->
    @disposables.dispose()

  attached: ->
    if @editor?
      saveHandler = =>
        @renderUml()

      @disposables.add @editor.getBuffer().onDidSave ->
        saveHandler()
      @renderUml()

  getPath: ->
    if @editor?
      @editor.getPath()

  getURI: ->
    if @editor?
      "plantuml-preview://editor/#{@editor.id}"

  getTitle: ->
    if @editor?
      "#{@editor.getTitle()} Preview"

  onDidChangeTitle: ->
    new Disposable()

  onDidChangeModified: ->
    new Disposable()

  renderUml: ->
    filePath = @editor.getPath()
    imgFile = filePath.replace path.extname(filePath), '.png'
    setZoomAttr @image, atom.config.get('plantuml-preview.zoomToFit')
    @image.removeAttr 'src'

    imgTag = @image
    @on 'change', '#zoomToFit', ->
      setZoomAttr imgTag, @checked

    exit = (code) ->
      imgTag.attr 'src', "#{imgFile}?time=#{Date.now()}"
      imgTag.show

    command = atom.config.get 'plantuml-preview.java'
    args = [
      '-jar',
      atom.config.get('plantuml-preview.jarLocation'),
      '-charset',
      @editor.getEncoding(),
      filePath
    ]
    new BufferedProcess {command, args, exit}
