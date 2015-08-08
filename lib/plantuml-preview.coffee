fs = require 'fs-plus'
url = require 'url'
PlantumlPreviewView = null

isPlantumlPreviewView = (object) ->
  PlantumlPreviewView ?= require './plantuml-preview-view'
  object instanceof PlantumlPreviewView

toggle = ->
  editor = atom.workspace.getActivePaneItem()
  if isPlantumlPreviewView(editor)
    atom.workspace.destroyActivePaneItem()
    return

  if editor and fs.isFileSync(editor.getPath())
    options =
      activatePane: false
      searchAllPanes: true
      split: 'right'
    atom.workspace.open "plantuml-preview://editor/#{editor.id}", options
  else
    console.warn "Editor has not been saved to file."

module.exports =
  config:
    java:
      type: 'string'
      default: 'java'
    jarLocation:
      type: 'string'
      default: 'plantuml.jar'
    zoomToFit:
      type: 'boolean'
      default: false

  activate: ->
    atom.commands.add 'atom-workspace', 'plantuml-preview:toggle', => toggle()
    @openerDisposable = atom.workspace.addOpener (uriToOpen) ->
      {protocol, host, pathname} = url.parse uriToOpen
      return unless protocol is 'plantuml-preview:'

      PlantumlPreviewView ?= require './plantuml-preview-view'
      new PlantumlPreviewView(editorId: pathname.substring(1))

  deactivate: ->
    @openerDisposable.dispose()
