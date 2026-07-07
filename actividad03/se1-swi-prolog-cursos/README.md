# Sistema Experto para la Gestión de Inscripción Académica

Este proyecto consiste en un sistema experto desarrollado en **SWI-Prolog** que ayuda en el proceso de inscripción de materias para estudiantes de Ingeniería en Sistemas Computacionales (ISC).

El sistema utiliza reglas de conocimiento para determinar qué asignaturas puede cursar un alumno, tomando en cuenta sus prerrequisitos, su historial académico y su rendimiento escolar. Además, ofrece información útil para tutores y coordinadores sobre el desempeño de los estudiantes y la posible apertura de grupos.

## Requisitos

- SWI-Prolog 9.x o superior.
- Disponible en: https://www.swi-prolog.org/

## Ejecución

Para iniciar el servidor, ejecutar:

```bash
swipl servidor.pl
```

Una vez iniciado, el servicio estará disponible en:

```
http://localhost:8080
```

## Funcionalidades

El sistema permite:

- Verificar que un estudiante cumpla con los prerrequisitos antes de inscribir una materia.
- Limitar la carga académica cuando el promedio sea menor de 80 o existan más de una materia reprobada.
- Consultar el número de intentos y las calificaciones obtenidas en cada asignatura.
- Detectar estudiantes que deben causar baja por reprobar tres veces la misma materia.
- Identificar alumnos con desempeño sobresaliente (promedio igual o mayor a 90).
- Consultar las materias organizadas por semestre y por área de conocimiento.
- Calcular cuántos estudiantes podrían inscribirse en una materia para apoyar la apertura de un grupo.

## Servicios disponibles

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/materias` | Muestra todas las materias registradas. |
| GET | `/materias/semestre?semestre=3` | Consulta las materias de un semestre específico. |
| GET | `/materias/area?area=programacion` | Lista las materias pertenecientes a un área. |
| GET | `/alumno/historial?matricula=a002` | Devuelve el historial académico del alumno. |
| GET | `/alumno/puede_cursar?matricula=a002&materia=mat2` | Indica si el alumno puede inscribir una materia. |
| GET | `/alumno/materias_disponibles?matricula=a005` | Muestra las materias disponibles y el límite permitido de carga. |
| GET | `/alumno/baja?matricula=a003` | Verifica si el alumno debe ser dado de baja. |
| GET | `/alumno/promedio?matricula=a001` | Consulta el promedio general y las materias reprobadas. |
| GET | `/alumnos/alto_rendimiento` | Obtiene la lista de alumnos con promedio destacado. |
| GET | `/materia/aspirantes?materia=mat2` | Muestra los posibles aspirantes a una materia. |

## Casos de prueba

Se incluyen diferentes perfiles de estudiantes para validar el funcionamiento del sistema:

- **a001:** estudiante con excelente rendimiento académico.
- **a002:** alumno que aprobó una materia después de un segundo intento y mantiene una reprobada.
- **a003:** estudiante que reprobó la misma asignatura tres veces.
- **a004:** alumno con bajo promedio y varias materias reprobadas, por lo que tiene restricción en su carga académica.
- **a005:** estudiante con avance suficiente para cursar materias de niveles superiores.

## Ejemplos de consulta

```bash
curl "http://localhost:8080/alumno/baja?matricula=a003"

curl "http://localhost:8080/alumnos/alto_rendimiento"

curl "http://localhost:8080/materia/aspirantes?materia=mat2"
```

## Tecnologías utilizadas

- SWI-Prolog
- Biblioteca HTTP de SWI-Prolog
- Servicios REST
- JSON
