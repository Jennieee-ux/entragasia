%% ============================================================
%%  SISTEMA EXPERTO: Apoyo a la elección de cursos (ISC)
%%  ------------------------------------------------------------
%%  Ayuda a alumnos, tutores y gestores a decidir qué materias
%%  puede cursar un alumno respetando la seriación y su
%%  desempeño académico, siguiendo estas reglas de negocio:
%%
%%   1. No se puede cursar una materia si no se aprobó su(s)
%%      materia(s) seriada(s) (prerrequisitos).
%%   2. No se pueden cargar más de 4 materias si el promedio
%%      general del alumno es menor a 80, o si tiene más de
%%      una materia reprobada.
%%   3. Se indica cuántas veces se ha cursado una materia y
%%      las calificaciones obtenidas en cada intento.
%%   4. Se indica si el alumno debe ser dado de baja (reprobó
%%      3 veces una misma materia).
%%   5. Se identifican los alumnos de alto rendimiento
%%      (promedio general >= 90).
%%   6. Se listan las materias por semestre y por área.
%%   7. Para abrir un curso de una materia, se indica cuántos
%%      aspirantes posibles existen.
%%
%%  El sistema se expone como un servidor HTTP con un conjunto
%%  de endpoints que regresan JSON, usando las librerías
%%  estándar de SWI-Prolog (http/thread_httpd, http/http_dispatch).
%%
%%  Ejecución:
%%      swipl server.pl
%%  (el servidor levanta en el puerto 8080, ver PUERTO más abajo)
%% ============================================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json)).
:- use_module(library(aggregate)).
:- use_module(library(lists)).

:- set_prolog_flag(double_quotes, codes).

% Calificación mínima aprobatoria (escala 0-100)
nota_aprobatoria(70).

% Carga máxima de materias en condiciones normales / restringidas
carga_maxima_normal(6).
carga_maxima_restringida(4).

% Número de reprobadas de una misma materia que provoca la baja
limite_reprobadas_baja(3).


%% ============================================================
%% 1) BASE DE CONOCIMIENTO: MATERIAS DEL PLAN DE ESTUDIOS DE ISC
%% ============================================================
%% materia(Codigo, Nombre, Semestre, Area).

materia(mat1,              'Matemáticas 1',                         1, matematicas).
materia(prog1,             'Programación 1',                        1, programacion).
materia(intro_isc,         'Introducción a la Ingeniería en Sistemas',1, formacion_general).
materia(comunicacion,      'Habilidades de Comunicación',           1, formacion_general).

materia(mat2,              'Matemáticas 2',                         2, matematicas).
materia(prog2,             'Programación 2',                        2, programacion).
materia(fisica1,           'Física 1',                              2, matematicas).
materia(estructuras_discretas, 'Estructuras Discretas',              2, matematicas).

materia(mat3,              'Matemáticas 3',                         3, matematicas).
materia(edd,               'Estructura de Datos',                   3, programacion).
materia(basesdatos1,       'Bases de Datos 1',                      3, basesdedatos).
materia(redes1,            'Fundamentos de Redes',                  3, redes).

materia(probabilidad,      'Probabilidad y Estadística',            4, matematicas).
materia(poo,               'Programación Orientada a Objetos',      4, programacion).
materia(basesdatos2,       'Bases de Datos 2',                      4, basesdedatos).
materia(so,                'Sistemas Operativos',                   4, redes).

materia(ingesoft1,         'Ingeniería de Software 1',              5, ingenieria_software).
materia(redes2,            'Redes 2',                               5, redes).
materia(algoritmos,        'Análisis de Algoritmos',                5, programacion).
materia(dev_web1,          'Desarrollo Web 1',                      5, programacion).

materia(ingesoft2,         'Ingeniería de Software 2',              6, ingenieria_software).
materia(dev_movil,         'Desarrollo Móvil',                      6, programacion).
materia(seguridad,         'Seguridad Informática',                 6, redes).
materia(ia,                'Inteligencia Artificial',               6, programacion).

