% =============================================================
% SISTEMA INTELIGENTE DE GESTION DE SALUD Y BIENESTAR PERSONAL
% Motor de inferencia en Prolog
% Curso: SOF-23 Lenguajes y paradigmas de programacion
% Modulo: Base de conocimiento y motor logico 
% =============================================================
%
% Este archivo modela, mediante hechos y reglas, el dominio de
% salud y bienestar solicitado en el enunciado del proyecto:
%   1. Condiciones de salud
%   2. Grupos de alimentos y sus propiedades
%   3. Tipos de actividad fisica
%   4. Niveles de actividad del usuario
%   5. Objetivos de bienestar
%   6. Habitos de descanso
%
% Y expone predicados de consulta (motor de inferencia) que la
% aplicacion (microservicio en Java/Python/Node) invocara para
% obtener recomendaciones estructuradas, las cuales luego seran
% enriquecidas por la IA generativa.
%
% Para ejecutar:  swipl salud_bienestar.pl
% Para probar:    swipl -g run_tests -t halt salud_bienestar.pl
% =============================================================


% =====================================================
% 1. CONDICIONES DE SALUD
% =====================================================
% condicion(NombreCondicion).

condicion(diabetes_tipo2).
condicion(hipertension).
condicion(hipotiroidismo).
condicion(obesidad).
condicion(anemia).
condicion(intolerancia_lactosa).
condicion(celiaquia).
condicion(ninguna).   % perfil sin condiciones preexistentes


% =====================================================
% 2. GRUPOS DE ALIMENTOS Y SUS PROPIEDADES
% =====================================================
% alimento(NombreAlimento, GrupoNutricional).
% propiedad_alimento(NombreAlimento, Propiedad).
%
% Las propiedades son las que se cruzan contra las restricciones
% de cada condicion para decidir si un alimento es apto o no.

% --- Proteinas ---
alimento(pechuga_pollo, proteinas).
alimento(pescado_blanco, proteinas).
alimento(lentejas, proteinas).
alimento(huevo, proteinas).
alimento(tofu, proteinas).
alimento(carne_roja_procesada, proteinas).

% --- Carbohidratos ---
alimento(arroz_blanco, carbohidratos).
alimento(arroz_integral, carbohidratos).
alimento(pan_blanco, carbohidratos).
alimento(pan_integral, carbohidratos).
alimento(avena, carbohidratos).
alimento(quinoa, carbohidratos).
alimento(azucar_refinada, carbohidratos).
alimento(papa, carbohidratos).

% --- Grasas ---
alimento(aceite_oliva, grasas).
alimento(palta, grasas).
alimento(frituras, grasas).
alimento(mantequilla, grasas).
alimento(frutos_secos, grasas).

% --- Vitaminas / vegetales y frutas ---
alimento(brocoli, vitaminas).
alimento(espinaca, vitaminas).
alimento(naranja, vitaminas).
alimento(zanahoria, vitaminas).
alimento(banano, vitaminas).

% --- Fibra ---
alimento(chia, fibra).
alimento(frijoles, fibra).
alimento(brocoli, fibra).      % un alimento puede pertenecer a mas de un grupo
alimento(avena, fibra).

% --- Lacteos (para intolerancia a la lactosa) ---
alimento(leche_entera, proteinas).
alimento(queso_maduro, proteinas).
alimento(yogur_deslactosado, proteinas).
alimento(leche_almendra, proteinas).

% Propiedades relevantes de cada alimento
propiedad_alimento(arroz_blanco, alto_indice_glucemico).
propiedad_alimento(pan_blanco, alto_indice_glucemico).
propiedad_alimento(azucar_refinada, alto_indice_glucemico).
propiedad_alimento(papa, alto_indice_glucemico).

propiedad_alimento(arroz_integral, bajo_indice_glucemico).
propiedad_alimento(quinoa, bajo_indice_glucemico).
propiedad_alimento(avena, bajo_indice_glucemico).
propiedad_alimento(lentejas, bajo_indice_glucemico).
propiedad_alimento(frijoles, bajo_indice_glucemico).

propiedad_alimento(carne_roja_procesada, alto_sodio).
propiedad_alimento(frituras, alto_sodio).
propiedad_alimento(queso_maduro, alto_sodio).

propiedad_alimento(frituras, alta_grasa_saturada).
propiedad_alimento(mantequilla, alta_grasa_saturada).
propiedad_alimento(carne_roja_procesada, alta_grasa_saturada).

