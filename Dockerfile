FROM ubuntu
RUN apt-get update
RUN apt-get install -y python
RUN echo 1.0 >> /etc/version && apt-get install -y git \
	&& apt-get install -y iputils-ping
RUN mkdir /datos

# WORKDIR establece el directorio de trabajo por defecto
# Esto significa que las instrucciones que se hagan a continuación de esta instruccion WORKDIR, tienen como directorio base o por defecto ese directorio de trabajo
# Establece el directorio de trabajo por defecto en el directorio "/datos"
WORKDIR /datos
# Crea el fichero "f1.txt" en el directorio de trabajo por defecto "/datos"
RUN touch f1.txt
RUN mkdir /datos1
# Establece el directorio de trabajo por defecto en el directorio "/datos1"(Ya no es el directorio "/datos")
WORKDIR /datos1
# Crea el fichero "f2.txt" en el directorio de trabajo por defecto "/datos1"
RUN touch f2.txt

# Copia el archivo "index.html" del directorio de la máquina Host donde se encuentra este Dockerfile al directorio raíz del directorio de trabajo por defecto '/datos1' 
COPY index.html .
# Copia el archivo "app.log" del directorio de la máquina Host donde se encuentra este Dockerfile al directorio "/datos" del contenedor 
COPY app.log /datos

# La instrucción ADD hace lo mismo que la instrucción COPY pero tiene algunas funcionalidades extra como descomprimir archvios comprimidos y traerse datos de internet a través de una URL
# Copia el contenido del directorio "docs" desde el directorio de la máquina Host donde se encuentra este Dockerfile al directorio "docs" del directorio de trabajo por defecto '/datos1'(Si no existe ese directorio en "/datos1", se crea automáticamente)
ADD docs docs
# Copia todos los archivos que hagan match con la expresión "f*" del directorio de la máquina Host donde se encuentra este Dockerfile al directorio "/datos" del contenedor
ADD f* /datos
# Descomprime el archivo comprimido "f.tar" del directorio de la máquina Host donde se encuentra este Dockerfile en el directorio de trabajo por defecto '/datos1'
# Si se desea copiar este archivo comprimido "f.tar" al contenedor, se debe usar la instrucción COPY
ADD f.tar .

# La instrucción ENV nos permite crear variables de entorno en contenedores
# Estas variables de entorno también pueden ser usadas en el Dockerfile como variables accediendo al contenido de ellas a través de '$'
ENV dir=/data dir1=/data1
# Crea 2 directorios en el contenedor a partir del valor de las variables de entorno "dir" y "dir1"
RUN mkdir $dir && mkdir $dir1

# La instrucción ARG es similar a la instrucción ENV con la diferencia de que ARG nos permite pasar valores en el momento de la construcción de la imagen
# El valor de esta variable "dir2" se pasará en el momento de la construcción de la imagen(docker build ... --build-arg dir2='valor' ...)
#ARG dir2
# Crea 1 directorio en el contenedor a partir del valor de las variable "dir2"
#RUN mkdir $dir2
# El valor de esta variable "user" se pasará en el momento de la construcción de la imagen(docker build ... --build-arg user='valor' ...)
#ARG user
# Crea la varaible de entorno "user_docker" en el contenedor con el valor de la variable "user"
# Esta variable de entorno será usada por nuestro script "add-user.sh"
#ENV user_docker $user
# Copiamos nuestro script "add-user.sh", que se encuentra en el directorio de la máquina Host donde se encuentra este Dockerfile, al directorio "/datos1" del contenedor
#ADD add-user.sh /datos1
# Ejecuta el script "add-user.sh" dentro del contenedor
#RUN /datos1/add-user.sh

# La instrucción EXPOSE sirve para indicar,a modo de información, qué puertos utilizan, los servicios web, o servidores, que se crean en la imagen (¡Ojo! No hace público los puertos, únicamente informa a los usuarios que utilizan este Dockerfile sobre los puertos que se exponen)
# Variable de entrno para que no pregunte por el área geográfica durante la instalación de Apache
ENV DEBIAN_FRONTEND=noninteractive 
# Instala un servidor Apache que, por defecto escucha peticiones en el puerto 80, y, mediante la instrucción EXPOSE, informamos de ello
RUN apt-get install -y apache2
EXPOSE 80
# Copiamos nuestro script "entrypoint.sh"(arranca el servidor Apache), que se encuentra en el directorio de la máquina Host donde se encuentra este Dockerfile, al directorio "/datos1" del contenedor
ADD entrypoint.sh /datos1

# La instrucción VOLUME nos permite crear volúmenes para los contenedores de la imagen
# Copia el contenido del directorio "paginas" desde el directorio de la máquina Host donde se encuentra este Dockerfile al directorio "/var/www/html" del contenedor(Si no existe ese directorio en "/var/www/html", se crea automáticamente)
# Este directorio "/var/www/html" es donde el servidor Apache2 sirve por defecto las páginas web
ADD paginas /var/www/html
# Crea un volumen montado en el directorio "/var/www/html" del contenedor
VOLUME ["/var/www/html"]

# CMD ejecuta el comando que le indiquemos justo cuando arranca un contenedor de esta imagen
# Es decir, es el comando por defecto a ejecutar cuando arranca un contenedor
# Si ponemos el comando sin corchetes, se ejecuta ese comando en una shell("/bin/sh -c 'comando'" o "/bin/bash -c 'comando'" según el tipo de Linux)
#CMD echo "Wellcome to this container"
# Si ponemos el comando usando corchetes, se ejecuta ese comando usando exec, es decir, no se ejecuta en una shell
# Esta es la opción más usada y la recomendada
# Ejecuta una shell cuando arranca un contenedor de esta imagen
#CMD ["/bin/bash"]
# Ejecuta el script "entrypoint.sh" cuando arranca un contenedor de esta imagen
CMD /datos1/entrypoint.sh

# La instrucción ENTRYPOINT hace lo mismo que la instrucción CMD(Es el comando a ejecutar cuando arranca un contenedor de la imagen) pero tiene la siguiente diferencia:
# Si se usa CMD, el comando por defecto indicado en ese CMD puede ser sobrescrito por otro comando que se indique en el arranque del contendor(docker run ... 'comando')
# Sin embargo, si se usa ENTRYPOINT, el comando por defecto indicado en ese ENTRYPOINT no puede ser sobrescrito por otro comando indicado en el arranque del contenedor
# Pero con ENTRYPONT, si es posible añadir argumentos o parámetros al comando indicado en ese ENTRYPOINT desde el arranque de un contenedor(docker run ... 'args')
# Por ejemplo, "docker run ... -h" añade el argumento "-h" al comando "df" y se ejecutaría el comando "df -h" en el arranque del contenedor 
# Si un Dockerfile tiene muchas instrucciones CMD o ENTRYPOINT, el último CMD o ENTRYPOINT de ese Dockerfile es el que cuenta
# Muestra un listados de los espacios de disco
#ENTRYPOINT ["df"]
# Ejecuta una shell cuando arranca un contenedor de esta imagen
#ENTRYPOINT ["/bin/bash"]