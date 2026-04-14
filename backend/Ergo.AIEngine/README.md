# Ergo.AIEngine Microservice

Microservicio de visión por computadora para detección y evaluación de postura ergonómica. Desarrollado en Python (FastAPI + MediaPipe) y containerizado con Docker para fácil integración.

---

## Despliegue Rápido (Docker) - Recomendado

Esta es la forma estándar para ejecución en producción o integración con el equipo de .NET, garantizando que no existan conflictos de librerías.

### 1. Construir la imagen

```bash
docker build -t ergo-ai-engine .
```

### 2. Ejecutar el contenedor

```bash
docker run -d -p 8000:8000 --name ergo-service ergo-ai-engine
```

El servicio estará disponible en: **http://localhost:8000**

---

## Instalación Local (Para Desarrollo)

Si necesitas modificar el código fuente o depurar, sigue estos pasos.

### 1. Clonar el repositorio

```bash
git clone https://github.com/Jaramillo-Caleb/Ergo.git
cd Ergo/Ergo.AIEngine
```

### 2. Crear entorno virtual

**Windows:**

```bash
python -m venv venv
.\venv\Scripts\activate
```

**Linux / Mac:**

```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Instalar dependencias

Nota: Este proyecto utiliza versiones específicas de mediapipe y protobuf para estabilidad.

```bash
pip install -r requirements.txt
```

### 4. Configurar Variables de Entorno

Crea un archivo `.env` en la raíz (puedes basarte en env.example):

```ini
# .env
PROJECT_NAME="Ergo.AIEngine"
MIN_IMAGES_REQUIRED=5
# Umbral de similitud (0.0 a 1.0)
SIMILARITY_THRESHOLD=0.85
```

### 5. Ejecución (Hot Reload)

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

---

## Integración con .NET (API Contract)

Para facilitar el consumo de este servicio en C#, se incluye el archivo de especificación OpenAPI.

**Archivo:** `openapi.json` (en la raíz del repo).

**Uso:** En Visual Studio, usar la opción "Connected Services" → "OpenAPI" e importar este archivo para generar automáticamente las clases y el cliente HTTP.

---

## Endpoints Principales (Prefijo `/internal`)

### 1. Calibrar Postura (Calibration)

Genera el "Ground Truth" o vector de referencia personalizado.

- **Método:** `POST /internal/calibration`
- **Body:** `multipart/form-data` con array de imágenes.

### 2. Comparar Postura (Monitoring)

Valida un frame actual contra el vector de referencia.

- **Método:** `POST /internal/compare`
- **Body:** `multipart/form-data`
  - `image`: Imagen actual (File).
  - `reference_vector`: JSON String del vector obtenido en calibración.

---

## Estructura del Proyecto

Arquitectura en capas desacopladas:

```
Ergo.AIEngine/
├── api/                # Rutas FastAPI
├── core/               # Lógica de Negocio
│   ├── landmark/       # Wrappers de MediaPipe
│   ├── math/           # Geometría (Euclidiana, RBF)
│   └── normalization/  # Algoritmos (Z-Score)
├── models/             # Esquemas Pydantic
├── services/           # Orquestación (Facade)
├── Dockerfile          # Configuración de Contenedor
├── openapi.json        # Contrato de API
├── requirements.txt    # Dependencias (Headless)
└── main.py             # Entrypoint
```

---

## Detalles Técnicos (Algoritmos)

### Normalización Z-Score

Para mitigar el sesgo por distancia a la cámara, las coordenadas (x,y,z) se normalizan:

```
z = (x - μ) / σ
```

Esto centra la postura en el origen (0,0,0) con escala unitaria.

### Similitud Vectorial (RBF Kernel)

La puntuación se calcula transformando la distancia euclidiana mediante un Kernel Radial:

```
Score = e^(-distancia / σ)
```

Donde σ = 10.0 controla la tolerancia del sistema.

---

## Licencia y Autoría

**Autor:** Caleb Josué Jaramillo Rendón  
**Entidad:** Universidad de Caldas – Semillero TECSIS  
**Año:** 2026 

Desarrollado como parte del proyecto de investigación ERGO: Sistema Inteligente de Asistencia Ergonómica.