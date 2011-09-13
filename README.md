# Pour, an async DSL for CoffeeScript

    [serial, parallel] = require 'pour'

    serial
        1: ->
            if file.isSaved then @next()
            else @[3]() # skip next step
        2: -> fs.writeFile "file.txt", "Text data", @next
        3: -> api.uploadFile 'file.txt', @next
        4: (res) -> console.log 'File upload response:', res
        catch: (err) -> console.log 'Couldn't finish upload:', err

    parallel
        upload: -> api.uploadFile 'file.txt', @next
        notify: -> api.confirm 'Would you like to close file?', @next
        log: -> api.logStats 'file.txt', @next
        catch: (err) -> console.log 'Error occurred:', err
        finally: (res) ->
            console.log res.upload, res.notify, res.log

    parallel
        upload: ->
            @serial
                1: api.uploadFile 'file.txt', @next
                2: api.logStats 'file.txt', @up.next
        finally (res) ->
            console.log res.upload
