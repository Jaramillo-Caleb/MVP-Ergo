# Ergo.Gateway (Reverse Proxy)

**Tipo de Servicio:** Fachada / Infraestructura  
**Tecnología:** .NET 9, YARP (Yet Another Reverse Proxy)  
**Puerto Docker:** 8080

## Descripción General
Este microservicio actúa como el punto único de entrada (Single Entry Point) para la aplicación de escritorio ERGO (Cliente Flutter). Su función es desacoplar el cliente de la topología interna de microservicios, proporcionando seguridad, enrutamiento y control de tráfico.

## Responsabilidades (Clean Architecture)
1.  **Enrutamiento Inteligente:** Redirige las peticiones HTTP a los clusters internos (`WorkSession`, `IAM`, `Tasks`) basándose en la URL.
2.  **Seguridad (JWT):** Realiza una validación preliminar de la firma del token Bearer antes de permitir el paso de la petición.
3.  **Rate Limiting:** Protege los servicios internos de ataques de denegación de servicio o bucles infinitos accidentales en el cliente, limitando el número de peticiones por segundo.
4.  **Ocultamiento de Red:** Evita que el cliente conozca las direcciones IP o puertos reales de los contenedores Docker.

## Configuración (appsettings.json)
El enrutamiento se define mediante `ReverseProxy:Routes` y `ReverseProxy:Clusters`.

- **Ruta `/api/auth/*`** -> Cluster `ergo-iam`
- **Ruta `/api/work-session/*`** -> Cluster `ergo-work-session`
- **Ruta `/api/tasks/*`** -> Cluster `ergo-tasks`

## Ejecución

### Docker (Recomendado)
El servicio se orquesta automáticamente mediante el `docker-compose` en la raíz del proyecto.
```bash
docker-compose up -d --build ergo-gateway
Local (.NET CLI)
code
Bash
cd src
dotnet run
Proyecto de Investigación ERGO - Universidad de Caldas
code
Code
---

### Resumen de Ubicación

Tu carpeta `C:\Users\jaram\Desktop\ErgoProject\src\Ergo.Gateway\` debería verse así ahora:

```text
├── src/                (Carpeta con de código .cs y .csproj)
├── .dockerignore       (Archivo creado arriba)
├── Dockerfile          (Archivo creado arriba)
└── README.md           (Archivo creado arriba)