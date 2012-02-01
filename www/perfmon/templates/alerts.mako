<%include file="/header.mako" />
        <div class="box" id="alerts">
            <h1>Alerts</h1>
    <%
    cells = ''
    prevdate = None
    n = len(c.alerts)
    i = 0
    for a in c.alerts:
        date = a[0]
        diff = a[5]
        i += 1
        if i == 1:
            cells += '<tr><td>%s</td><td>' % date
            prevdate = date
        elif date != prevdate:
            cells += '</td></tr>\n<tr><td>%s</td><td>' % date
            prevdate = date

        if diff > 0:
            status = "improvement"
        else:
            status = "regression"
        # Colors range from 150 to 0
        # This was hound empirically. Colors max out at 25% change
        color = 150 - abs(int(diff * 600))
        if color < 0:
            color = 0
        if diff < 0:
            # Shade of red
            hexcol = "#FF%02X%02X" % (color, color)
        else:
            # Shade of green
            hexcol = "#%02XFF%02X" % (color, color)
        u = h.url_for(controller='plot', action='showbench', id=a[1])
        div = h.content_tag('div', '%.2f%%  - %s v.%s (%s)<br />' %(diff*100, a[2], a[3], a[4]), style='background-color: %s;' % hexcol)
        cells += h.content_tag('a', div, href=u)
        if i == n:
            cells += '</td></tr>\n'
    %>
            <table><tr><th>Date</th><th>Change</th></tr>
            ${cells}
            </table>
        </div>
		<%include file="/footer.mako" />
