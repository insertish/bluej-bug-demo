#!/bin/bash
ghex bluej_out/uk/insrt/report/App.java &
sleep 1
ghex bluej_export/uk/insrt/report/App.java &
sleep 1
ghex bluej_export_modified/uk/insrt/report/App.java &
