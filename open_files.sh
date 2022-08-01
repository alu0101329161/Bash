#!/bin/bash
# open_files - Práctica de BASH Ficheros Abiertos por Usuarios.
# Autor: Joseph Gabino Rodríguez.
# Utilidad: Es un script que trabaja principalmente con el comando lsof y sus diferentes opciones
# para mostar los procesos de los usuarios, donde se ejecutan y demás.

##### Constantes.

TITLE="PRÁCTICA DE BASH FICHEROS ABIERTOS POR USUARIOS CREADO POR $USER"
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
TEMP_FILE=$TEMPDIR/miscript.$$.$RANDOM
TEMP_FILE1=$TEMPDIR/miscript.$$.$RANDOM
PROGNAME=$(basename $0)
ANADIREXP='$'

##### Variables.
# Variable que contiene el filtro introducido por parametros.
filtro=
# Guarda los usuarios introducidos por parámetro. 
usuarios=
# Variable que guarda el numero de iteraciones
contador=
# Guarda las veces que se encuentra el filtro
variable=0
# Contador que guarda cuantas veces lo encuentra
variable1=0

##### Estilos.
TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

##### Funciones.
# Funcion que devuelve error segun le indiquemos.
function error_exit()
{
        echo "${PROGNAME}: ${1:-"Error desconocido"}" 1>&2
        help
        exit 1
}
# Funcion que comprueba que has introducido filtro perfectamente
function ComprobarFiltro()
{
   if [ -z $1 ]; then
   error_exit "No has introducido filtro"
   fi
   if [ "$2" != "" ]; then
   error_exit "Hay demasiados filtros introducidos"
   fi
}

# Funcion que comprueba si despues de -o no hay nada
function ErrorOfline()
{
   if [ "$1" != "" ]; then
   error_exit "Despues del -o no puedes introducir nada"
   fi
}

# Comprobar que este instalado lsof y sino pregunta para instalarlo
function ComprobarLsof()
{
   if [ $(type -P lsof) ] ; then
    echo "$TEXT_BOLD$TITLE$TEXT_RESET"
   else
     echo "Ha ocurrido un error ya que no cuenta con el paquete \"lsof\""
     echo "¿Desea instalar este paquete? responda: yes/no"
     read -t 10 message 
      if [ "$message" = "yes" ]; then
       sudo apt install lsof
      else
      exit 1
      fi
   fi
}
# Funcion que comprueba que los comandos estan instalados.
function Comandos()
{
    # Comprobar que existe el directorio.
    if [ -f /etc/passwd ]; then
     proceso=1
    else
     error_exit "El directorio /etc/passwd de usuarios no existe"
    fi
    # Comprobar que los usuarios existen
    for usuario in $usuarios
     do
      if [ -n $usuario ]; then
       if id -u "$usuario" >/dev/null 2>&1; then 
        proceso=1                                               
       else 
       error_exit "Usuario introducido no existe"
       fi
      fi
     done
}

# Funcion que fuerza borrado del archivo temporal.
function cleanup() {    
  # Comprobamos que existan los archivos.
  if [ -f TEMP_FILE ]; then             
  rm -r TEMP_FILE
  fi
  if [ -f TEMP1_FILE ]; then                 
  rm -r TEMP1_FILE
  fi
}

# Funcion que imprime por pantalla la lista.
function Lsof()
{ 
   echo "Usuario:"$1 "UID:""$(id -u $1)" "Ficheros_Abiertos:""$(lsof -u $1 | wc -l)" "Pid_Proceso_Mas_Antiguo:""$(ps -u $1 --no-headers | head -n1 | cut -d " " -f 2)"
}

# Imprime el usuario con el numero de procesos y el pid del proceso más antiguo.
function Metodo()
{
   # Guardamos los usuarios en un fichero temporal.
    echo "Usarios de who:"
    who | cut -d " " -f 1 | sort | uniq >> TEMP_FILE                                   

    # Mientras va leyendo del fichero temporal va ejecutando para cada usuario.
    while IFS= read -r line
    do

    Lsof $line

    done < TEMP_FILE
    cleanup
}

# Imprime un contador que guarda la cantidad de veces que se ha encontrado el filtro.
function filter()
{
   a=$1
   # Al guardar de esa manera se borran las comillas.
   filtro=$a$ANADIREXP
   echo $filtro
   contador=9
   # Contador recorre las columnas y guarda las veces que encuentra el filto en variable.
   while [ $contador -le 11 ]
   do
     variable1=$(lsof | awk '{print $'$contador'}' | grep -E ''$filtro'' | wc -l)
     variable=$(($variable + $variable1))
     contador=$(($contador + 1))
   done
   # Imprimimos el valor final de variable.
   echo "El filtro introducido por parmetro se ha encontrado" $variable "veces."
}

# Muestra los usuarios que no estan conectados actualmente.
function offline()
{
   who | cut -d " " -f 1 | sort | uniq >> TEMP1_FILE  
   cut -d: -f1 /etc/passwd >>TEMP_FILE
   contador=1
   # Recorro ambos ficheros y cuando encuentre 2 iguales borra esa linea.
   while IFS= read -r line1
    do
        while IFS= read -r line
         do
           if [ "$line" == "$line1" ]; then
           sed -i ''$contador'd' TEMP_FILE
           fi
           contador=$(($contador + 1))
         done < TEMP_FILE
         contador=1
   done < TEMP1_FILE
   #Ejecutamos pero solo para los usuarios que no hay en who
   while IFS= read -r line
   do
    Lsof $line
   done < TEMP_FILE
   cleanup
}

# Muestra los usuarios y aplica el filtro introducido.
function filteruser() 
{
    Comandos $usuarios
    if [ -z $filtro ]; then
     for usuario in $usuarios
      do
       Lsof $usuario
      done
    else
      filtro=$filtro$ANADIREXP
     for usuario in $usuarios
     do
      contador=9
      # Contador recorre las columnas y guarda las veces que encuentra el filto en variable.
      while [ $contador -le 11 ]
        do
        variable1=$(lsof -u $usuario | awk '{print $'$contador'}' | grep -E ''$filtro'' | wc -l)
        variable=$(($variable + $variable1))
        contador=$(($contador + 1))
        done
     contador=9
     echo "Usuario:" $usuario "UID:""$(id -u $usuario)" "Ficheros_Abiertos:""$variable" "Pid_Proceso_Mas_Antiguo:" "$(ps -u $usuario --no-headers | head -n1 | cut -d " " -f 2)"
     variable=0  
    done
   fi
}

# Opciones del script para pasar por parametro.
function help()
{
   echo "help: open_files [ ] [-h] [-f filtro] [-o] [-u usuarios]"
   exit 1
}

ComprobarLsof
#LLamamos a comprobar asi mira si esta todo instalado correctamente.
Comandos
# Procesar la línea de comandos del script para leer las opciones.
case $1 in
        "" )
           Metodo
           ;;
        -h | --help )
           help
           ;;
        -f | --filter )
           shift
           ComprobarFiltro $1 $2
           filter $1
           ;;
        -o | --offline )
           ErrorOfline $2
           offline
           ;;
        -u | --user )
           shift
           while [ "$1" != "" ] && [ "$1" != "-f" ]; do
                # Mientras no este vacio y no haya una f.
                usuarios="$usuarios $1"                             
                shift         
            done
           if [ "$1" = "" ]; then
           filteruser
           else
           filtro=$2
           ComprobarFiltro $2 $3
           filteruser
           fi
           ;;
        * )
           error_exit
           exit 1
esac

echo "$TEXT_BOLD$TIME_STAMP$TEXT_RESET"


