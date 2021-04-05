@ECHO OFF
start cmd /c "python -m http.server 8000 --directory ./docs/"
start firefox -private-window http://localhost:8000
