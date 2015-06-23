_ = require 'underscore-plus'
{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  commands: ['camelize', 'capitalize', 'dasherize', 'uncamelcase', 'underscore']

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @commands.forEach((command) =>
      @subscriptions.add(
        atom.commands.add('atom-text-editor', "text-transformer:#{command}", => @transform(command))
      )
    )

    @installPackageDependencies()

  deactivate: ->
    @subscriptions.dispose()

  transform: (command) ->
    editor = @getActiveTextEditor()
    return unless editor?

    editor.mutateSelectedText (selection) ->
      return if selection.isEmpty()
      text = selection.getText()
      selection.insertText(_[command](text), {select: true})

  sequential: ->
    editor = @getActiveTextEditor()
    return unless editor?

    count = @sequentialCommandService.count()
    if count is 0
      @candidates = @computeCandidates(editor)
    else
      editor.undo()

    command = @candidates[count % @candidates.length]
    @transform(command)

  computeCandidates: (editor) ->
    getSelectionsText = ->
      editor.getSelections().map((selection) -> selection.getText()).toString()

    candidates = []
    states = [getSelectionsText()]

    for command in @commands
      editor.transact( =>
        @transform(command)
        state = getSelectionsText()
        unless state in states
          candidates.push(command)
          states.push(state)
        editor.abortTransaction()
      )

    candidates

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  consumeSequentialCommand: (@sequentialCommandService) ->
    commandSubscription = atom.commands.add('atom-text-editor', "text-transformer:sequential", => @sequential())
    @subscriptions.add(commandSubscription)
    commandSubscription

  installPackageDependencies: ->
    return if atom.packages.getLoadedPackage('sequential-command')
    message = 'text-transformer: Some dependencies not found. Running "apm install" on these for you. Please wait for a success confirmation!'
    notification = atom.notifications.addInfo(message, { dismissable: true })
    require('atom-package-dependencies').install ->
      atom.notifications.addSuccess('text-transformer: Dependencies installed correctly.', dismissable: true)
      notification.dismiss()
      atom.packages.activatePackage('sequential-command')