propiedad_alimento(pan_blanco, contiene_gluten).
propiedad_alimento(pan_integral, contiene_gluten).
propiedad_alimento(avena, contiene_gluten).   % traza cruzada tipica

propiedad_alimento(leche_entera, contiene_lactosa).
propiedad_alimento(queso_maduro, contiene_lactosa).
propiedad_alimento(mantequilla, contiene_lactosa).

propiedad_alimento(lentejas, rico_en_hierro).
propiedad_alimento(espinaca, rico_en_hierro).
propiedad_alimento(carne_roja_procesada, rico_en_hierro).
propiedad_alimento(frijoles, rico_en_hierro).

propiedad_alimento(naranja, rico_en_vitamina_c).
propiedad_alimento(brocoli, rico_en_vitamina_c).

propiedad_alimento(pescado_blanco, bajo_en_grasa).
propiedad_alimento(pechuga_pollo, bajo_en_grasa).
propiedad_alimento(tofu, bajo_en_grasa).

% --- Reglas: que propiedad se debe RESTRINGIR por cada condicion ---
% restriccion_condicion(Condicion, PropiedadRestringida).
restriccion_condicion(diabetes_tipo2, alto_indice_glucemico).
restriccion_condicion(hipertension, alto_sodio).
restriccion_condicion(obesidad, alta_grasa_saturada).
restriccion_condicion(obesidad, alto_indice_glucemico).
restriccion_condicion(intolerancia_lactosa, contiene_lactosa).
restriccion_condicion(celiaquia, contiene_gluten).
restriccion_condicion(hipotiroidismo, alta_grasa_saturada).

% --- Reglas: que propiedad se RECOMIENDA por cada condicion ---
% recomendacion_condicion(Condicion, PropiedadRecomendada).
recomendacion_condicion(diabetes_tipo2, bajo_indice_glucemico).
recomendacion_condicion(anemia, rico_en_hierro).
recomendacion_condicion(anemia, rico_en_vitamina_c). % mejora absorcion de hierro
recomendacion_condicion(hipertension, bajo_en_grasa).
recomendacion_condicion(obesidad, bajo_en_grasa).


% =====================================================
% 3. TIPOS DE ACTIVIDAD FISICA
% =====================================================
% actividad(Nombre, Tipo, Impacto, NivelEsfuerzo, ListaBeneficios).
%   Tipo:      aerobica | anaerobica
%   Impacto:   bajo_impacto | alto_impacto
%   Esfuerzo:  esfuerzo_bajo | esfuerzo_medio | esfuerzo_alto

actividad(caminata,        aerobica,    bajo_impacto, esfuerzo_bajo,
          [mejora_cardiovascular, reduccion_estres]).
actividad(yoga,             anaerobica,  bajo_impacto, esfuerzo_bajo,
          [reduccion_estres, mantenimiento]).
actividad(natacion,         aerobica,    bajo_impacto, esfuerzo_medio,
          [mejora_cardiovascular, perdida_peso]).
actividad(ciclismo,         aerobica,    bajo_impacto, esfuerzo_medio,
          [mejora_cardiovascular, perdida_peso]).
actividad(trote,            aerobica,    alto_impacto, esfuerzo_medio,
          [mejora_cardiovascular, perdida_peso]).
actividad(entrenamiento_pesas, anaerobica, alto_impacto, esfuerzo_alto,
          [ganancia_muscular, mantenimiento]).
actividad(hiit,              anaerobica, alto_impacto, esfuerzo_alto,
          [perdida_peso, mejora_cardiovascular]).
actividad(pilates,           anaerobica, bajo_impacto, esfuerzo_bajo,
          [reduccion_estres, mantenimiento]).

% --- Restricciones de actividad por condicion de salud ---
% restriccion_actividad(Condicion, ImpactoProhibido) /
% restriccion_actividad(Condicion, EsfuerzoProhibido)
restriccion_actividad(hipertension, esfuerzo_alto).
restriccion_actividad(obesidad, alto_impacto).
restriccion_actividad(diabetes_tipo2, esfuerzo_alto). % salvo supervision medica


% =====================================================
% 4. NIVELES DE ACTIVIDAD DEL USUARIO
% =====================================================
% nivel_actividad(Nombre, EsfuerzoMaximoRecomendadoParaIniciar).

