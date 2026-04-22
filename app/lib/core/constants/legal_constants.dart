class LegalConstants {
  static const String termsAndConditionsTitle = 'Términos y Condiciones - ERGO';
  static const String termsAndConditionsText = """
TÉRMINOS, CONDICIONES Y POLÍTICA DE PRIVACIDAD DE ERGO

1. NATURALEZA DEL SISTEMA
ERGO es un Sistema Inteligente de Asistencia Ergonómica desarrollado en el marco del Semillero TECSIS de la Universidad de Caldas. Su objetivo es el monitoreo postural y la gestión de la productividad.

2. PRIVACIDAD Y PROCESAMIENTO EN EL BORDE (EDGE COMPUTING)
Garantizamos el Nivel 1 de Privacidad Física. El procesamiento de video y extracción biométrica se realiza de manera 100% local en la memoria RAM de su equipo, utilizando el componente Ergo.AIEngine. NINGÚN FOTOGRAMA O VIDEO ES TRANSMITIDO A LA NUBE NI ALMACENADO PERMANENTEMENTE.

3. ALMACENAMIENTO DE DATOS LOCALES
La información de su historial postural se almacena localmente en su dispositivo en una base de datos cifrada de grado militar (AES-256 mediante SQLCipher).

4. TELEMETRÍA E INVESTIGACIÓN TÉCNICA
Al utilizar este software, usted acepta que el componente 'SyncAgent' recopile y transmita asincrónicamente vectores matemáticos anonimizados y resúmenes estadísticos a nuestra infraestructura en la nube (PostgreSQL/MongoDB). Estos datos son utilizados EXCLUSIVAMENTE para fines de investigación en salud ocupacional por parte de los investigadores del Semillero TECSIS, sin comprometer su identidad.

5. IDENTIDAD Y SEGURIDAD
El acceso multiplataforma está protegido mediante un esquema de Seguridad Escalonada (RBAC). Sus credenciales son manejadas por el microservicio Ergo.IAM bajo estrictos protocolos de seguridad.

Al aceptar estos términos, usted comprende el alcance investigativo y técnico de la plataforma ERGO.
""";
}