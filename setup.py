from setuptools import setup, find_packages

setup(
    name="microservices",
    version="0.1",
    packages=find_packages(),
    install_requires=[
        "Flask>=2.0",
        "requests>=2.31.0",
        "mysqlclient>=2.1.0",
        "python-dotenv>=0.19.0"
    ],
)