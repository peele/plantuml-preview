{$, ScrollView} = require 'atom-space-pen-views'
{Disposable, CompositeDisposable, BufferedProcess} = require 'atom'
path = require 'path'
fs = require 'fs-plus'

editorForId = (editorId) ->
  for editor in atom.workspace.getTextEditors()
    return editor if editor.id?.toString() is editorId.toString()
  null

module.exports =
class PlantumlPreviewView extends ScrollView
  @content: ->
    @div class: 'plantuml-preview padded pane-item', tabindex: -1, =>
      @div class: 'plantuml-control', outlet: 'control', =>
        @input id: 'zoomToFit', type: 'checkbox', outlet: 'zoomToFit'
        @label 'Zoom To Fit'
      @div class: 'plantuml-container', outlet: 'container'

  constructor: ({@editorId}) ->
    super
    @editor = editorForId @editorId
    @disposables = new CompositeDisposable

  destroy: ->
    @disposables.dispose()

  attached: ->
    if @editor?
      @zoomToFit.attr('checked', atom.config.get('plantuml-preview.zoomToFit'))
      checkHandler = (checked) =>
        @setZoomAttr(checked)
      @on 'change', '#zoomToFit', ->
        checkHandler(@checked)

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

  addImages: (imgFiles) ->
    for file in imgFiles
      image = "<img class=\"uml-image\" src=\"#{file}?time=#{Date.now()}\"/>"
      @container.append image
    @setZoomAttr(@zoomToFit.is(':checked'))
    @container.show

  removeImages: ->
    @container.empty()

  setZoomAttr: (checked) ->
    if checked
      @container.find('.uml-image').attr('height', '100%')
      @container.find('.uml-image').attr('width', '100%')
    else
      @container.find('.uml-image').removeAttr('height')
      @container.find('.uml-image').removeAttr('width')

  renderUml: ->
    filePath = @editor.getPath()
    imgBase = filePath.replace path.extname(filePath), ''

    imgFiles = [imgBase + '.png']
    count = 1
    for line in @editor.getText().split('\n')
      if line.match ///^[\s]*(newpage)///i
        countStr = count + ''
        countStr = '000'.substring(countStr.length) + countStr
        imgFiles.push "#{imgBase}_#{countStr}.png"
        count++

    upToDate = true
    fileTime = fs.statSync(filePath).mtime
    for image in imgFiles
      if fs.isFileSync(image)
        if fileTime > fs.statSync(image).mtime
          upToDate = false
          break
      else
        upToDate = false
        break
    if upToDate
        @removeImages()
        @addImages imgFiles
        return

    exitHandler = (files) =>
      @addImages(files)
    exit = (code) ->
      exitHandler imgFiles

    command = atom.config.get 'plantuml-preview.java'
    args = [
      '-jar',
      atom.config.get('plantuml-preview.jarLocation'),
      '-charset',
      @editor.getEncoding()
    ]
    dotLocation = atom.config.get('plantuml-preview.dotLocation')
    if dotLocation != ''
      args.push '-graphvizdot'
      args.push dotLocation
    args.push filePath

    @removeImages()
    new BufferedProcess {command, args, exit}