%% Seriación: seriacion(Materia, Prerrequisito).
%% Significa que "Materia" exige tener aprobado "Prerrequisito".
seriacion(mat2,        mat1).
seriacion(mat3,        mat2).
seriacion(prog2,       prog1).
seriacion(edd,         prog2).
seriacion(basesdatos1, prog2).
seriacion(probabilidad,mat3).
seriacion(poo,         edd).
seriacion(basesdatos2, basesdatos1).
seriacion(so,          redes1).
seriacion(ingesoft1,   poo).
seriacion(redes2,      so).
seriacion(algoritmos,  edd).
seriacion(dev_web1,    basesdatos2).
seriacion(ingesoft2,   ingesoft1).
seriacion(dev_movil,   dev_web1).
seriacion(seguridad,   redes2).
seriacion(ia,          algoritmos).


%% ============================================================
%% 2) BASE DE CONOCIMIENTO: ALUMNOS E HISTORIAL ACADÉMICO
%% ============================================================
%% alumno(Matricula, Nombre).

alumno(a001, 'Ana Torres').
alumno(a002, 'Luis Medina').
alumno(a003, 'Carla Ruiz').
alumno(a004, 'Jorge Pineda').
alumno(a005, 'Marta Gil').

%% historial(Matricula, Materia, Intento, Calificacion).
%% Un alumno puede tener varios "intentos" (cursadas) de la
%% misma materia si la reprobó en ocasiones anteriores.

% --- a001: alumno de alto rendimiento (todo aprobado, promedio >= 90) ---
historial(a001, mat1,          1, 95).
historial(a001, prog1,         1, 92).
historial(a001, intro_isc,     1, 98).
historial(a001, comunicacion,  1, 90).
historial(a001, mat2,          1, 91).
historial(a001, prog2,         1, 93).

% --- a002: alumno regular, con una materia reprobada actualmente ---
historial(a002, mat1,          1, 60).
historial(a002, mat1,          2, 75).
historial(a002, prog1,         1, 80).
historial(a002, intro_isc,     1, 85).
historial(a002, comunicacion,  1, 78).
historial(a002, mat2,          1, 65).   % reprobada (posible candidato a re-cursar mat2)

% --- a003: alumno que debe ser dado de baja (reprobó mat1 3 veces) ---
historial(a003, mat1,          1, 55).
historial(a003, mat1,          2, 60).
historial(a003, mat1,          3, 58).
historial(a003, prog1,         1, 70).

% --- a004: promedio bajo y más de una materia reprobada (carga restringida) ---
historial(a004, mat1,          1, 68).
historial(a004, prog1,         1, 65).
historial(a004, intro_isc,     1, 72).
historial(a004, comunicacion,  1, 74).

% --- a005: alumno avanzado, elegible para materias de semestres altos ---
historial(a005, mat1,          1, 80).
historial(a005, prog1,         1, 82).
historial(a005, intro_isc,     1, 88).
historial(a005, comunicacion,  1, 84).
historial(a005, mat2,          1, 79).
historial(a005, prog2,         1, 81).
historial(a005, edd,           1, 77).
historial(a005, basesdatos1,   1, 83).
historial(a005, redes1,        1, 85).


%% ============================================================
%% 3) REGLAS DEL SISTEMA EXPERTO
%% ============================================================

%% aprobo(+Matricula, +Materia)
%% Verdadero si el alumno aprobó la materia en alguno de sus intentos.
aprobo(Matricula, Materia) :-
    nota_aprobatoria(Minima),
    historial(Matricula, Materia, _Intento, Calificacion),
    Calificacion >= Minima, !.

%% veces_cursada(+Matricula, +Materia, -Veces)
%% Cuántas veces ha cursado el alumno una materia (número de intentos).
veces_cursada(Matricula, Materia, Veces) :-
    findall(Intento, historial(Matricula, Materia, Intento, _), Intentos),
    length(Intentos, Veces).

%% calificaciones_materia(+Matricula, +Materia, -Lista)
%% Lista Intento-Calificacion de todos los intentos de una materia.
calificaciones_materia(Matricula, Materia, Lista) :-
    findall(Intento-Calificacion,
            historial(Matricula, Materia, Intento, Calificacion),
            Lista).

