# Pour, a serial/parallel DSL for CoffeeScript
# copyright 2011, released under the MIT license
# released by timcameronryan; contributions by walling 

#
# combines the properties of several objects into a single object
#

combine = (objs...) ->
	ret = {}
	((ret[k] = v) for k, v of obj) for obj in objs
	return ret

#
# evaluates steps in serial
#

exports[0] = serial = (specs...) ->
	spec = combine specs...
	spec.serial = (specs...) -> serial specs..., up: spec
	spec.parallel = (specs...) -> parallel specs..., up: spec

	steps = ({key: k, func: f} for k, f of spec when k not in ['catch', 'up', 'serial', 'parallel'])
	for i, cur of steps
		next = steps[Number(i)+1]
		do (cur, next) ->
			spec[cur.key] = (args...) ->
				spec.next = (err, args...) ->
					if err then spec.catch(err, args...) if spec.catch
					else spec[next.key](args...) if next
				cur.func.apply(spec, args)
	spec[steps[0].key].apply(spec)
	return

#
# evaluates steps in parallel
#

exports[1] = parallel = (specs...) ->
	spec = combine specs... 

	res = {}; stepc = 0; steps = {}
	for key, step of spec when key not in ['catch', 'finally', 'up', 'serial', 'parallel']
		steps[key] = step
		stepc++
	if stepc == 0 then return steps.finally {}
	for key, step of steps
		do (key, step) ->
			ths = next: (err, args...) -> 
				return spec.catch(err, args...) if err
				res[key] = args
				if --stepc == 0 then spec.finally(res)
			ths.up = spec.up
			ths.serial = (specs...) -> serial specs..., up: ths
			ths.parallel =  (specs...) -> parallel specs..., up: ths
			step.apply ths
	return