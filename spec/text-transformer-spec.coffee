apd = require('atom-package-dependencies')

installPackageDependencies = ->
  new Promise((resolve, reject) ->
    return resolve() if atom.packages.resolvePackagePath('sequential-command')

    apd.install ->
      if atom.packages.resolvePackagePath('sequential-command')
        resolve()
      else
        reject()
  )

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "TextTransformer", ->
  [activationPromise, editor, editorElement] = []

  executeCommand = (command, callback) ->
    atom.commands.dispatch(editorElement, "text-transformer:#{command}")
    waitsForPromise -> activationPromise
    runs(callback)

  beforeEach ->
    activationPromise = atom.packages.activatePackage('text-transformer')

    waitsForPromise ->
      installPackageDependencies()

    waitsForPromise ->
      atom.packages.activatePackage('sequential-command')

    waitsForPromise ->
      atom.workspace.open().then((_editor) ->
        editor = _editor
        editorElement = atom.views.getView(editor)
      )

  describe "transform", ->
    beforeEach ->
      editor.setText("sequential-command\nsequentialCommand")
      editor.setCursorBufferPosition([0, 0])
      editor.selectToEndOfLine()
      expect(editor.getSelectedText()).toBe('sequential-command')

    it "camelize", ->
      executeCommand 'camelize', ->
        expect(editor.getSelectedText()).toBe('sequentialCommand')

    it "capitalize", ->
      executeCommand 'capitalize', ->
        expect(editor.getSelectedText()).toBe('Sequential-command')

    it "dasherize", ->
      executeCommand 'dasherize', ->
        expect(editor.getSelectedText()).toBe('sequential-command')

    it "uncamelcase", ->
      editor.setCursorBufferPosition([1, 0])
      editor.selectToEndOfLine()
      expect(editor.getSelectedText()).toBe('sequentialCommand')
      executeCommand 'uncamelcase', ->
        expect(editor.getSelectedText()).toBe('Sequential Command')

    it "underscore", ->
      executeCommand 'underscore', ->
        expect(editor.getSelectedText()).toBe('sequential_command')

    it "sequential", ->
      executeCommand 'sequential', ->
        expect(editor.getSelectedText()).toBe('sequentialCommand')
        atom.commands.dispatch(editorElement, 'text-transformer:sequential')
        expect(editor.getSelectedText()).toBe('Sequential-command')
        atom.commands.dispatch(editorElement, 'text-transformer:sequential')
        expect(editor.getSelectedText()).toBe('sequential_command')
        atom.commands.dispatch(editorElement, 'text-transformer:sequential')
        expect(editor.getSelectedText()).toBe('sequentialCommand')
        atom.commands.dispatch(editorElement, 'core:undo')
        expect(editor.getSelectedText()).toBe('sequential-command')
