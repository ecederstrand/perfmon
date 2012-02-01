from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201304566.608696
_template_filename='/usr/local/www/perfmon/trunk/perfmon/templates/zoom.mako'
_template_uri='/zoom.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        h = context.get('h', UNDEFINED)
        c = context.get('c', UNDEFINED)
        # SOURCE LINE 1
        import string
        tag = '<img src="/plot/png/'+str(c.random)+'" ismap="ismap" usemap="#points" width="700" height="500" alt="Plot">'
        js = h.update_element_function("pngplot", content=tag)
        #update_element_function unecessarily escapes double quotes. Blech.
        js = js.replace('\\"', '') 
        
        
        __M_locals.update(dict([(__M_key, locals()[__M_key]) for __M_key in ['tag','string','js'] if __M_key in locals()]))
        # SOURCE LINE 6
        context.write(u'\n')
        # SOURCE LINE 7
        context.write(unicode(js))
        context.write(u'\n')
        # SOURCE LINE 8
        context.write(unicode(h.update_element_function("points", content=str(c.map))))
        context.write(u'\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


