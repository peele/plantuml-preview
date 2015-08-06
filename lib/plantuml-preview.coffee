fs = require 'fs-plus'
PlantumlPreviewView = null

openURI = (uriToOpen) ->
  pathname = uriToOpen.replace 'plantuml-preview://', ''
  return unless uriToOpen.substr(0, 19) is 'plantuml-preview://'

  PlantumlPreviewView ?= require './plantuml-preview-view'
  new PlantumlPreviewView(filePath: pathname)

createView = ->
  paneItem = atom.workspace.getActivePaneItem()
  filePath = paneItem.getPath()
  if paneItem and fs.isFileSync(filePath)
    options =
      activatePane: false
      searchAllPanes: true
      split: 'right'
    atom.workspace.open "plantuml-preview://#{filePath}", options
  else
    console.warn "File (#{filePath}) does not exists"

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
