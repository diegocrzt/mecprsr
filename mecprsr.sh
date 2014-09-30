#!/bin/sh

# Wrapper para generar csv a partir del pdf del MEC

# CONSTANTES

TOOL="pdftotext" # Herramienta utilizada para el primer parseado
FIX_PARSER="mecprsr.rb" # Herramienta el segundo parseado

# FUNCIONES AUXILIARES
solo_nombre(){
    filename=$(basename "$1");
    extension="${filename##*.}";
    filename="${filename%.*}";
    echo ${filename};
}

# PROGRAMA PRINCIPAL


if ! command -v ${TOOL} 2>&1 > /dev/null ; then
    echo "Asegurese que tiene instalado pdftotext (o xpdf)" >&2;
    exit -1
fi

if [ -z ${1} ] ; then
    echo "uso: $0 funcionarios_docentes_AAAAmm.pdf" >&2;
    exit -2;
fi

if [ ! -e ${1} ] ; then
    echo "El fichero $1 no existe " >&2;
    exit -3;
fi

echo "Parseando PDF"

NAME=$(solo_nombre ${1})

pdftotext -layout -fixed 2 ${1} ${NAME}.txt;

if [ $? -eq 0 ] ; then
    echo "Parseado exitosamente en ${NAME}.txt"
else
    echo "${TOOL} retornó un estado de error, verificar antes" >&2;
    exit -4;
fi

echo "Parseando TXT"

ruby mecprsr.rb ${NAME}.txt

if [ $? -eq 0 ] ; then
    echo "Parseado exitosamente en ${NAME}.csv"
else
    echo "${FIX_PARSER} retornó un estado de error, verificar" >&2;
    exit -5;
fi
