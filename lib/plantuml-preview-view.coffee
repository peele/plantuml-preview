{$, ScrollView} = require 'atom-space-pen-views'
{Disposable, CompositeDisposable, BufferedProcess} = require 'atom'
clipboard = null
nativeimage = null
path = null
fs = null
os = null

editorForId = (editorId) ->
  for editor in atom.workspace.getTextEditors()
    return editor if editor.id?.toString() is editorId.toString()
  null

settingsError = (message, setting) ->
  options = {
    detail: "Verify '#{setting}' in settings.",
    buttons: [{
        text: 'Open Package Settings',
        onDidClick: -> atom.workspace.open('atom://config/packages/plantuml-preview', searchAllPanes: true)
    }],
    dismissable: true
  }
  atom.notifications.addError "plantuml-preview: #{message}", options

module.exports =
class PlantumlPreviewView extends ScrollView
  @content: ->
    @div class: 'plantuml-preview padded pane-item', tabindex: -1, =>
      @div class: 'plantuml-control', outlet: 'control', =>
        @div =>
          @input id: 'zoomToFit', type: 'checkbox', outlet: 'zoomToFit'
          @label 'Zoom To Fit'
        @div =>
          @input id: 'useTempDir', type: 'checkbox', outlet: 'useTempDir'
          @label 'Use Temp Dir'
        @div =>
          @label 'Output'
          @select outlet: 'outputFormat', =>
            @option value: 'png', 'png'
            @option value: 'svg', 'svg'
      @div class: 'plantuml-container', outlet: 'container'

  constructor: ({@editorId}) ->
    super
    @editor = editorForId @editorId
    @disposables = new CompositeDisposable

  destroy: ->
    @disposables.dispose()

  attached: ->
    if @editor?
      @useTempDir.attr('checked', atom.config.get('plantuml-preview.useTempDir'))
      @outputFormat.val atom.config.get('plantuml-preview.outputFormat')

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

      atom.commands.add @element,
        'core:copy': (event) =>
          clipboard ?= require 'clipboard'
          nativeimage ?= require 'native-image'
          event.stopPropagation()
          filename = $(event.target).closest('.uml-image').attr('src')
          filename = filename.replace ///\?time=.*///, ''
          console.log "COPY! #{filename}"
          image = nativeimage.createFromPath(filename)
          image = image.toPng()
          # atom.clipboard.writeImage(image, 'image/png')
          clipboard.writeImage(image, 'image/png')
          # clipboard.writeImage(image)

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
    @container.empty()
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
    @container.append $('<div/>').attr('class', 'throbber')
    @container.show

  setZoomFit: (checked) ->
    if checked
      @container.find('.uml-image').addClass('zoomToFit')
    else
      @container.find('.uml-image').removeClass('zoomToFit')

  getFilenames: (directory, defaultName, defaultExtension, contents) ->
    path ?= require 'path'
    filenames = []
    defaultFilename = path.join(directory, defaultName)
    defaultCount = 0
    for uml in contents.split(///@enduml///i)
      if uml.trim() == ''
        continue

      currentFilename = path.join(directory, defaultName)
      currentExtension = defaultExtension
      pageCount = 1

      filename = uml.match ///@startuml([^\n]*)\n///i
      if filename?
        filename = filename[1].trim()
        if filename != ''
          if path.extname(filename)
            currentExtension = path.extname filename
          else
            currentExtension = defaultExtension
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
    os ?= require 'os'

    filePath = @editor.getPath()
    basename = path.basename(filePath, path.extname(filePath))
    directory = path.dirname(filePath)
    format = @outputFormat.val()

    if @useTempDir.is(':checked')
      directory = path.join os.tmpdir(), 'plantuml-preview'
      if !fs.existsSync directory
        fs.mkdirSync directory

    imgFiles = @getFilenames directory, basename, '.' + format, @editor.getText()

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

    command = atom.config.get 'plantuml-preview.java'
    args = [
      '-jar',
      atom.config.get('plantuml-preview.jarLocation'),
      '-charset',
      @editor.getEncoding()
    ]
    if format == 'svg'
      args.push '-tsvg'
    dotLocation = atom.config.get('plantuml-preview.dotLocation')
    if dotLocation != ''
      if fs.isFileSync dotLocation
        args.push '-graphvizdot', dotLocation
      else
        settingsError "#{dotLocation} not found or is not a file.", 'Graphviz Dot Location'
    args.push '-output', directory, filePath

    outputlog = []
    errorlog = []

    exitHandler = (files) =>
      @addImages(files, Date.now())
      if errorlog.length > 0
        str = errorlog.join('')
        if str.match ///jarfile///i
          settingsError str, 'PlantUML Jar Location'
        else
          atom.notifications.addError "plantuml-preview: stderr (logged to console)", detail: str
          console.log "plantuml-preview: stderr\n#{str}"
      if outputlog.length > 0
        str = outputlog.join('')
        atom.notifications.addInfo "plantuml-preview: stdout (logged to console)", detail: str
        console.log "plantuml-preview: stdout\n#{str}"
    exit = (code) ->
      exitHandler imgFiles

    stdout = (output) ->
      outputlog.push output
    stderr = (output) ->
      errorlog.push output
    errorHandler = (object) ->
      object.handle()
      settingsError "#{command} not found.", 'Java Command'

    @removeImages()
    new BufferedProcess({command, args, stdout, stderr, exit}).onWillThrowError errorHandler
