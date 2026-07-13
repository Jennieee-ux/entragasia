/**
 * Perceptrón aplicado a la compuerta XOR usando INGENIERÍA DE CARACTERÍSTICAS
 * -----------------------------------------------------------------------
 * El problema clásico: XOR no es linealmente separable en el espacio
 * original (x1, x2). Un perceptrón simple (una sola capa, sin capas
 * ocultas) NUNCA puede aprender XOR en ese espacio, sin importar cuántas
 * épocas se entrenen.
 *
 * Solución (kernel / ingeniería de características):
 *   En vez de cambiar el modelo (agregar capas ocultas = MLP), se
 *   transforma la ENTRADA con un mapeo de características que agrega
 *   el término de interacción x1*x2 (equivalente al término cruzado
 *   que introduce un kernel polinomial de grado 2):
 *
 *        phi(x1, x2) = [ x1, x2, x1*x2 ]
 *
 *   Identidad notable para valores binarios {0,1}:
 *        XOR(x1, x2) = x1 + x2 - 2*x1*x2
 *
 *   Esto significa que, en el espacio transformado de 3 dimensiones
 *   (x1, x2, z) con z = x1*x2, las 4 muestras SÍ son separables por un
 *   plano (un perceptrón lineal de una sola capa puede resolverlas).
 *
 * Este script:
 *   1. Genera las características phi(x1,x2) = [x1, x2, x1*x2]
 *   2. Entrena un perceptrón clásico (regla de aprendizaje de Rosenblatt)
 *   3. Verifica que converge y clasifica correctamente las 4 combinaciones
 *   4. Imprime el plano separador encontrado: w1*x1 + w2*x2 + w3*z + b = 0
 */

// ---------- 1. Datos originales de la compuerta XOR ----------
const rawInputs = [
  [0, 0],
  [0, 1],
  [1, 0],
  [1, 1],
];
const labels = [0, 1, 1, 0]; // salida esperada de XOR

// ---------- 2. Ingeniería de características (kernel polinomial grado 2) ----------
// phi(x1, x2) = [x1, x2, x1*x2]
function featureMap([x1, x2]) {
  return [x1, x2, x1 * x2];
}

const X = rawInputs.map(featureMap);
// X = [[0,0,0], [0,1,0], [1,0,0], [1,1,1]]

// ---------- 3. Perceptrón (algoritmo de Rosenblatt) ----------
class Perceptron {
  constructor(nFeatures, lr = 0.1) {
    this.weights = new Array(nFeatures).fill(0);
    this.bias = 0;
    this.lr = lr;
  }

  activate(z) {
    return z >= 0 ? 1 : 0; // función escalón
  }

  predict(x) {
    const z = x.reduce((sum, xi, i) => sum + xi * this.weights[i], this.bias);
    return this.activate(z);
  }

  train(X, y, maxEpochs = 100) {
    for (let epoch = 1; epoch <= maxEpochs; epoch++) {
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
      console.log(
        `Época ${epoch}: errores=${errors}  pesos=[${this.weights
          .map((w) => w.toFixed(3))
          .join(", ")}]  bias=${this.bias.toFixed(3)}`
      );
      if (errors === 0) {
        console.log(`\n✅ Convergencia alcanzada en la época ${epoch}`);
        return epoch;
      }
    }
    console.log("\n⚠️ No convergió dentro del número máximo de épocas");
    return -1;
  }
}

// ---------- 4. Entrenamiento ----------
const perceptron = new Perceptron(3, 0.5);
perceptron.train(X, labels, 50);

// ---------- 5. Verificación final ----------
console.log("\n--- Verificación de la compuerta XOR con features [x1, x2, x1*x2] ---");
rawInputs.forEach((raw, i) => {
  const feats = featureMap(raw);
  const pred = perceptron.predict(feats);
  console.log(
    `x1=${raw[0]} x2=${raw[1]}  z=x1*x2=${feats[2]}  =>  predicho=${pred}  esperado=${labels[i]}  ${
      pred === labels[i] ? "OK" : "FALLÓ"
    }`
  );
});

// ---------- 6. Ecuación del plano separador ----------
const [w1, w2, w3] = perceptron.weights;
const b = perceptron.bias;
console.log(
  `\nPlano separador en el espacio (x1, x2, z):\n` +
    `  ${w1.toFixed(3)}*x1 + ${w2.toFixed(3)}*x2 + ${w3.toFixed(3)}*z + ${b.toFixed(3)} = 0\n` +
    `donde z = x1 * x2 (característica agregada por ingeniería de características).`
);
