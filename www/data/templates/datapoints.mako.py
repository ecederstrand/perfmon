from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201036042.3055301
_template_filename=u'/usr/local/www/perfmon/trunk/perfmon/templates/datapoints.mako'
_template_uri=u'/datapoints.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        # SOURCE LINE 1
        context.write(u'\n<div id="d_facts"></div>\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


