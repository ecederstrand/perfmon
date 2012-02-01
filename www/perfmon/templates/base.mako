<%include file="/header.mako" />
        <div id="left">
                <div class="box" id="control">
                        <h1>Control</h1>
                        <a class="toggle" href="javascript: toggle('d_control');">hide</a>
		                <%include file="/settings.mako" />
                </div>
                <div class="box" id="plot">
                        <h1>Plot Area</h1>
		                <%include file="/plot.mako" />
                </div>
        </div>
        <div id="right">
                <div class="box" id="datapoints">
                        <h1>Datapoints</h1>
                        <a class="toggle" href="javascript: toggle('d_facts');">hide</a>
		                <%include file="/datapoints.mako" />
                </div>
                <div class="box" id="compare">
                        <h1>Revision Details</h1>
                        <a class="toggle" href="javascript: toggle('d_compare');">hide</a>
		                <%include file="/compare.mako" />
                </div>
                <div class="box" id="details">
                        <h1>General Details</h1>
                        <a class="toggle" href="javascript: toggle('d_details');">hide</a>
		                <%include file="/details.mako" />
                </div>
        </div>
		<%include file="/footer.mako" />
