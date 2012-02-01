try:
    from setuptools import setup, find_packages
except ImportError:
    from ez_setup import use_setuptools
    use_setuptools()
    from setuptools import setup, find_packages

setup(
    name='perfmon',
    version="0.1",
    description='Website to present performance data created by the FreeBSD PerfMon project.',
    author='Erik Cederstrand',
    author_email='erik@cederstrand.dk',
    #url='',
    install_requires=["Pylons>=0.9.6.1", "SQLAlchemy>=0.4.1", "matplotlib>=0.91.1"],
    packages=find_packages(exclude=['ez_setup']),
    include_package_data=True,
    test_suite='nose.collector',
    package_data={'perfmon': ['i18n/*/LC_MESSAGES/*.mo']},
    #message_extractors = {'perfmon': [
    #        ('**.py', 'python', None),
    #        ('templates/**.mako', 'mako', None),
    #        ('public/**', 'ignore', None)]},
    entry_points="""
    [paste.app_factory]
    main = perfmon.config.middleware:make_app

    [paste.app_install]
    main = pylons.util:PylonsInstaller
    """,
)
