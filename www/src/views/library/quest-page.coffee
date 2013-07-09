define [
    "underscore"
    "views/proto/common"
    "text!templates/library/quest-page.html"
], (_, Common, html) ->
    class extends Common
        template: _.template html
        activated: false

        realm: -> @model.get 'realm'
