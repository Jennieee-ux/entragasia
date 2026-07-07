# SE 2 - Sistema Experto para la Asignación de Desarrolladores

Este proyecto implementa un sistema experto desarrollado con **Tau-Prolog**, cuyo objetivo es determinar si existe el personal suficiente para asignar equipos de trabajo a proyectos de software según su nivel de complejidad.

A diferencia de SWI-Prolog, esta versión funciona completamente desde el navegador gracias a **Tau-Prolog**, por lo que no es necesario instalar programas adicionales ni ejecutar un servidor.

## Requisitos de personal

Cada proyecto requiere una cantidad mínima de desarrolladores de acuerdo con su nivel.

| Nivel del proyecto | Personal requerido |
|--------------------|-------------------|
| Bajo | 1 avanzado y 1 junior |
| Medio | 1 senior y 1 avanzado |
| Alto | 1 senior, 1 avanzado y 1 junior |
| Muy alto | 1 senior, 2 avanzados y 2 junior |

## Requisitos

- Navegador web moderno (Chrome, Firefox, Edge o similar).
- Conexión a Internet para cargar la biblioteca Tau-Prolog desde un CDN.

## Ejecución

No es necesario instalar software.

Solo abre el archivo:

```
proyectos.html
```

El sistema cargará automáticamente la base de conocimiento y permitirá realizar consultas desde la interfaz web.

El archivo **kb.pl** se incluye únicamente como respaldo de la base de conocimiento escrita en Prolog; la versión utilizada por la aplicación se encuentra integrada dentro del archivo **proyectos.html**.

## Base de conocimiento

El sistema incluye información de ejemplo para realizar pruebas.

- 10 desarrolladores con distintos niveles de experiencia.
  - 3 Junior
  - 4 Avanzados
  - 3 Senior

- 10 proyectos clasificados por dificultad.
  - 3 de nivel bajo
  - 3 de nivel medio
  - 2 de nivel alto
  - 2 de nivel muy alto

Además, dos desarrolladores (**Hugo** y **Diego**) aparecen como ocupados en otros proyectos, por lo que no se consideran disponibles al momento de realizar la asignación.

## Funcionalidades

El sistema permite:

- Consultar el listado de desarrolladores registrados y su nivel.
- Mostrar los proyectos disponibles y su nivel de complejidad.
- Verificar si existe suficiente personal para desarrollar un proyecto.
- Identificar qué perfiles profesionales hacen falta contratar cuando el personal disponible no es suficiente.
- Ejecutar consultas personalizadas directamente sobre la base de conocimiento.

## Consultas disponibles

La interfaz proporciona consultas como:

- Mostrar desarrolladores disponibles.
- Mostrar proyectos registrados.
- Verificar si un proyecto cuenta con el personal requerido.
- Consultar el personal faltante para un proyecto.

También es posible escribir consultas Prolog manualmente.

Ejemplos:

```prolog
disponibles_nivel(senior, L).

cuenta_disponibles(avanzado, N).
```

## Tecnologías utilizadas

- Tau-Prolog
- JavaScript
- HTML5
- CSS
