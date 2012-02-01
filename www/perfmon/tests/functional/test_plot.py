from perfmon.tests import *

class TestPlotController(TestController):

    def test_index(self):
        response = self.app.get(url_for(controller='plot'))
        # Test response...
