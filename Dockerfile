FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias necesarias para compilar Astra
RUN apt-get update && apt-get install -y \
    build-essential \
    make \
    gcc \
    g++ \
    libdvbcsa-dev \
    lua5.1 \
    lua5.1-dev \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copiar los archivos del proyecto al contenedor
COPY . /astra

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /astra

# Ejecutar el script de configuración y compilar el proyecto
RUN chmod +x configure.sh && ./configure.sh && make

# Exponer el puerto en el que el servicio Astra escucha
EXPOSE 3035

# Comando para ejecutar el binario del proyecto
CMD ["./astra", "--stream"]
