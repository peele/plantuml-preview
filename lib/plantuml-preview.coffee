fs = require 'fs-plus'
url = require 'url'
PlantumlPreviewView = null

openURI = (uriToOpen) ->
  {protocol, host, pathname} = url.parse uriToOpen
  return unless protocol is 'plantuml-preview:'

  PlantumlPreviewView ?= require './plantuml-preview-view'
  new PlantumlPreviewView(editorId: pathname.substring(1))

createView = ->
  editor = atom.workspace.getActivePaneItem()
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
    additionalArgs:
      type: 'string'
      default: '-charset utf8'
    zoomToFit:
      type: 'boolean'
      default: false

  activate: ->
    atom.commands.add 'atom-workspace', 'plantuml-preview:toggle', => createView()
    @openerDisposable = atom.workspace.addOpener(openURI)

  deactivate: ->
    @openerDisposable.dispose()
