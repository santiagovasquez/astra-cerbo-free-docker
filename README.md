# 📡 Astra Cerbo Free en Docker - Plataforma de Streaming Satelital por UDP

Este proyecto contiene una configuración completa de **Astra Cerbo Free** en un contenedor **Docker**, permitiendo levantar canales de televisión satelital usando una tarjeta **TBS** (como la **TBS6909**) y transmitirlos vía **UDP** sobre red local o internet.

El corazón del sistema es el script `stream.lua`, que define adaptadores DVB, decodificadores Newcamd y salidas por canal.

---

## ✅ Requisitos del Sistema

### Hardware
- Tarjeta **TBS6909** o compatible con drivers para Linux
- Fuente de señal satelital activa

### Software
- Sistema operativo: **Ubuntu** o cualquier distribución **Linux**
- Docker & Docker Compose instalados
- Drivers DVB instalados correctamente (verifica `/dev/dvb/adapterX`)

---

## 📁 Estructura del Proyecto

```
astra-docker/
├── astra-free/
│   └── scripts/
│       └── stream.lua        # Script principal de configuración
├── Dockerfile                # Imagen Docker de Astra
├── docker-compose.yml        # Orquestación de servicios
└── README.md                 # Este documento
```

---

## ⚙️ Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/santiagovasquez/astra-cerbo-free-docker.git
cd astra-docker
```

### 2. Editar el script de canales

Abre y modifica `astra-free/scripts/stream.lua` para agregar tus adaptadores, lectores y canales:

```bash
nano astra-free/scripts/stream.lua
```

### 3. Construir e iniciar el contenedor

```bash
docker compose up --build -d
```

---

## 🛠️ Configuración de `stream.lua`

Este archivo controla toda la lógica de captura y salida de canales.

### 🔧 Ejemplo básico

```lua
-- Escanea un transpondedor desde el adaptador 0 (S2)
adapter_1 = dvb_tune({
    type = "S2",
    adapter = 0,
    tp = "11422:H:30000"
})

-- Escanea otro desde el adaptador 1 (S)
adapter_2 = dvb_tune({
    type = "S",
    adapter = 1,
    tp = "12390:V:30000"
})

-- Lectores Newcamd (decodificación)
reader_1 = newcamd({
    name = "Newcamd #1",
    host = "dominio.com",
    port = 11000,
    user = "usuario1",
    pass = "clave1",
    key  = "0102030405060708091011121314"
})

reader_2 = newcamd({
    name = "Newcamd #2",
    host = "dominio.com",
    port = 10005,
    user = "usuario2",
    pass = "clave2",
    key  = "0102030405060708091011121314"
})

-- Canales y sus salidas por UDP
make_channel({
    name = "Caracol",
    input = {
        "dvb://adapter_1#pnr=464&cam=reader_1"
    },
    output = {
        "udp://0.0.0.0:1111",
        "udp://0.0.0.0:2222"
    },
    timeout = 5
})

make_channel({
    name = "RCN",
    input = {
        "dvb://adapter_2#pnr=466&cam=reader_2"
    },
    output = {
        "udp://0.0.0.0:3333"
    },
    timeout = 5
})
```

---

## 🐳 Dockerfile

```Dockerfile
FROM ubuntu:22.04

RUN apt-get update &&     apt-get install -y wget ca-certificates libglib2.0-0 libssl-dev libz-dev &&     rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN wget http://download.astra.cesbo.com/astra-cesbo-free_1.19.7_amd64.deb &&     dpkg -i astra-cesbo-free_1.19.7_amd64.deb

COPY astra-free /opt/astra-free

ENTRYPOINT ["astra", "/opt/astra-free/scripts/stream.lua"]
```

---

## 🧬 docker-compose.yml

```yaml
version: '3.7'

services:
  astra:
    build: .
    container_name: astra
    restart: unless-stopped
    privileged: true
    volumes:
      - ./astra-free:/opt/astra-free
    devices:
      - /dev/dvb:/dev/dvb
```

> 🔒 Nota: Se requiere `privileged: true` y el mapeo de `/dev/dvb` para acceder al hardware DVB dentro del contenedor.

---

## ✅ Validar Salida de Canales

Puedes verificar que el canal está saliendo correctamente por UDP usando VLC o FFmpeg:

```bash
ffplay udp://@0.0.0.0:1111
```

O en VLC:

```
Archivo > Red > udp://@0.0.0.0:1111
```

---

## ♻️ Mantenimiento

### Reiniciar tras editar `stream.lua`

```bash
docker compose restart
```

### Ver logs

```bash
docker logs -f astra
```

### Detener el servicio

```bash
docker compose down
```

---

## 🧠 Recursos Adicionales

- Sitio oficial de Astra: [https://cesbo.com](https://cesbo.com)
- Drivers TBS Astra: [https://help.cesbo.com/misc/tools-and-utilities/dvb/tbs-driver](https://help.cesbo.com/misc/tools-and-utilities/dvb/tbs-driver)
- Documentación oficial Docker: [https://docs.docker.com](https://docs.docker.com)

---

## 🛑 Consideraciones Legales

Este proyecto no incluye ni promueve contenido ilegal. Asegúrate de contar con los permisos legales necesarios para recibir y retransmitir señales satelitales.

---