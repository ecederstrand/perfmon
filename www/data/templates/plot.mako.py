from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201370277.2237871
_template_filename=u'/usr/local/www/perfmon/trunk/perfmon/templates/plot.mako'
_template_uri=u'/plot.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        c = context.get('c', UNDEFINED)
        # SOURCE LINE 1
        context.write(u'<div id="pngplot">\n<img src="/plot/png/')
        # SOURCE LINE 2
        context.write(unicode(c.random))
        context.write(u'" ismap="ismap" usemap="#points" width="700" height="500" alt="Empty plot" />\n</div>\n<map id="points" name="points">')
        # SOURCE LINE 4
        context.write(unicode(c.map))
        context.write(u'</map>\n\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


