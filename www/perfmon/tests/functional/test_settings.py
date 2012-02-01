from perfmon.tests import *

class TestSettingsController(TestController):

    def test_index(self):
        response = self.app.get(url_for(controller='settings'))
        # Test response...
