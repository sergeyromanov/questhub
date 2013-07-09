###

Lots of this code is copy-pasted from views/quest/add.coffee.

###
define [
    "underscore", "jquery"
    "views/proto/common"
    "models/library/quest"
    "text!templates/library/quest-add.html"
], (_, $, Common, Model, html) ->
    class extends Common
        template: _.template html
        selfRender: true

        events:
            "click ._go": "submit"
            "keyup [name=name]": "nameEdit"

        initialize: ->
            super
            $("#modal-storage").append @$el
            @$(".modal").modal().on "shown", =>
                @$("[name=name]").focus()
            @$(".modal").modal().on "hidden", (e) =>
                return unless $(e.target).hasClass("modal")
                @remove()

        disable: ->
            @$("._go").addClass "disabled"
            @enabled = false

        enable: ->
            @$("._go").removeClass "disabled"
            @enabled = true
            @submitted = false

        getName: -> @$("[name=name]").val()

        validate: (options) ->
            if @submitted or not @getName()
                @disable()
                return
            @enable()

        nameEdit: (e) ->
            @validate()
            @checkEnter e

        checkEnter: (e) ->
            @submit() if e.keyCode is 13

        render: ->
            super
            @$(".icon-spinner").hide()
            @submitted = false
            @validate()

        submit: ->
            params =
                name: @getName()
                realm: @options.realm

            mixpanel.track "add library quest"
            model = new Model()
            model.save params,
                success: =>
                    Backbone.trigger "pp:library-quest-add", model
                    @$(".modal").modal "hide"
            @$(".icon-spinner").show()
            @validate()