%% calificacion_oficial(+Matricula, +Materia, -Calificacion)
%% La calificación "vigente" de una materia es la del último intento.
calificacion_oficial(Matricula, Materia, Calificacion) :-
    aggregate_all(max(Intento), historial(Matricula, Materia, Intento, _), MaxIntento),
    historial(Matricula, Materia, MaxIntento, Calificacion).

%% materias_cursadas(+Matricula, -Materias)
%% Lista (sin duplicados) de las materias que un alumno ha cursado.
materias_cursadas(Matricula, MateriasUnicas) :-
    findall(Materia, historial(Matricula, Materia, _, _), Todas),
    sort(Todas, MateriasUnicas).

%% promedio_general(+Matricula, -Promedio)
%% Promedio de las calificaciones oficiales (último intento) de
%% todas las materias cursadas por el alumno.
promedio_general(Matricula, Promedio) :-
    materias_cursadas(Matricula, Materias),
    Materias \= [],
    findall(Calificacion,
            (member(M, Materias), calificacion_oficial(Matricula, M, Calificacion)),
            Calificaciones),
    sum_list(Calificaciones, Suma),
    length(Calificaciones, N),
    Promedio is Suma / N.
promedio_general(_Matricula, 0) :-
    % Si no tiene historial, se reporta promedio 0 (evita fallos en consultas).
    true.

%% reprobo_veces(+Matricula, +Materia, -N)
%% Número de intentos reprobados (calificación < mínima) de una materia.
reprobo_veces(Matricula, Materia, N) :-
    nota_aprobatoria(Minima),
    findall(C, (historial(Matricula, Materia, _, C), C < Minima), Reprobados),
    length(Reprobados, N).

%% num_materias_reprobadas(+Matricula, -N)
%% Cuántas materias distintas tiene reprobadas actualmente el alumno
%% (según su calificación oficial / último intento).
num_materias_reprobadas(Matricula, N) :-
    nota_aprobatoria(Minima),
    materias_cursadas(Matricula, Materias),
    findall(M,
            (member(M, Materias), calificacion_oficial(Matricula, M, C), C < Minima),
            Reprobadas),
    length(Reprobadas, N).

%% debe_baja(+Matricula)
%% Verdadero si el alumno reprobó 3 (o más) veces alguna materia.
debe_baja(Matricula) :-
    limite_reprobadas_baja(Limite),
    materias_cursadas(Matricula, Materias),
    member(M, Materias),
    reprobo_veces(Matricula, M, N),
    N >= Limite, !.

%% max_materias_permitidas(+Matricula, -Max)
%% Regla de carga académica:
%%   - Si promedio < 80  o  num. materias reprobadas > 1  => máx. 4 materias
%%   - En otro caso                                        => carga normal
max_materias_permitidas(Matricula, Max) :-
    promedio_general(Matricula, Promedio),
    num_materias_reprobadas(Matricula, NReprobadas),
    (   (Promedio < 80 ; NReprobadas > 1)
    ->  carga_maxima_restringida(Max)
    ;   carga_maxima_normal(Max)
    ).

%% seriacion_cumplida(+Matricula, +Materia)
%% Verdadero si el alumno aprobó TODOS los prerrequisitos de Materia.
%% (Si la materia no tiene seriación, se cumple trivialmente.)
seriacion_cumplida(Matricula, Materia) :-
    forall(seriacion(Materia, Prerrequisito), aprobo(Matricula, Prerrequisito)).

%% puede_cursar(+Matricula, +Materia)
%% Verdadero si el alumno puede inscribir la materia:
%%   - la materia existe en el plan
%%   - el alumno todavía no la ha aprobado
%%   - cumple la seriación (prerrequisitos aprobados)
puede_cursar(Matricula, Materia) :-
    materia(Materia, _, _, _),
    \+ aprobo(Matricula, Materia),
    seriacion_cumplida(Matricula, Materia).

%% materias_disponibles(+Matricula, -Lista)
%% Todas las materias que el alumno puede cursar en el siguiente periodo.
materias_disponibles(Matricula, Lista) :-
    findall(Materia, puede_cursar(Matricula, Materia), Lista).

