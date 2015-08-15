{$, ScrollView} = require 'atom-space-pen-views'
{Disposable, CompositeDisposable, BufferedProcess} = require 'atom'
path = null
fs = null

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
        @setZoomFit(checked)
      @on 'change', '#zoomToFit', ->
        checkHandler(@checked)

      saveHandler = =>
        @renderUml()

      @disposables.add @editor.getBuffer().onDidSave ->
        saveHandler()
      if atom.config.get 'plantuml-preview.bringFront'
        @disposables.add atom.workspace.onDidChangeActivePaneItem (item) =>
          if item is @editor
              pane = atom.workspace.paneForItem(this)
              pane.activateItem this

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

  addImages: (imgFiles, time) ->
    displayFilenames = atom.config.get('plantuml-preview.displayFilename')
    for file in imgFiles
      if displayFilenames
        div = $('<div/>')
          .attr('class', 'filename')
          .text("#{file}")
        @container.append div
      img = $('<img/>')
        .attr('class', 'uml-image')
        .attr('src', "#{file}?time=#{time}")
      @container.append img
    @setZoomFit(@zoomToFit.is(':checked'))
    @container.show

  removeImages: ->
    @container.empty()

  setZoomFit: (checked) ->
    if checked
      @container.find('.uml-image').addClass('zoomToFit')
    else
      @container.find('.uml-image').removeClass('zoomToFit')

  getFilenames: (directory, defaultName, contents) ->
    path ?= require 'path'
    filenames = []
    defaultFilename = path.join(directory, defaultName)
    defaultCount = 0
    for uml in contents.split(///@enduml///i)
      if uml.trim() == ''
        continue

      currentFilename = path.join(directory, defaultName)
      currentExtension = '.png'
      pageCount = 1

      filename = uml.match ///@startuml([^\n]*)\n///i
      if filename?
        filename = filename[1].trim()
        if filename != ''
          if path.extname(filename)
            currentExtension = path.extname filename
          else
            currentExtension = '.png'
          currentFilename = path.join(directory, filename.replace(currentExtension, ''))

      if (currentFilename == defaultFilename)
        if defaultCount > 0
          countStr = defaultCount + ''
          countStr = '000'.substring(countStr.length) + countStr
          newfile = "#{currentFilename}_#{countStr}#{currentExtension}"
          filenames.push(newfile) unless newfile in filenames
        else
          newfile = currentFilename + currentExtension
          filenames.push(newfile) unless newfile in filenames
        defaultCount++
      else
        newfile = currentFilename + currentExtension
        filenames.push(newfile) unless newfile in filenames

      for line in uml.split('\n')
        if line.match ///^[\s]*(newpage)///i
          countStr = pageCount + ''
          countStr = '000'.substring(countStr.length) + countStr
          newfile = "#{currentFilename}_#{countStr}#{currentExtension}"
          filenames.push(newfile) unless newfile in filenames
          pageCount++

    filenames

  renderUml: ->
    path ?= require 'path'
    fs ?= require 'fs-plus'
    filePath = @editor.getPath()

    imgFiles = @getFilenames path.dirname(filePath), path.basename(filePath, path.extname(filePath)), @editor.getText()

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
        @addImages imgFiles, Date.now()
        return

    exitHandler = (files) =>
      @addImages(files, Date.now())
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
      args.push '-graphvizdot', dotLocation
    args.push filePath

    @removeImages()
    new BufferedProcess {command, args, exit}
