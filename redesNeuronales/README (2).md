# Redes Neuronales — Tarea Final: Perceptrón + XOR

Aplicación de un perceptrón a la compuerta XOR mediante ingeniería de características (kernel), de modo que el problema —no linealmente separable en su espacio original— se vuelve separable en un espacio transformado.

## Estructura del repositorio

```
redesNeuronales/
├── README(2).md
├── codigo/
│   └── perceptron_xor.js       # Perceptrón + ingeniería de características (Node.js)
├── imagenes/
│   ├── plot_xor.py             # Script para generar las gráficas
│   ├── xor_2d.png              # XOR en el espacio original (no separable)
│   ├── xor_3d_plane.png        # XOR en el espacio transformado + plano separador
│   └── vista_lateral.png       # Vista lateral del plano (opcional)
└── presentacion/
    ├── Presentacion_XOR.pdf
    └── Presentacion_XOR.pptx
```

## Cómo ejecutar el código

Requisitos: Node.js instalado.

```bash
cd codigo
node perceptron_xor.js
```

Esto entrena el perceptrón sobre los datos de XOR ya transformados y muestra en consola los pesos finales, el sesgo y la predicción para cada uno de los cuatro casos.

---

# 1. Ingeniería de características (Kernel)

Las entradas originales `(x1, x2)` se transforman agregando una tercera característica basada en la conjunción lógica:

```
φ(x1, x2) = (x1, x2, x1·x2)
```

Este término `x1*x2` corresponde a una expansión equivalente a un kernel polinomial de grado 2, permitiendo que el problema sea linealmente separable.

Los cuatro casos quedan transformados así:

| (x1,x2) | φ(x1,x2) | Clase |
|---------|----------|--------|
| (0,0) | (0,0,0) | 0 |
| (0,1) | (0,1,0) | 1 |
| (1,0) | (1,0,0) | 1 |
| (1,1) | (1,1,1) | 0 |

---

# 2. Plano de separación

En el espacio transformado, un corte únicamente sobre `x3` no es suficiente para separar correctamente las clases, ya que tres puntos tienen `x3 = 0` y solo uno tiene `x3 = 1`.

Por ello, el perceptrón utiliza las tres características para encontrar un plano de separación:

```
w1*x1 + w2*x2 + w3*(x1*x2) + b = 0
```

Después del entrenamiento se obtuvo el siguiente plano:

```
0.5·x1 + 0.5·x2 − 1.5·z − 0.5 = 0
```

donde:

```
z = x1·x2
```

Este plano separa correctamente:

- Clase 0 → (0,0,0) y (1,1,1)
- Clase 1 → (0,1,0) y (1,0,0)

---

# 3. Resultados

El perceptrón entrenado sobre las características transformadas converge en 8 épocas (η = 0.1) y clasifica correctamente el 100 % de los casos de XOR, algo que un perceptrón simple no puede lograr en el espacio original.

---

# Cómo visualizar el resultado en GeoGebra 3D

Para comprobar la separación de forma gráfica:

1. Abrir GeoGebra 3D Calculator.
2. Ingresar los cuatro puntos:

```
(0,0,0)
(0,1,0)
(1,0,0)
(1,1,1)
```

3. Ingresar el plano:

```
0.5x + 0.5y − 1.5z − 0.5 = 0
```

Se observará que los puntos pertenecientes a la clase 0 quedan de un lado del plano y los de la clase 1 del otro, confirmando la separación lineal en el espacio transformado.

---

## Cómo regenerar las gráficas

```bash
cd imagenes
pip install matplotlib
python3 plot_xor.py
```

---

## Subir el proyecto a GitHub

```bash
git add .
git commit -m "Perceptrón XOR con ingeniería de características"
git push
```