%% alumnos_alto_rendimiento(-Lista)
%% Matrículas de los alumnos con promedio general >= 90.
alumnos_alto_rendimiento(Lista) :-
    findall(Matricula,
            (alumno(Matricula, _), promedio_general(Matricula, P), P >= 90),
            Lista).

%% aspirantes_materia(+Materia, -Lista)
%% Alumnos que podrían inscribirse a "Materia" si se abre un curso
%% (cumplen seriación y aún no la han aprobado).
aspirantes_materia(Materia, Lista) :-
    findall(Matricula,
            (alumno(Matricula, _), puede_cursar(Matricula, Materia)),
            Lista).

%% materias_por_semestre(+Semestre, -Lista)
materias_por_semestre(Semestre, Lista) :-
    findall(materia(Cod, Nombre, Semestre, Area),
            materia(Cod, Nombre, Semestre, Area),
            Lista).

%% materias_por_area(+Area, -Lista)
materias_por_area(Area, Lista) :-
    findall(materia(Cod, Nombre, Sem, Area),
            materia(Cod, Nombre, Sem, Area),
            Lista).


%% ============================================================
%% 4) CAPA HTTP: SERVIDOR Y ENDPOINTS (JSON)
%% ============================================================

:- http_handler(root(materias),                    listar_materias_handler,       []).
:- http_handler(root('materias/semestre'),          materias_semestre_handler,     []).
:- http_handler(root('materias/area'),              materias_area_handler,         []).
:- http_handler(root('alumno/historial'),           alumno_historial_handler,      []).
:- http_handler(root('alumno/puede_cursar'),         puede_cursar_handler,          []).
:- http_handler(root('alumno/materias_disponibles'), materias_disponibles_handler,  []).
:- http_handler(root('alumno/baja'),                 alumno_baja_handler,           []).
:- http_handler(root('alumno/promedio'),             alumno_promedio_handler,       []).
:- http_handler(root('alumnos/alto_rendimiento'),    alto_rendimiento_handler,      []).
:- http_handler(root('materia/aspirantes'),          aspirantes_handler,            []).

%% ---- Helpers de conversión a JSON ----

materia_json(materia(Cod, Nombre, Sem, Area),
             json([codigo=Cod, nombre=Nombre, semestre=Sem, area=Area])).

historial_item_json(Intento-Calificacion,
                     json([intento=Intento, calificacion=Calificacion])).

%% GET /materias
%% Lista todas las materias del plan de estudios.
listar_materias_handler(_Request) :-
    findall(materia(C,N,S,A), materia(C,N,S,A), Materias),
    maplist(materia_json, Materias, JsonList),
    reply_json_dict(_{materias: JsonList}).

%% GET /materias/semestre?semestre=3
listar_json_ok(Lista) :-
    maplist(materia_json, Lista, JsonList),
    reply_json_dict(_{materias: JsonList}).

materias_semestre_handler(Request) :-
    http_parameters(Request, [semestre(SemAtom, [])]),
    atom_number(SemAtom, Semestre),
    materias_por_semestre(Semestre, Lista),
    listar_json_ok(Lista).

%% GET /materias/area?area=programacion
materias_area_handler(Request) :-
    http_parameters(Request, [area(AreaAtom, [])]),
    materias_por_area(AreaAtom, Lista),
    listar_json_ok(Lista).

%% GET /alumno/historial?matricula=a002
%% Regresa, para cada materia cursada: cuántas veces se cursó
%% y las calificaciones de cada intento.
alumno_historial_handler(Request) :-
    http_parameters(Request, [matricula(MatAtom, [])]),
    Matricula = MatAtom,
    ( alumno(Matricula, Nombre) -> true ; Nombre = "desconocido" ),
    materias_cursadas(Matricula, Materias),
    findall(
        json([materia=Materia,
              veces_cursada=Veces,
              calificaciones=CalifJson]),
        ( member(Materia, Materias),
          veces_cursada(Matricula, Materia, Veces),
          calificaciones_materia(Matricula, Materia, Califs),
          maplist(historial_item_json, Califs, CalifJson)
        ),
        Detalle),
    reply_json_dict(_{matricula: Matricula, nombre: Nombre, historial: Detalle}).