nivel_actividad(sedentario,            esfuerzo_bajo).
nivel_actividad(levemente_activo,      esfuerzo_medio).
nivel_actividad(moderadamente_activo,  esfuerzo_medio).
nivel_actividad(muy_activo,            esfuerzo_alto).

% Orden de esfuerzo, usado para comparar "no superar tal nivel"
esfuerzo_orden(esfuerzo_bajo, 1).
esfuerzo_orden(esfuerzo_medio, 2).
esfuerzo_orden(esfuerzo_alto, 3).


% =====================================================
% 5. OBJETIVOS DE BIENESTAR
% =====================================================
objetivo(perdida_peso).
objetivo(ganancia_muscular).
objetivo(mantenimiento).
objetivo(mejora_cardiovascular).
objetivo(reduccion_estres).


% =====================================================
% 6. HABITOS DE DESCANSO
% =====================================================
% horas_sueno_recomendadas(PerfilEtario, HorasMin, HorasMax).
horas_sueno_recomendadas(adulto, 7, 9).
horas_sueno_recomendadas(adulto_mayor, 7, 8).
horas_sueno_recomendadas(adolescente, 8, 10).

% Practicas de higiene del sueno disponibles en el sistema
practica_higiene_sueno(horario_regular_de_sueno).
practica_higiene_sueno(evitar_pantallas_una_hora_antes_de_dormir).
practica_higiene_sueno(evitar_cafeina_despues_de_las_3pm).
practica_higiene_sueno(ambiente_oscuro_y_fresco).
practica_higiene_sueno(evitar_comidas_pesadas_antes_de_dormir).
practica_higiene_sueno(tecnica_de_relajacion_o_meditacion).
practica_higiene_sueno(evitar_siestas_largas_durante_el_dia).


% =============================================================
% MOTOR DE INFERENCIA
% =============================================================

% -------------------------------------------------------------
% 5.1  alimentos_recomendados(+ListaCondiciones, -ListaAlimentos)
%
% Un alimento es apto para el usuario si, para CADA condicion que
% tiene, no posee ninguna propiedad restringida por esa condicion.
% Esto resuelve el requisito de "combinaciones de condiciones":
% se calcula la INTERSECCION de alimentos aptos por condicion.
% -------------------------------------------------------------

apto_para_condicion(Alimento, Condicion) :-
    ( Condicion == ninguna
    -> true
    ;  \+ ( propiedad_alimento(Alimento, P),
            restriccion_condicion(Condicion, P) )
    ).

apto_para_todas([], _).
apto_para_todas([C|Cs], Alimento) :-
    apto_para_condicion(Alimento, C),
    apto_para_todas(Cs, Alimento).

alimentos_recomendados(Condiciones, ListaOrdenada) :-
    setof(Alimento,
          Grupo^( alimento(Alimento, Grupo),
                  apto_para_todas(Condiciones, Alimento)
                ),
          Lista),
    list_to_set(Lista, ListaOrdenada).

% Alimentos que ademas cumplen alguna propiedad recomendada
% explicitamente para el perfil (para priorizarlos en la salida).
alimentos_prioritarios(Condiciones, Prioritarios) :-
    setof(Alimento,
          Cond^Prop^
          ( member(Cond, Condiciones),
            recomendacion_condicion(Cond, Prop),
            propiedad_alimento(Alimento, Prop),
            apto_para_todas(Condiciones, Alimento)
          ),
          Prioritarios), !.
alimentos_prioritarios(_, []).


% -------------------------------------------------------------
% 5.2  rutina_segura(+Condiciones, +NivelActividadUsuario, -Rutinas)
%
% Una actividad es segura si:
%   a) su nivel de esfuerzo no excede el maximo recomendado para
%      el nivel de actividad del usuario, y
%   b) no viola ninguna restriccion de impacto/esfuerzo asociada
%      a alguna de las condiciones del usuario (interseccion).
% -------------------------------------------------------------

esfuerzo_permitido(NivelUsuario, EsfuerzoActividad) :-
    nivel_actividad(NivelUsuario, MaxEsfuerzo),
    esfuerzo_orden(MaxEsfuerzo, MaxN),
    esfuerzo_orden(EsfuerzoActividad, ActN),
    ActN =< MaxN.

segura_para_condicion(Condicion, Impacto, Esfuerzo) :-
    \+ restriccion_actividad(Condicion, Impacto),
    \+ restriccion_actividad(Condicion, Esfuerzo).

