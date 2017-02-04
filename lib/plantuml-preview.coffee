fs = null
url = require 'url'
PlantumlPreviewView = null

uriForEditor = (editor) ->
  "plantuml-preview://editor/#{editor.id}"

isPlantumlPreviewView = (object) ->
  PlantumlPreviewView ?= require './plantuml-preview-view'
  object instanceof PlantumlPreviewView

removePreviewForEditor = (editor) ->
  uri = uriForEditor(editor)
  previewPane = atom.workspace.paneForURI(uri)
  if previewPane?
    previewPane.destroyItem(previewPane.itemForURI(uri))
    true
  else
    false

addPreviewForEditor = (editor) ->
  fs ?= require 'fs-plus'
  uri = uriForEditor(editor)
  previousActivePane = atom.workspace.getActivePane()
  if editor and fs.isFileSync(editor.getPath())
    options =
      searchAllPanes: true
      split: 'right'
    atom.workspace.open(uri, options).then (plantumlPreviewView) ->
      if isPlantumlPreviewView(plantumlPreviewView)
        previousActivePane.activate()
  else
    console.warn "Editor has not been saved to file."

toggle = ->
  if isPlantumlPreviewView(atom.workspace.getActivePaneItem())
    atom.workspace.destroyActivePaneItem()
    return

  editor = atom.workspace.getActiveTextEditor()
  return unless editor?

  addPreviewForEditor(editor) unless removePreviewForEditor(editor)

module.exports =
  config:
    java:
      title: 'Java Executable'
      description: 'Path to and including Java executable. If default, Java found on System Path will be used.'
      type: 'string'
      default: 'java'
    javaAdditional:
      title: 'Additional Java Arguments'
      description: 'Such as -DPLANTUML_LIMIT_SIZE=8192 or -Xmx1024m'
      type: 'string'
      default: ''
    jarAdditional:
      title: 'Additional PlantUML Arguments'
      description: 'Arguments are added immediately after -jar. Arguments specified in settings may override.'
      type: 'string'
      default: ''
    jarLocation:
      title: 'PlantUML Jar'
      description: 'Path to and including PlantUML Jar.'
      type: 'string'
      default: 'plantuml.jar'
    dotLocation:
      title: 'Graphvis Dot Executable'
      description: "Path to and including Dot executable. If empty string, '-graphvizdot' argument will not be used."
      type: 'string'
      default: ''
    zoomToFit:
      type: 'boolean'
      default: true
    displayFilename:
      title: 'Display Filename Above UML Diagrams'
      type: 'boolean'
      default: true
    bringFront:
      title: 'Bring To Front'
      description: 'Bring preview to front when parent editor gains focus.'
      type: 'boolean'
      default: false
    useTempDir:
      title: 'Use Temp Directory'
      description: 'Output diagrams to {OS Temp Dir}/plantuml-preview/'
      type: 'boolean'
      default: true
    outputFormat:
      type: 'string'
      default: 'svg'
      enum: ['png', 'svg']
    beautifyXml:
      title: 'Beautify XML'
      description: 'Use js-beautify on XML when copying and generating SVG diagrams.'
      type: 'boolean'
      default: true

  activate: ->
    atom.commands.add 'atom-workspace', 'plantuml-preview:toggle', -> toggle()
    @openerDisposable = atom.workspace.addOpener (uriToOpen) ->
      {protocol, host, pathname} = url.parse uriToOpen
      return unless protocol is 'plantuml-preview:'

      PlantumlPreviewView ?= require './plantuml-preview-view'
      new PlantumlPreviewView(editorId: pathname.substring(1))

  deactivate: ->
    @openerDisposable.dispose()
