# Redes Neuronales — Tarea Final: Perceptrón + XOR

Aplicación de un perceptrón a la compuerta XOR mediante ingeniería de
características (kernel), de modo que el problema —no linealmente separable
en su espacio original— se vuelve separable en un espacio transformado.

## Estructura del repositorio

```
redesNeuronales/
├── codigo/
│   └── perceptron_xor.js       # Perceptrón + ingeniería de características (Node.js)
├── presentacion/
│   ├── Presentacion_XOR.pdf    # Explicación del kernel y gráficas del plano separador
│   ├── xor_2d.png              # XOR en el espacio original (no separable)
│   └── xor_3d_plane.png        # XOR en el espacio transformado + plano separador
└── README.md
```

## Cómo ejecutar el código

Requisitos: Node.js instalado.

```bash
cd codigo
node perceptron_xor.js
```

Esto entrena el perceptrón sobre los datos de XOR ya transformados y muestra
en consola los pesos finales, el sesgo, y la predicción para cada uno de los
4 casos.

## 1. Ingeniería de características (el kernel)

Las entradas originales (x1, x2) se transforman agregando una tercera
característica basada en la conjunción lógica:

    phi(x1, x2) = (x1, x2, x1 * x2)

Este término x3 = x1*x2 es el que introduce un kernel polinomial de grado 2
—K(x,z) = (x·z + 1)²— al expandirlo explícitamente. Con él, los 4 puntos del
XOR pasan a:

| (x1,x2) | phi(x1,x2) | Clase |
|---|---|---|
| (0,0) | (0,0,0) | 0 |
| (0,1) | (0,1,0) | 1 |
| (1,0) | (1,0,0) | 1 |
| (1,1) | (1,1,1) | 0 |

## 2. Plano de separación

En el espacio 3D transformado, un umbral simple sobre x3 (por ejemplo
x3 = 0.5) **no alcanza** a separar las clases correctamente: 3 de los 4
puntos tienen x3 = 0 y solo uno tiene x3 = 1, así que un corte únicamente en
x3 deja mal clasificados a (0,0,0) frente a (0,1,0)/(1,0,0). Por eso el
perceptrón necesita usar las **tres** características (x1, x2, x1*x2) para
encontrar el plano correcto:

    w1*x1 + w2*x2 + w3*(x1*x2) + b = 0

Con los pesos aprendidos (ver `presentacion/Presentacion_XOR.pdf`), ese plano
sí separa {(0,0,0), (1,1,1)} (clase 0) de {(0,1,0), (1,0,0)} (clase 1). La
gráfica `xor_3d_plane.png` muestra este plano junto con los 4 puntos.

## 3. Resultados

El perceptrón, entrenado sobre las características expandidas, converge en
8 épocas (tasa de aprendizaje eta = 0.1) y clasifica correctamente el 100%
de los casos de XOR — algo imposible de lograr con un perceptrón simple en
el espacio original (x1, x2).
