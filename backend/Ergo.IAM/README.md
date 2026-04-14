# ERGO: Sistema Inteligente de Asistencia Ergonómica

ERGO es una plataforma de salud ocupacional basada en **Edge Computing** e **IA**. 
Este repositorio contiene el microservicio de **Identidad y Acceso (IAM)**.

## 🚀 Tecnologías
- **Backend:** .NET 9 (C#) con Clean Architecture.
- **Base de Datos:** SQLite + SQLCipher (Cifrado AES-256 local).
- **Seguridad:** JWT (JSON Web Tokens) y BCrypt para hashing.
- **Infraestructura:** Docker & Docker Compose.

## 🛠 Estructura de Proyecto
- `src/Ergo.IAM.Core`: Entidades de dominio e interfaces.
- `src/Ergo.IAM.Infrastructure`: Persistencia con EF Core y SQLCipher.
- `src/Ergo.IAM.Api`: Controladores REST y configuración.

## 📦 Ejecución con Docker
Desde la raíz del proyecto global:
```bash
docker-compose up --build
🔒 Privacidad (Startup Vision)
A diferencia de otras soluciones, ERGO no envía datos biométricos a la nube.
Las credenciales y perfiles se almacenan en el equipo del usuario de forma cifrada.
code
Code
---

### Nota final sobre el Gateway:
Para que el Gateway redirija las llamadas a `ergo-iam`, asegúrate de que en el `appsettings.json` del **Gateway (YARP)** tengas configurada la ruta. Algo como:

```json
"Routes": {
  "iam-route": {
    "ClusterId": "iam-cluster",
    "Match": { "Path": "/api/auth/{**catch-all}" }
  }