from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201313248.8017099
_template_filename=u'/usr/local/www/perfmon/trunk/perfmon/templates/footer.mako'
_template_uri=u'/footer.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = []


def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        # SOURCE LINE 1
        context.write(u'</body>\n</html>\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


