from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1200306243.275265
_template_filename='/usr/local/www/perfmon/trunk/perfmon/templates/search.mako'
_template_uri='/search.mako'
_template_cache=cache.Cache(__name__, _modified_time)
_source_encoding=None
_exports = ['head_tags']


def _mako_get_namespace(context, name):
    try:
        return context.namespaces[(__name__, name)]
    except KeyError:
        _mako_generate_namespaces(context)
        return context.namespaces[(__name__, name)]
def _mako_generate_namespaces(context):
    pass
def _mako_inherit(template, context):
    _mako_generate_namespaces(context)
    return runtime._inherit_from(context, u'base.mako', _template_uri)
def render_body(context,**pageargs):
    context.caller_stack.push_frame()
    try:
        __M_locals = dict(pageargs=pageargs)
        h = context.get('h', UNDEFINED)
        c = context.get('c', UNDEFINED)
        # SOURCE LINE 1
        context.write(u'\n\n')
        # SOURCE LINE 5
        context.write(u'\n\n    Select options:<br />\n    ')
        # SOURCE LINE 8
        context.write(unicode(h.form(h.url(action='setopts'), method='post')))
        context.write(u'<br />\n    OS config ID: ')
        # SOURCE LINE 9
        context.write(unicode(h.select('osconf', c.osconf_opt)))
        context.write(u'<br />\n    Machine: ')
        # SOURCE LINE 10
        context.write(unicode(h.select('machine', c.machine_opt)))
        context.write(u'<br />\n    Machine config ID: ')
        # SOURCE LINE 11
        context.write(unicode(h.select('machineconf', c.machineconf_opt)))
        context.write(u'<br />\n    Benchmark: ')
        # SOURCE LINE 12
        context.write(unicode(h.select('bench', c.bench_opt)))
        context.write(u'<br />\n    Benchmark config ID: ')
        # SOURCE LINE 13
        context.write(unicode(h.select('benchconf', c.benchconf_opt)))
        context.write(u'<br />\n    ')
        # SOURCE LINE 14
        context.write(unicode(h.submit('Submit')))
        context.write(u'<br />\n    ')
        # SOURCE LINE 15
        context.write(unicode(h.end_form()))
        context.write(u'\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


def render_head_tags(context):
    context.caller_stack.push_frame()
    try:
        # SOURCE LINE 3
        context.write(u'\n    <title>PerfMon Search</title>\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


