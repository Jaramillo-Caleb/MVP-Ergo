# Lógica de Detección de Postura

Este documento explica el comportamiento del sistema cuando se detecta una mala postura.

## 1. El Bucle de Monitoreo (`Monitoring Loop`)
El sistema no analiza constantemente cada frame para ahorrar CPU/Batería. Utiliza dos estados de frecuencia:
- **Modo Normal**: Análisis cada **10 segundos**.
- **Modo Ráfaga (Burst)**: Análisis cada **2 segundos** (se activa al detectar un error).

## 2. Proceso de Análisis
1. **Captura**: Se toma una foto silenciosa desde la cámara principal.
2. **Comparación IA**: Se envía el frame y el "vector de referencia" (la postura que guardaste al calibrar) al motor nativo en C#.
3. **Resultado**: La IA devuelve si la postura actual coincide con la de referencia dentro de un umbral de tolerancia.

## 3. Comportamiento ante Mala Postura
Cuando la IA determina que la postura es **Incorrecta**:

- **Cambio de Estado**: El indicador visual en el Dashboard cambia a rojo ("Incorrecto").
- **Activación de Ráfaga**: El sistema reduce el tiempo de espera a **2 segundos**. Esto permite verificar rápidamente si el usuario se corrigió o si fue un error momentáneo.
- **Contador de Errores**: Se inicia un contador de errores consecutivos.

## 4. Sistema de Alertas (Notificaciones)
Para evitar molestar al usuario con falsos positivos, las notificaciones de Windows se envían siguiendo esta regla:
- **1er Error**: No hay notificación (espera a confirmar en el siguiente ciclo).
- **2do Error Consecutivo**: Se envía la **primera alerta** ("ERGO: Alerta de Postura").
- **Errores Siguientes**: Si el usuario sigue en mala postura, se envía un recordatorio cada **5 análisis** (aprox. cada 10 segundos en modo ráfaga).

## 5. Recuperación
En cuanto el sistema detecta **un solo frame correcto**:
- El contador de errores vuelve a **0**.
- Se desactiva el Modo Ráfaga (vuelve a analizar cada **10 segundos**).
- El indicador visual vuelve a verde ("Correcto").