segura_para_todas([], _, _).
segura_para_todas([C|Cs], Impacto, Esfuerzo) :-
    ( C == ninguna
    -> true
    ;  segura_para_condicion(C, Impacto, Esfuerzo)
    ),
    segura_para_todas(Cs, Impacto, Esfuerzo).

rutina_segura(Condiciones, NivelActividadUsuario, Rutinas) :-
    ( setof(nombre_actividad(Nombre, beneficios(Beneficios)),
            Tipo^Impacto^Esfuerzo^
            ( actividad(Nombre, Tipo, Impacto, Esfuerzo, Beneficios),
              esfuerzo_permitido(NivelActividadUsuario, Esfuerzo),
              segura_para_todas(Condiciones, Impacto, Esfuerzo)
            ),
            Rutinas)
    -> true
    ;  Rutinas = []   % si no hay ninguna actividad segura, lista vacia en vez de fallar
    ).


% -------------------------------------------------------------
% 5.3  habitos_descanso(+NivelEstres, +HorasSuenoActuales, -Recomendacion)
%
% NivelEstres: bajo | medio | alto
% Devuelve horas de sueno objetivo y una lista de practicas de
% higiene del sueno, priorizadas segun la severidad del caso.
% -------------------------------------------------------------

habitos_descanso(NivelEstres, HorasActuales, recomendacion(HorasObjetivo, Practicas)) :-
    horas_sueno_recomendadas(adulto, Min, Max),
    HorasObjetivo = rango(Min, Max),
    practicas_por_urgencia(NivelEstres, HorasActuales, Min, Practicas).

% Caso critico: estres alto y deficit de sueno marcado
practicas_por_urgencia(alto, HorasActuales, Min, Practicas) :-
    HorasActuales < Min,
    !,
    Practicas = [horario_regular_de_sueno,
                 evitar_pantallas_una_hora_antes_de_dormir,
                 tecnica_de_relajacion_o_meditacion,
                 evitar_cafeina_despues_de_las_3pm,
                 ambiente_oscuro_y_fresco].

% Estres alto pero horas de sueno ya adecuadas
practicas_por_urgencia(alto, _, _, Practicas) :-
    !,
    Practicas = [tecnica_de_relajacion_o_meditacion,
                 evitar_pantallas_una_hora_antes_de_dormir,
                 horario_regular_de_sueno].

% Estres medio
practicas_por_urgencia(medio, HorasActuales, Min, Practicas) :-
    HorasActuales < Min,
    !,
    Practicas = [horario_regular_de_sueno,
                 evitar_cafeina_despues_de_las_3pm,
                 evitar_comidas_pesadas_antes_de_dormir].

% Estres bajo con deficit de horas (solo ajuste de horario)
practicas_por_urgencia(bajo, HorasActuales, Min, Practicas) :-
    HorasActuales < Min,
    !,
    Practicas = [horario_regular_de_sueno,
                 evitar_pantallas_una_hora_antes_de_dormir].

% Caso general / sin alertas relevantes
practicas_por_urgencia(_, _, _,
    [horario_regular_de_sueno, ambiente_oscuro_y_fresco]).


% -------------------------------------------------------------
% 5.4  combinacion_optima(+Objetivo, +Condiciones, +NivelActividadUsuario,
%                          -Dieta, -Ejercicio)
%
% Combina dieta (alimentos_recomendados) y ejercicio (rutina_segura)
% que mejor sirven a un objetivo especifico, respetando las
% condiciones de salud del usuario.
% -------------------------------------------------------------

% Que beneficio de actividad conviene mas para cada objetivo
beneficio_prioritario(perdida_peso, perdida_peso).
beneficio_prioritario(ganancia_muscular, ganancia_muscular).
beneficio_prioritario(mantenimiento, mantenimiento).
beneficio_prioritario(mejora_cardiovascular, mejora_cardiovascular).
beneficio_prioritario(reduccion_estres, reduccion_estres).

combinacion_optima(Objetivo, Condiciones, NivelActividadUsuario, Dieta, EjercicioRecomendado) :-
    alimentos_recomendados(Condiciones, Dieta),
    rutina_segura(Condiciones, NivelActividadUsuario, Rutinas),
    beneficio_prioritario(Objetivo, BeneficioClave),
    ( setof(nombre_actividad(N, beneficios(B)),
            ( member(nombre_actividad(N, beneficios(B)), Rutinas),
              member(BeneficioClave, B)
            ),
            EjercicioRecomendado)
    -> true
    ;  EjercicioRecomendado = Rutinas   % si ninguna coincide exacto con el objetivo,
                                         % se devuelve toda la rutina segura disponible
    ).


