// ============================================================
// SISTEMA EXPERTO: Control de ingredientes de un menú
// ------------------------------------------------------------
// Ayuda al cocinero a saber:
//  1. Qué ingredientes lleva un guiso (platillo) del menú.
//  2. Si existen en el inventario todos los ingredientes
//     necesarios (en cantidad suficiente) para preparar un guiso.
//  3. Qué ingredientes (y cuánto) faltan para un guiso dado.
//
// Ejecución:
//     go run main.go
// ============================================================
package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strconv"
	"strings"
)

// Ingrediente representa la cantidad necesaria de un insumo
// dentro de la receta de un platillo.
type Ingrediente struct {
	Nombre   string
	Cantidad float64
	Unidad   string
}

// Platillo representa un guiso del menú y su lista de ingredientes.
type Platillo struct {
	Nombre      string
	Ingredientes []Ingrediente
}

// Inventario lleva el control de existencias por ingrediente.
// La llave es el nombre del ingrediente (en minúsculas) y el valor
// es la cantidad disponible junto con su unidad de medida.
type Inventario struct {
	Existencias map[string]Ingrediente
}

// NuevoInventario crea un inventario vacío.
func NuevoInventario() *Inventario {
	return &Inventario{Existencias: make(map[string]Ingrediente)}
}

// Agregar registra o actualiza la existencia de un ingrediente.
func (inv *Inventario) Agregar(nombre string, cantidad float64, unidad string) {
	clave := strings.ToLower(nombre)
	inv.Existencias[clave] = Ingrediente{Nombre: nombre, Cantidad: cantidad, Unidad: unidad}
}

// Cantidad disponible de un ingrediente (0 si no existe en inventario).
func (inv *Inventario) Cantidad(nombre string) float64 {
	if ing, ok := inv.Existencias[strings.ToLower(nombre)]; ok {
		return ing.Cantidad
	}
	return 0
}

// ------------------------------------------------------------
// REGLAS DEL SISTEMA EXPERTO
// ------------------------------------------------------------

// IngredientesDe regresa la lista de ingredientes que lleva un guiso.
func (p *Platillo) IngredientesDe() []Ingrediente {
	return p.Ingredientes
}

// FaltantesPara compara los ingredientes requeridos por el platillo
// contra el inventario disponible y regresa la lista de ingredientes
// que faltan (o que no alcanzan en cantidad), junto con cuánto falta.
func (p *Platillo) FaltantesPara(inv *Inventario) []Ingrediente {
	var faltantes []Ingrediente
	for _, req := range p.Ingredientes {
		disponible := inv.Cantidad(req.Nombre)
		if disponible < req.Cantidad {
			faltante := Ingrediente{
				Nombre:   req.Nombre,
				Cantidad: req.Cantidad - disponible,
				Unidad:   req.Unidad,
			}
			faltantes = append(faltantes, faltante)
		}
	}
	return faltantes
}

// TieneTodosLosIngredientes indica si el inventario alcanza para
// preparar el platillo completo (no hay ningún faltante).
func (p *Platillo) TieneTodosLosIngredientes(inv *Inventario) bool {
	return len(p.FaltantesPara(inv)) == 0
}

// ------------------------------------------------------------
// MENÚ (base de conocimiento de platillos)
// ------------------------------------------------------------

// Menu agrupa todos los platillos disponibles, indexados por nombre
// en minúsculas para facilitar la búsqueda.
type Menu struct {
	Platillos map[string]*Platillo
}

func NuevoMenu() *Menu {
	return &Menu{Platillos: make(map[string]*Platillo)}
}

func (m *Menu) Agregar(p *Platillo) {
	m.Platillos[strings.ToLower(p.Nombre)] = p
}

func (m *Menu) Buscar(nombre string) (*Platillo, bool) {
	p, ok := m.Platillos[strings.ToLower(nombre)]
	return p, ok
}

func (m *Menu) NombresOrdenados() []string {
	var nombres []string
	for _, p := range m.Platillos {
		nombres = append(nombres, p.Nombre)
	}
	sort.Strings(nombres)
	return nombres
}

// construirMenu crea la base de conocimiento con platillos de ejemplo.
func construirMenu() *Menu {
	menu := NuevoMenu()

	menu.Agregar(&Platillo{
		Nombre: "Enchiladas Verdes",
		Ingredientes: []Ingrediente{
			{"tortilla de maiz", 12, "pza"},
			{"pollo", 500, "g"},
			{"tomate verde", 400, "g"},
			{"chile serrano", 3, "pza"},
			{"crema", 200, "ml"},
			{"queso fresco", 150, "g"},
			{"cebolla", 1, "pza"},
		},
	})

	menu.Agregar(&Platillo{
		Nombre: "Chiles Rellenos",
		Ingredientes: []Ingrediente{
			{"chile poblano", 6, "pza"},
			{"queso oaxaca", 300, "g"},
			{"huevo", 4, "pza"},
			{"harina", 100, "g"},
			{"jitomate", 500, "g"},
			{"cebolla", 1, "pza"},
			{"aceite", 250, "ml"},
		},
	})

	menu.Agregar(&Platillo{
		Nombre: "Pozole Rojo",
		Ingredientes: []Ingrediente{
			{"maiz pozolero", 1, "kg"},
			{"carne de cerdo", 800, "g"},
			{"chile guajillo", 8, "pza"},
			{"ajo", 4, "pza"},
			{"lechuga", 1, "pza"},
			{"rabano", 6, "pza"},
			{"oregano", 10, "g"},
		},
	})

	menu.Agregar(&Platillo{
		Nombre: "Ensalada Cesar",
		Ingredientes: []Ingrediente{
			{"lechuga romana", 1, "pza"},
			{"pollo", 300, "g"},
			{"queso parmesano", 80, "g"},
			{"pan", 100, "g"},
			{"aderezo cesar", 100, "ml"},
		},
	})

	return menu
}

