#!/bin/bash 

# Wrapper para generar csv a partir del pdf del MEC


test = $(locate pdftotext)

pdftotext -layout -l 1  -fixed 2 
