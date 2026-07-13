/**
 * Perceptrón + Ingeniería de características para la compuerta XOR
 * -----------------------------------------------------------------
 * El XOR no es linealmente separable en el espacio original (x1, x2).
 * Se aplica una transformación de características (kernel polinomial
 * de grado 2, expandido explícitamente) que agrega el término cruzado
 * x1*x2 como una tercera dimensión:
 *
 *      phi(x1, x2) = (x1, x2, x1*x2)
 *
 * En este nuevo espacio 3D, las 4 combinaciones de XOR SÍ son
 * separables por un plano, y el perceptrón puede aprenderlo.
 *
 * Ejecutar con: node perceptron_xor.js
 */

// ---- 1. Datos de la compuerta XOR ----
const rawInputs = [
  [0, 0],
  [0, 1],
  [1, 0],
  [1, 1],
];
const targets = [0, 1, 1, 0]; // salida esperada de XOR

// ---- 2. Ingeniería de características (kernel polinomial grado 2) ----
// phi(x1, x2) = (x1, x2, x1*x2)
function featureMap([x1, x2]) {
  return [x1, x2, x1 * x2];
}

const X = rawInputs.map(featureMap);

// ---- 3. Perceptrón simple (regla de aprendizaje del perceptrón) ----
class Perceptron {
  constructor(nInputs, learningRate = 0.1) {
    this.weights = new Array(nInputs).fill(0).map(() => Math.random() * 0.2 - 0.1);
    this.bias = 0;
    this.lr = learningRate;
  }

  activate(z) {
    return z >= 0 ? 1 : 0; // función escalón
  }

  predict(x) {
    const z = x.reduce((sum, xi, i) => sum + xi * this.weights[i], 0) + this.bias;
    return this.activate(z);
  }

  train(X, y, epochs = 100) {
    for (let epoch = 0; epoch < epochs; epoch++) {
      let errors = 0;
      for (let i = 0; i < X.length; i++) {
        const pred = this.predict(X[i]);
        const error = y[i] - pred;
        if (error !== 0) {
          errors++;
          for (let j = 0; j < this.weights.length; j++) {
            this.weights[j] += this.lr * error * X[i][j];
          }
          this.bias += this.lr * error;
        }
      }
      if (errors === 0) {
        console.log(`Convergió en la época ${epoch + 1}`);
        break;
      }
    }
  }
}

// ---- 4. Entrenamiento ----
const model = new Perceptron(3, 0.1);
model.train(X, targets, 200);

// ---- 5. Resultados ----
console.log("\nPesos finales:", model.weights.map((w) => w.toFixed(3)));
console.log("Bias final:", model.bias.toFixed(3));

console.log("\nEntrada (x1,x2) | phi(x1,x2,x1*x2) | esperado | predicho");
rawInputs.forEach((raw, i) => {
  const x = X[i];
  const pred = model.predict(x);
  console.log(
    `(${raw[0]}, ${raw[1]})       | (${x.join(", ")})       | ${targets[i]}        | ${pred}`
  );
});

// El plano separador aprendido, en el espacio (x1, x2, x1*x2), es:
//   w1*x1 + w2*x2 + w3*(x1*x2) + b = 0
console.log(
  `\nPlano separador: (${model.weights[0].toFixed(2)})*x1 + (${model.weights[1].toFixed(
    2
  )})*x2 + (${model.weights[2].toFixed(2)})*(x1*x2) + (${model.bias.toFixed(2)}) = 0`
);
