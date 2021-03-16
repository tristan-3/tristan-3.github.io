@ECHO OFF
start cmd /c "python -m http.server 8000 --directory ./docs/"
start http://localhost:8000
