# SE 3 - Sistema Experto para el Control de Ingredientes

Este proyecto consiste en un sistema experto desarrollado en **Go** que funciona desde la consola y permite administrar la preparación de platillos mediante la verificación del inventario disponible.

Su propósito es apoyar al personal de cocina para comprobar si existen los ingredientes necesarios para elaborar un platillo y, en caso contrario, indicar cuáles hacen falta y en qué cantidad.

## Requisitos

- Go 1.21 o una versión superior.
- Descarga disponible en: https://go.dev/dl/

## Ejecución

Desde la terminal, ejecutar:

```bash
go run main.go
```

Al iniciar el programa se mostrará un menú interactivo donde el usuario podrá seleccionar distintas opciones relacionadas con los platillos y el inventario.

## Organización del programa

El sistema está compuesto por las siguientes estructuras:

- **Ingrediente:** almacena el nombre, la cantidad requerida y la unidad de medida.
- **Platillo:** representa una receta junto con todos los ingredientes necesarios para prepararla.
- **Inventario:** contiene las existencias actuales de los ingredientes disponibles en la cocina.
- **Menú:** reúne todos los platillos registrados en el sistema.

## Funcionalidades

Entre las principales operaciones que realiza el sistema se encuentran:

- Mostrar los ingredientes que necesita un platillo.
- Comprobar si el inventario cuenta con los ingredientes suficientes para preparar una receta.
- Informar qué ingredientes hacen falta y la cantidad necesaria para completar la preparación.

## Casos de prueba

El sistema incluye un menú de ejemplo con cuatro recetas:

- Enchiladas Verdes
- Chiles Rellenos
- Pozole Rojo
- Ensalada César

El inventario inicial fue configurado para representar diferentes escenarios:

- **Pozole Rojo:** dispone de todos los ingredientes necesarios.
- **Chiles Rellenos:** presenta falta de queso Oaxaca.
- **Ensalada César:** tiene varios ingredientes insuficientes.

Estos casos permiten comprobar el funcionamiento de todas las reglas implementadas por el sistema.

## Tecnologías utilizadas

- Go
- Programación orientada a estructuras
- Aplicación de consola
