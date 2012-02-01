from mako import runtime, filters, cache
UNDEFINED = runtime.UNDEFINED
_magic_number = 2
_modified_time = 1201371099.6041529
_template_filename='/usr/local/www/perfmon/trunk/perfmon/templates/overview.mako'
_template_uri='/overview.mako'
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
        runtime._include_file(context, u'/header.mako', _template_uri)
        context.write(u'\n        <div class="box" id="overview">\n            <h1>Overview</h1>\n            ')
        # SOURCE LINE 4

        img = ''
        for bid in c.benchids:
            s = '/img/thumbnails/%s.png' %(bid)
            i = h.tag('img', open=False, src=s, width=300, height=240, alt='Benchmark id:'+str(bid))
            u = h.url_for(controller='plot', action='showbench', id=bid)
            img += h.content_tag('a', i, href=u, title='Benchmark id: '+str(bid))+'\n'
                    
        
        __M_locals.update(dict([(__M_key, locals()[__M_key]) for __M_key in ['i','bid','u','s','img'] if __M_key in locals()]))
        # SOURCE LINE 11
        context.write(u'\n            ')
        # SOURCE LINE 12
        context.write(unicode(img))
        context.write(u'\n        </div>\n\t\t')
        # SOURCE LINE 14
        runtime._include_file(context, u'/footer.mako', _template_uri)
        context.write(u'\n')
        return ''
    finally:
        context.caller_stack.pop_frame()


