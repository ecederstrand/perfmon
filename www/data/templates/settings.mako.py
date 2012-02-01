from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201396084.2902901
_template_filename=u'/usr/local/www/perfmon/trunk/perfmon/templates/settings.mako'
_template_uri=u'/settings.mako'
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
        context.write(u'    ')

        f = h.form_remote_tag(url=h.url_for(controller='plot', action='update'), failure=h.update_element_function("pngplot", content="Error when requesting an update!"), success=h.evaluate_remote_response())
        f = f.replace("POST", "post")   # XHTML needs lowercate POST
        
        
        __M_locals.update(dict([(__M_key, locals()[__M_key]) for __M_key in ['f'] if __M_key in locals()]))
        # SOURCE LINE 4
        context.write(u'\n    <div id="d_control">\n    ')
        # SOURCE LINE 6
        context.write(unicode(f))
        context.write(u'\n    <p>\n    OS conf: ')
        # SOURCE LINE 8
        context.write(unicode(h.select('osconf', c.osconf_opt)))
        context.write(u'\n    Branch: ')
        # SOURCE LINE 9
        context.write(unicode(h.select('osbranch', c.osbranch_opt)))
        context.write(u'\n    Start: ')
        # SOURCE LINE 10
        context.write(unicode(h.select('osdatefirst', c.osdatefirst_opt)))
        context.write(u'\n    End: ')
        # SOURCE LINE 11
        context.write(unicode(h.select('osdatelast', c.osdatelast_opt)))
        context.write(u'<br />\n    Machine: ')
        # SOURCE LINE 12
        context.write(unicode(h.select('machine', c.machine_opt)))
        context.write(u'\n    Machine conf: ')
        # SOURCE LINE 13
        context.write(unicode(h.select('machineconf', c.machineconf_opt)))
        context.write(u'<br />\n    Benchmark conf: ')
        # SOURCE LINE 14
        context.write(unicode(h.select('benchconf', c.benchconf_opt)))
        context.write(u'\n    Benchmark: ')
        # SOURCE LINE 15
        context.write(unicode(h.select('bench', c.bench_opt)))
        context.write(u'<br />\n    Scatter: ')
        # SOURCE LINE 16
        context.write(unicode(h.radio_button('style', 'scatter', checked=True)))
        context.write(u' Line: ')
        context.write(unicode(h.radio_button('style', 'smooth')))
        context.write(u'\n    Error bars: ')
        # SOURCE LINE 17
        context.write(unicode(h.check_box('errorbars', value=True, checked=True)))
        context.write(u'\n    ')
        # SOURCE LINE 18
        context.write(unicode(h.submit('Apply')))
        context.write(u'\n    </p>\n    ')
        # SOURCE LINE 20
        context.write(unicode(h.end_form()))
        context.write(u'\n    </div>\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


