````markdown
# Ergo.WorkSession Microservice

Microservicio orquestador de **Datos Calientes (Hot Data)** y gestión de sesiones de trabajo. Desarrollado en **.NET 9** utilizando **Clean Architecture** y **Minimal APIs** para garantizar alto rendimiento y bajo consumo de recursos.

Este servicio actúa como el cerebro lógico del sistema **ERGO**, coordinando la comunicación entre la interfaz de usuario y el motor de IA.

---

## Despliegue Rápido (Docker) 

Esta es la forma estándar para ejecución en producción o integración con el ecosistema ERGO.

### 1. Construir la imagen

```bash
docker build -t ergo-worksession .
````

### 2. Ejecutar el contenedor

Es necesario montar un volumen para persistir la base de datos SQLite y conectar el servicio a la misma red que el motor de IA.

```bash
docker run -d \
  -p 5000:8080 \
  -v ergo_data:/app/data \
  --name ergo-worksession \
  ergo-worksession
```

El servicio estará disponible en:
`http://localhost:5000`

---

## Instalación Local (Para Desarrollo)

Si necesitas modificar el código fuente o depurar, sigue estos pasos.

### 1. Prerrequisitos

* .NET 9 SDK instalado.

### 2. Restaurar dependencias

```bash
dotnet restore
```

### 3. Ejecutar el servicio

```bash
dotnet run --project src/Ergo.WorkSession.API/Ergo.WorkSession.API.csproj
```

La API iniciará (por defecto) en `http://localhost:5xxx`.
Al iniciar, el sistema creará automáticamente la base de datos SQLite (`WorkSession.db`) si no existe.

---

## Documentación de API (Swagger / OpenAPI)

El servicio expone una interfaz interactiva para probar los endpoints sin necesidad de herramientas externas.

* **Swagger UI**: `http://localhost:5xxx/swagger`
* **OpenAPI JSON**: `http://localhost:5xxx/swagger/v1/swagger.json`

(Este JSON puede importarse directamente en Postman).

---

## Endpoints Principales (`/api/work-session`)

### 1. Iniciar Sesión (Start)

Abre una nueva jornada de trabajo y cierra cualquier sesión anterior que haya quedado abierta.

* **Método**: `POST /api/work-session/start`
* **Headers**:

  * `X-User-Id`: UUID del usuario

---

### 2. Calibrar (Calibration)

Recibe un set de imágenes, las envía al motor de IA y almacena el vector de referencia resultante en la base de datos de la sesión.

* **Método**: `POST /api/work-session/calibrate`
* **Body**: `multipart/form-data`

  * Array de imágenes

---

### 3. Monitorear (Monitor)

Endpoint crítico (**Hot Path**).
Recibe una imagen cada 1s o 10s, recupera el vector de referencia desde memoria y consulta la validación al motor de IA.

* **Método**: `POST /api/work-session/monitor`
* **Body**: `multipart/form-data`

  * `image`: captura actual de la webcam
* **Respuesta**:

  * Estado de alerta
  * Puntaje de similitud
  * Mensaje de corrección

---

## Estructura del Proyecto

El proyecto sigue estrictamente **Clean Architecture** para desacoplar la lógica de negocio de la infraestructura.

```text
Ergo.WorkSession/
├── src/
│   ├── Ergo.WorkSession.Domain/         # Núcleo (Entidades: WorkSession, ReferencePose)
│   ├── Ergo.WorkSession.Application/    # Casos de Uso (SessionOrchestrator)
│   ├── Ergo.WorkSession.Infrastructure/ # Persistencia (SQLite) y Cliente HTTP (IA)
│   └── Ergo.WorkSession.API/            # Entrada (Minimal APIs, Configuración)
├── tests/                               # Pruebas Unitarias
├── Dockerfile                           # Configuración de Contenedor
└── README.md                            # Documentación
```

---

## Detalles Técnicos

### Gestión de Datos Calientes (Hot Data)

A diferencia de sistemas tradicionales, **WorkSession** mantiene en memoria el contexto necesario (Vector de Referencia) para minimizar la latencia de lectura en disco durante el ciclo de monitoreo rápido (**Fast Loop**).

### Orquestación de IA

Este servicio actúa como un **Proxy Inteligente**.
No procesa imágenes, pero sabe qué hacer con los resultados:

* Si el **Score < Umbral** → marca `IsAlert = true`.
* Registra el evento en el historial (`PostureEvents`).
* Notifica al cliente si es necesario activar el modo de corrección.

### Persistencia Híbrida

Utiliza **SQLite** con conversión de valores (`ValueConverter`) para almacenar vectores matemáticos complejos como cadenas JSON, manteniendo la simplicidad de un archivo local sin requerir bases de datos vectoriales dedicadas.

---

## Licencia y Autoría

* **Autor**: Caleb Josué Jaramillo Rendón
* **Entidad**: Universidad de Caldas — Semillero TECSIS
* **Año**: 2026

Desarrollado como parte del proyecto de investigación **ERGO: Sistema Inteligente de Asistencia Ergonómica**.

```
```
