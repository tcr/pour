# Pour, an async DSL for CoffeeScript

    > npm install pour

Require the package:

    [serial, parallel] = require 'pour'

Execute steps in serial, passing the results of each function to the next step using the `@next` callback, or catching errors as they occur:

    serial
        1: ->
            if file.isSaved then @next()
            else @[3]() # skip next step
        2: -> fs.writeFile "file.txt", "Text data", @next
        3: -> api.uploadFile 'file.txt', @next
        4: (res) -> console.log 'File upload response:', res
        catch: (err) -> console.log 'Couldn't finish upload:', err

Execute steps in parallel, aggregating the results as named properties of a single result object, or catching errors (and stopping immediately) when they occur.

    parallel
        upload: -> api.uploadFile 'file.txt', @next
        notify: -> api.confirm 'Would you like to close file?', @next
        log: -> api.logStats 'file.txt', @next
        catch: (err) -> console.log 'Error occurred:', err
        finally: (res) ->
            console.log res.upload, res.notify, res.log

You can easily nest parallel and serial steps by using the `@parallel` and `@serial` properties of both, then using `@up.next` to pass control back to the outer control structure.

    parallel
        upload: ->
            @serial
                1: api.uploadFile 'file.txt', @next
                2: api.logStats 'file.txt', @up.next
        finally (res) ->
            console.log res.upload

Released under the MIT license.
