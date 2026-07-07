%% ============================================================
%%  SISTEMA EXPERTO: Asignación de programadores a proyectos
%%  ------------------------------------------------------------
%%  Este archivo documenta la base de conocimiento en Prolog puro
%%  (misma sintaxis que se ejecuta embebida dentro de proyectos.html
%%  usando el motor Tau-Prolog en el navegador).
%%
%%  No requiere SWI-Prolog: se ejecuta 100% en JavaScript mediante
%%  la librería Tau-Prolog (https://github.com/tau-prolog/tau-prolog).
%%
%%  Reglas de asignación por nivel de proyecto:
%%    bajo      -> 1 avanzado + 1 junior
%%    medio     -> 1 senior  + 1 avanzado
%%    alto      -> 1 senior  + 1 avanzado + 1 junior
%%    muy_alto  -> 1 senior  + 2 avanzados + 2 junior
%% ============================================================

:- use_module(library(lists)).

% ---------- 10 DESARROLLADORES FICTICIOS ----------
% desarrollador(Id, Nombre, Nivel).
desarrollador(d1,  ana,    junior).
desarrollador(d2,  bruno,  junior).
desarrollador(d3,  carla,  junior).
desarrollador(d4,  diego,  avanzado).
desarrollador(d5,  elena,  avanzado).
desarrollador(d6,  fabio,  avanzado).
desarrollador(d7,  gina,   avanzado).
desarrollador(d8,  hugo,   senior).
desarrollador(d9,  irene,  senior).
desarrollador(d10, jose,   senior).

% ---------- 10 PROYECTOS FICTICIOS ----------
% proyecto(Id, Nombre, Nivel).
proyecto(p1,  proyecto_a, bajo).
proyecto(p2,  proyecto_b, bajo).
proyecto(p3,  proyecto_c, bajo).
proyecto(p4,  proyecto_d, medio).
proyecto(p5,  proyecto_e, medio).
proyecto(p6,  proyecto_f, medio).
proyecto(p7,  proyecto_g, alto).
proyecto(p8,  proyecto_h, alto).
proyecto(p9,  proyecto_i, muy_alto).
proyecto(p10, proyecto_j, muy_alto).

% ---------- ASIGNACIONES ACTUALES (desarrolladores ya ocupados) ----------
% asignado(IdDesarrollador, IdProyecto).
% Estos desarrolladores ya trabajan en otro proyecto activo, por lo
% que NO están disponibles para un nuevo proyecto.
asignado(d8, p4).   % hugo (senior)   ya trabaja en proyecto_d
asignado(d4, p1).   % diego (avanzado) ya trabaja en proyecto_a

% ---------- REQUISITOS DE PERSONAL POR NIVEL DE PROYECTO ----------
% requiere(NivelProyecto, junior(N), avanzado(N), senior(N)).
requiere(bajo,     junior(1), avanzado(1), senior(0)).
requiere(medio,    junior(0), avanzado(1), senior(1)).
requiere(alto,     junior(1), avanzado(1), senior(1)).
requiere(muy_alto, junior(2), avanzado(2), senior(1)).

% ---------- REGLAS ----------

% disponible(D): el desarrollador D no está asignado a ningún proyecto.
disponible(D) :-
    desarrollador(D, _, _),
    \+ asignado(D, _).

% disponibles_nivel(Nivel, Lista): desarrolladores disponibles de un nivel.
disponibles_nivel(Nivel, Lista) :-
    findall(D, (desarrollador(D, _, Nivel), disponible(D)), Lista).

% cuenta_disponibles(Nivel, N): cuántos disponibles hay de ese nivel.
cuenta_disponibles(Nivel, N) :-
    disponibles_nivel(Nivel, Lista),
    length(Lista, N).

% 1) lista_desarrolladores(L): todos los desarrolladores con su nivel.
lista_desarrolladores(L) :-
    findall(dev(Id, Nombre, Nivel), desarrollador(Id, Nombre, Nivel), L).

% 2) lista_proyectos(L): todos los proyectos con su nivel.
lista_proyectos(L) :-
    findall(proy(Id, Nombre, Nivel), proyecto(Id, Nombre, Nivel), L).

% 3) tiene_personal(Proyecto): existe suficiente personal DISPONIBLE
%    (no asignado a otro proyecto) para cubrir los requisitos del
%    nivel del proyecto dado.
tiene_personal(Proyecto) :-
    proyecto(Proyecto, _, Nivel),
    requiere(Nivel, junior(J), avanzado(A), senior(S)),
    cuenta_disponibles(junior, CJ),   CJ >= J,
    cuenta_disponibles(avanzado, CA), CA >= A,
    cuenta_disponibles(senior, CS),   CS >= S.

% 4) personal_faltante(Proyecto, Faltantes): lista de faltante(Nivel,Cantidad)
%    que indica cuántas personas de cada nivel hace falta contratar.
personal_faltante(Proyecto, Faltantes) :-
    proyecto(Proyecto, _, Nivel),
    requiere(Nivel, junior(J), avanzado(A), senior(S)),
    cuenta_disponibles(junior, CJ),
    cuenta_disponibles(avanzado, CA),
    cuenta_disponibles(senior, CS),
    findall(faltante(NivelReq, Cantidad),
        ( member(NivelReq-Requerido-Disponible,
                 [junior-J-CJ, avanzado-A-CA, senior-S-CS]),
          Cantidad is Requerido - Disponible,
          Cantidad > 0
        ),
        Faltantes).
