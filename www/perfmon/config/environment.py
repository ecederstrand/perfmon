"""Pylons environment configuration"""
import os

from pylons import config

from sqlalchemy import engine_from_config

import perfmon.lib.app_globals as app_globals
import perfmon.lib.helpers
from perfmon.config.routing import make_map

from matplotlib import *
use('Agg')

def load_environment(global_conf, app_conf):
    """Configure the Pylons environment via the ``pylons.config``
    object
    """
    # Pylons paths
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    paths = dict(root=root,
                 controllers=os.path.join(root, 'controllers'),
                 static_files=os.path.join(root, 'public'),
                 templates=[os.path.join(root, 'templates')])

    config['pylons.response_options']['content_type'] = 'application/xhtml+xml'

    # Initialize config with the basic options
    config.init_app(global_conf, app_conf, package='perfmon',
                    template_engine='mako', paths=paths)

    config['routes.map'] = make_map()
    config['pylons.g'] = app_globals.Globals()
    config['pylons.h'] = perfmon.lib.helpers

    # Customize templating options via this variable
    tmpl_options = config['buffet.template_options']

    # CONFIGURATION OPTIONS HERE (note: all config options will override
    # any Pylons config options)
    config['pylons.g'].sa_engine = engine_from_config(config, 'sqlalchemy.default.')
