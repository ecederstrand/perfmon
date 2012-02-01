<%include file="/header.mako" />
        <div class="box" id="overview">
            <h1>Overview</h1>
            <%
                img = ''
                for bid in c.benchids:
                    s = '/img/thumbnails/%s.png' %(bid)
                    i = h.tag('img', open=False, src=s, width=300, height=240, alt='Benchmark id:'+str(bid))
                    u = h.url_for(controller='plot', action='showbench', id=bid)
                    img += h.content_tag('a', i, href=u, title='Benchmark id: '+str(bid))+'\n'
            %>
            ${img}
        </div>
		<%include file="/footer.mako" />
