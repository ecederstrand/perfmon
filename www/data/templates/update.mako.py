from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201304339.634665
_template_filename='/usr/local/www/perfmon/trunk/perfmon/templates/update.mako'
_template_uri='/update.mako'
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
        # ismap=True becomes ismap="True", which FF barfs on :-/
        # tag = h.tag('img', src=h.url_for(controller='plot', action='png', id=c.random), ismap=True, usemap='#points', width=700, height=500)
        #tag = '<img src="'+h.url_for(controller='plot', action='png', id=c.random)+'" usemap="#points" width=700 height=500>'
        tag = '<img src="/plot/png/'+str(c.random)+'" ismap="ismap" usemap="#points" width="700" height="500" alt="Plot">'
        js = h.update_element_function("pngplot", content=tag)
        #update_element_function unecessarily escapes double quotes. Blech.
        js = js.replace('\\"', '') 
        
        
        __M_locals.update(dict([(__M_key, locals()[__M_key]) for __M_key in ['tag','string','js'] if __M_key in locals()]))
        # SOURCE LINE 9
        context.write(u'\n')
        # SOURCE LINE 10
        context.write(unicode(js))
        context.write(u'\n')
        # SOURCE LINE 11
        context.write(unicode(h.update_element_function("points", content=str(c.map))))
        context.write(u'\n')
        # SOURCE LINE 12
        context.write(unicode(h.update_element_function("d_facts", content=str(c.d_facts))))
        context.write(u'\n')
        # SOURCE LINE 13
        context.write(unicode(h.update_element_function("d_compare", content=str(c.d_compare))))
        context.write(u'\n')
        # SOURCE LINE 14
        context.write(unicode(h.update_element_function("d_os", content=str(c.d_os))))
        context.write(u'\n')
        # SOURCE LINE 15
        context.write(unicode(h.update_element_function("d_osconf", content=str(c.d_osconf))))
        context.write(u'\n')
        # SOURCE LINE 16
        context.write(unicode(h.update_element_function("d_machine", content=str(c.d_machine))))
        context.write(u'\n')
        # SOURCE LINE 17
        context.write(unicode(h.update_element_function("d_machineconf", content=str(c.d_machineconf))))
        context.write(u'\n')
        # SOURCE LINE 18
        context.write(unicode(h.update_element_function("d_bench", content=str(c.d_bench))))
        context.write(u'\n')
        # SOURCE LINE 19
        context.write(unicode(h.update_element_function("d_benchconf", content=str(c.d_benchconf))))
        context.write(u'\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


