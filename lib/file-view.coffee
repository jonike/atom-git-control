{View, $} = require 'atom'

FileViewItem = require './file-view-item'

module.exports =
class FileView extends View
  @content: (params) ->
    @div class: 'files', =>
      @div class: 'heading', =>
        @i class: 'icon forked'
        @span 'Workspace'
        @div class: 'action', click: 'selectAll', =>
          @span 'Select'
          @i class: 'icon check'
          @input class: 'invisible', type: 'checkbox', outlet: 'allCheckbox'

  initialize: ->
    @files = {}
    @view = $(@element)

  hasSelected: ->
    for name, file of @files when file.selected
      return true
    return false

  getSelected: ->
    files =
      all: []
      add: []
      rem: []

    for name, file of @files when file.selected
      files.all.push name
      switch file.type
        when 'new' then files.add.push name
        when 'deleted' then files.rem.push name

    return files

  showSelected: ->
    fnames = []
    for div in @view.find('.file').toArray()
      f = $(div)
      if name = f.attr('data-name')
        if @files[name].selected
          fnames.push name
          f.addClass('active')
        else
          f.removeClass('active')

    for name, file of @files
      unless name in fnames
        file.selected = false

    @parentView.showSelectedFiles()
    return

  add: (file) ->
    file.click = (name) =>
      @select(name)
      return

    @files[file.name] or= name: file.name
    @files[file.name].type = file.type

    @view.append new FileViewItem(file)

    return

  addAll: (files) ->
    fnames = []

    @view.find('.file').remove()

    if files.length
      @view.removeClass('none')

      for file in files
        fnames.push file.name
        @add(file)

    else
      @view.addClass('none')
      @view.append $$ ->
        @div class: 'file deleted', 'No local working copy changes detected'

    for name, file of @files
      unless name in fnames
        file.selected = false

    @showSelected()
    return

  select: (name) ->
    if name
      @files[name].selected = !!!@files[name].selected

    @allCheckbox.prop('checked', false)
    @showSelected()
    return

  selectAll: ->
    val = !!!@allCheckbox.prop('checked')
    @allCheckbox.prop('checked', val)

    for name, file of @files
      file.selected = val

    @showSelected()
    return

  unselectAll: ->
    for name, file in @files when file.selected
      file.selected = false

    return
