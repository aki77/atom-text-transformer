# text-transformer package

Transform selected text
[![Build Status](https://travis-ci.org/aki77/atom-text-transformer.svg)](https://travis-ci.org/aki77/atom-text-transformer)

[![Gyazo](http://i.gyazo.com/c68e2df3df1f579d52768da82b2e4426.gif)](http://gyazo.com/c68e2df3df1f579d52768da82b2e4426)

## Commands

* `text-transformer:camelize`
* `text-transformer:capitalize`
* `text-transformer:dasherize`
* `text-transformer:uncamelcase`
* `text-transformer:underscore`
* `text-transformer:sequential`

## Keymap

No keymap by default.

edit `~/.atom/keymap.cson`

```coffeescript
'atom-text-editor':
  'alt-c': 'text-transformer:sequential'
```

## Requirement

* [sequential-command](https://atom.io/packages/sequential-command)
