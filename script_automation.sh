#!/bin/bash

# sysinfo - Un script sobre la practica 4 de sistemas

##### Constantes
TITLE="PRACTICA 4 DE SISTEMAS OPERATIVOS POR $USER"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
interactive=
TEMP_FILE=$TEMPDIR/miscript.$$.$RANDOM
filename=~/sysinfo.txt
PROGNAME=$(basename $0)
##### Estilos
TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

##### Funciones

function system_info() 
{
    echo "${TEXT_ULINE}Versión del sistema${TEXT_RESET}"
    echo 
    uname -a
}

function show_uptime() 
{
    echo "${TEXT_ULINE}Tiempo de encendido del sistema${TEXT_RESET}"
    echo 
    uptime
}

function drive_space() 
{
    echo "${TEXT_ULINE}Espacio en el sistema de archivos${TEXT_RESET}"
    echo 
    df
}
function home_space() 
{
    if [ "$USER" = "root" ] 
    then
       echo "${TEXT_ULINE}Espacio en home por usuario${TEXT_RESET}"
       echo
       echo "Bytes Directorio"
       du -s /home/* | sort -nr
   fi
}

function error_exit() 
{
        echo "${PROGNAME}: ${1:-"Error desconocido"}" 1>&2
        exit 1
}

function usage()
{
   echo "usage: sysinfo [-f file ] [-i] [-h]"

}

function cleanup() {               
  rm -r TEMP_FILE
}

function FinalizarProceso()
{
    #type -P ps || error_exit "El comando PS esta instalado"
    ps -A --no-headers -u $usuario --sort=-pcpu |head -n1 |tr -s ' ' ':' | cut -d ":" -f 2 >> TEMP_FILE
    proceso_id=$(cat TEMP_FILE)
    cleanup
    #echo $proceso_id
    #type -P kill || error_exit "El comando KILL esta instalado"
    if [ "$1" == "usuario" || "$1" == "root" ]; then
    kill -12 $proceso_id
    fi
    #si lo ejecuta root entonces acaba el programa 
    if [ "$usuario" == "root" ];then
    ./practica4 & >> TEMP_FILE
    creador=$(cat TEMP_FILE)
    cleanup
    ps aux | grep $creador | cut -d " " -f 1
    #CTRL + Z -> pausa el proceso en ejecución // #if ["$?" != "0"]; then $ guarda valor del if anterio //  proceso_id=$(cat TMP_FILE) //tambien se puede usar el coman
    # top pero ahi se actualizan cada 5 min
    fg $creador
    kill -12 $creador  
}

function write_page()
{
cat << _EOF_

$TEXT_BOLD$TITLE$TEXT_RESET

$(system_info)

$(show_uptime)

$(drive_space)

$(home_space)

$TEXT_GREEN$TIME_STAMP$TEXT_RESET

_EOF_

}

# Procesar la línea de comandos del script para leer las opciones
while [ "$1" != "" ]; do
   case $1 in
       -f | --file )
            shift
           filename=$1
           ;;
       -i | --interactive )
            interactive=1
            ;;

        -p | --usuario )
            shift
            if [ "$1" != "" ]; then
             echo "El parámetro posicional 1 contiene algo"
             usuario=$1
             FinalizarProceso
            else
             error_exit "El parámetro posicional 1 está vacío"
            fi
            ;;

       -h | --help )
           usage
           exit
           ;;
       * )

           usage
           exit 1
   esac
   shift
done

write_page > $filename