% =============================================================
% API PARA INTEGRACION CON PYTHON (microservicio)
% =============================================================
% Los predicados anteriores devuelven terminos Prolog anidados
% (compuestos dentro de compuestos), que son correctos y comodos
% de usar DENTRO de Prolog, pero pyswip no siempre los "aplana"
% bien al traerlos a Python (algunos atomos profundamente
% anidados llegan como referencias internas en vez de texto).
%
% Por eso se exponen aqui versiones "planas" (listas simples de
% atomos, o varias variables de salida) que son las que el
% microservicio en Python debe consultar. Internamente reusan
% toda la logica ya definida arriba.

% -- 1) Alimentos: ya es una lista plana de atomos, se usa igual.
%    alimentos_recomendados(+Condiciones, -Alimentos)

% -- 2) Rutina segura: nombres de actividad (lista plana) +
%       predicado aparte para consultar beneficios de una actividad.
rutina_segura_nombres(Condiciones, NivelActividadUsuario, Nombres) :-
    rutina_segura(Condiciones, NivelActividadUsuario, Rutinas),
    findall(N, member(nombre_actividad(N, _), Rutinas), Nombres).

beneficios_actividad(Nombre, Beneficios) :-
    actividad(Nombre, _Tipo, _Impacto, _Esfuerzo, Beneficios).

% -- 3) Habitos de descanso: horas min/max y practicas por separado.
habitos_descanso_flat(NivelEstres, HorasActuales, HorasMin, HorasMax, Practicas) :-
    habitos_descanso(NivelEstres, HorasActuales,
                      recomendacion(rango(HorasMin, HorasMax), Practicas)).

% -- 4) Combinacion optima: dieta plana + nombres de ejercicio planos.
combinacion_optima_flat(Objetivo, Condiciones, NivelActividadUsuario, Dieta, NombresEjercicio) :-
    combinacion_optima(Objetivo, Condiciones, NivelActividadUsuario, Dieta, Ejercicio),
    findall(N, member(nombre_actividad(N, _), Ejercicio), NombresEjercicio).


% =============================================================
% CASOS DE PRUEBA (VALIDACION DEL MOTOR - Objetivo especifico #5)
% =============================================================
% Se ejecutan con:  swipl -g run_tests -t halt salud_bienestar.pl

run_tests :-
    nl, writeln('==================================================='),
    writeln('CASO 1: Persona con diabetes tipo 2 y sobrepeso (obesidad)'),
    writeln('==================================================='),
    alimentos_recomendados([diabetes_tipo2, obesidad], Alimentos1),
    format('Alimentos recomendados: ~w~n', [Alimentos1]),
    rutina_segura([diabetes_tipo2, obesidad], sedentario, Rutina1),
    format('Rutina segura (nivel sedentario): ~w~n', [Rutina1]),

    nl, writeln('==================================================='),
    writeln('CASO 2: Persona sedentaria con hipertension'),
    writeln('==================================================='),
    rutina_segura([hipertension], sedentario, Rutina2),
    format('Rutina segura para hipertension + sedentario: ~w~n', [Rutina2]),

    nl, writeln('==================================================='),
    writeln('CASO 3: Usuario con estres alto y pocas horas de sueno (5h)'),
    writeln('==================================================='),
    habitos_descanso(alto, 5, Recom3),
    format('Recomendacion de descanso: ~w~n', [Recom3]),

    nl, writeln('==================================================='),
    writeln('CASO 4: Combinacion optima dieta+ejercicio para perdida de peso'),
    writeln('(deportista en recuperacion: sin condiciones, muy activo)'),
    writeln('==================================================='),
    combinacion_optima(perdida_peso, [ninguna], muy_activo, Dieta4, Ejercicio4),
    format('Dieta sugerida: ~w~n', [Dieta4]),
    format('Ejercicio sugerido: ~w~n', [Ejercicio4]),

    nl, writeln('==================================================='),
    writeln('CASO 5: Persona celiaca e intolerante a la lactosa'),
    writeln('==================================================='),
    alimentos_recomendados([celiaquia, intolerancia_lactosa], Alimentos5),
    format('Alimentos recomendados (interseccion de restricciones): ~w~n', [Alimentos5]),

    nl, writeln('Todas las pruebas se ejecutaron correctamente.'), nl.