// construirInventario simula el inventario actual de la cocina.
func construirInventario() *Inventario {
	inv := NuevoInventario()
	inv.Agregar("tortilla de maiz", 20, "pza")
	inv.Agregar("pollo", 700, "g")
	inv.Agregar("tomate verde", 250, "g") // insuficiente para enchiladas verdes
	inv.Agregar("chile serrano", 5, "pza")
	inv.Agregar("crema", 200, "ml")
	inv.Agregar("queso fresco", 150, "g")
	inv.Agregar("cebolla", 3, "pza")
	inv.Agregar("chile poblano", 2, "pza") // insuficiente para chiles rellenos
	inv.Agregar("huevo", 12, "pza")
	inv.Agregar("harina", 500, "g")
	inv.Agregar("jitomate", 500, "g")
	inv.Agregar("aceite", 1000, "ml")
	inv.Agregar("maiz pozolero", 2, "kg")
	inv.Agregar("carne de cerdo", 800, "g")
	inv.Agregar("chile guajillo", 8, "pza")
	inv.Agregar("ajo", 10, "pza")
	inv.Agregar("lechuga", 2, "pza")
	inv.Agregar("rabano", 6, "pza")
	inv.Agregar("oregano", 50, "g")
	// Nota: no hay existencia de "queso oaxaca", "lechuga romana",
	// "queso parmesano", "pan" ni "aderezo cesar" en el inventario.
	return inv
}

// ------------------------------------------------------------
// INTERFAZ DE CONSOLA
// ------------------------------------------------------------

func imprimirIngredientes(ings []Ingrediente) {
	for _, i := range ings {
		fmt.Printf("  - %-20s %.2f %s\n", i.Nombre, i.Cantidad, i.Unidad)
	}
}

func menuPrincipal() {
	fmt.Println("=========================================================")
	fmt.Println(" Sistema Experto: Control de Ingredientes de un Menú")
	fmt.Println("=========================================================")

	menu := construirMenu()
	inventario := construirInventario()

	lector := bufio.NewReader(os.Stdin)

	for {
		fmt.Println("\nPlatillos disponibles en el menú:")
		for i, nombre := range menu.NombresOrdenados() {
			fmt.Printf("  %d) %s\n", i+1, nombre)
		}
		fmt.Println("\nOpciones:")
		fmt.Println("  1) Ver ingredientes de un guiso")
		fmt.Println("  2) Verificar si existen todos los ingredientes de un guiso")
		fmt.Println("  3) Ver ingredientes faltantes de un guiso")
		fmt.Println("  0) Salir")
		fmt.Print("\nElige una opción: ")

		opcionTexto, _ := lector.ReadString('\n')
		opcion, err := strconv.Atoi(strings.TrimSpace(opcionTexto))
		if err != nil {
			fmt.Println("Opción inválida.")
			continue
		}
		if opcion == 0 {
			fmt.Println("Hasta luego, chef.")
			return
		}
		if opcion < 1 || opcion > 3 {
			fmt.Println("Opción inválida.")
			continue
		}

		fmt.Print("Escribe el nombre del guiso: ")
		nombreGuiso, _ := lector.ReadString('\n')
		nombreGuiso = strings.TrimSpace(nombreGuiso)

		platillo, existe := menu.Buscar(nombreGuiso)
		if !existe {
			fmt.Printf("No se encontró el guiso \"%s\" en el menú.\n", nombreGuiso)
			continue
		}

		switch opcion {
		case 1:
			fmt.Printf("\nIngredientes de \"%s\":\n", platillo.Nombre)
			imprimirIngredientes(platillo.IngredientesDe())

		case 2:
			if platillo.TieneTodosLosIngredientes(inventario) {
				fmt.Printf("\nSI, hay existencias suficientes para preparar \"%s\".\n", platillo.Nombre)
			} else {
				fmt.Printf("\nNO, faltan ingredientes para preparar \"%s\".\n", platillo.Nombre)
			}

		case 3:
			faltantes := platillo.FaltantesPara(inventario)
			if len(faltantes) == 0 {
				fmt.Printf("\nNo falta ningún ingrediente para \"%s\".\n", platillo.Nombre)
			} else {
				fmt.Printf("\nIngredientes faltantes para \"%s\":\n", platillo.Nombre)
				imprimirIngredientes(faltantes)
			}
		}
	}
}

func main() {
	menuPrincipal()
}
