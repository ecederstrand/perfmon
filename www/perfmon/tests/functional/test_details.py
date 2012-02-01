from perfmon.tests import *

class TestDetailsController(TestController):

    def test_index(self):
        response = self.app.get(url_for(controller='details'))
        # Test response...
