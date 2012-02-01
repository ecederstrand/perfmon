from perfmon.tests import *

class TestPerfController(TestController):

    def test_index(self):
        response = self.app.get(url_for(controller='perf'))
        # Test response...