%% GET /alumno/puede_cursar?matricula=a002&materia=mat2
puede_cursar_handler(Request) :-
    http_parameters(Request, [matricula(MatAtom, []), materia(MatCodAtom, [])]),
    Matricula = MatAtom,
    MateriaCod = MatCodAtom,
    ( puede_cursar(Matricula, MateriaCod)
    ->  Resultado = true, Razon = "cumple seriacion y no la ha aprobado"
    ;   ( aprobo(Matricula, MateriaCod)
        -> Resultado = false, Razon = "ya aprobo la materia"
        ;  Resultado = false, Razon = "no cumple con la seriacion (prerrequisitos)"
        )
    ),
    reply_json_dict(_{matricula: Matricula, materia: MateriaCod,
                       puede_cursar: Resultado, razon: Razon}).

%% GET /alumno/materias_disponibles?matricula=a005
%% Materias que el alumno puede cursar, respetando también el
%% número máximo de materias permitido según su desempeño.
materias_disponibles_handler(Request) :-
    http_parameters(Request, [matricula(MatAtom, [])]),
    Matricula = MatAtom,
    materias_disponibles(Matricula, Disponibles),
    max_materias_permitidas(Matricula, Max),
    reply_json_dict(_{matricula: Matricula,
                       materias_disponibles: Disponibles,
                       maximo_materias_permitidas: Max}).

%% GET /alumno/baja?matricula=a003
alumno_baja_handler(Request) :-
    http_parameters(Request, [matricula(MatAtom, [])]),
    Matricula = MatAtom,
    ( debe_baja(Matricula) -> Baja = true ; Baja = false ),
    reply_json_dict(_{matricula: Matricula, debe_ser_dado_de_baja: Baja}).

%% GET /alumno/promedio?matricula=a001
alumno_promedio_handler(Request) :-
    http_parameters(Request, [matricula(MatAtom, [])]),
    Matricula = MatAtom,
    promedio_general(Matricula, Promedio),
    num_materias_reprobadas(Matricula, NReprobadas),
    reply_json_dict(_{matricula: Matricula,
                       promedio_general: Promedio,
                       materias_reprobadas_actualmente: NReprobadas}).

%% GET /alumnos/alto_rendimiento
alto_rendimiento_handler(_Request) :-
    alumnos_alto_rendimiento(Lista),
    reply_json_dict(_{alumnos_alto_rendimiento: Lista}).

%% GET /materia/aspirantes?materia=mat2
aspirantes_handler(Request) :-
    http_parameters(Request, [materia(MatCodAtom, [])]),
    MateriaCod = MatCodAtom,
    aspirantes_materia(MateriaCod, Lista),
    length(Lista, Cantidad),
    reply_json_dict(_{materia: MateriaCod,
                       cantidad_aspirantes: Cantidad,
                       aspirantes: Lista}).


%% ============================================================
%% 5) ARRANQUE DEL SERVIDOR
%% ============================================================

puerto(8080).

servidor :-
    puerto(Puerto),
    http_server(http_dispatch, [port(Puerto)]),
    format("~n~n=========================================================~n"),
    format("  Servidor del Sistema Experto de Cursos ISC~n"),
    format("  Escuchando en http://localhost:~w~n", [Puerto]),
    format("=========================================================~n~n"),
    format("Endpoints disponibles:~n"),
    format("  GET /materias~n"),
    format("  GET /materias/semestre?semestre=3~n"),
    format("  GET /materias/area?area=programacion~n"),
    format("  GET /alumno/historial?matricula=a002~n"),
    format("  GET /alumno/puede_cursar?matricula=a002&materia=mat2~n"),
    format("  GET /alumno/materias_disponibles?matricula=a005~n"),
    format("  GET /alumno/baja?matricula=a003~n"),
    format("  GET /alumno/promedio?matricula=a001~n"),
    format("  GET /alumnos/alto_rendimiento~n"),
    format("  GET /materia/aspirantes?materia=mat2~n~n").

:- initialization(servidor, main).
