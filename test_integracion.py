"""
test_integracion.py

Ejemplo de integracion entre el microservicio en Python y el motor
logico en Prolog (salud_bienestar.pl) del "Sistema Inteligente de
Gestion de Salud y Bienestar Personal".

Requisitos:
    1. SWI-Prolog instalado en el sistema (no solo el paquete de Python).
       - Ubuntu/Debian:  sudo apt install swi-prolog
       - macOS:          brew install swi-prolog
       - Windows:        https://www.swi-prolog.org/download/stable
    2. pip install pyswip

Este archivo NO reemplaza al motor logico; solo demuestra como
consultarlo desde Python. Los predicados que se usan aqui son los
de la "API para integracion con Python" al final de salud_bienestar.pl
(devuelven listas planas de atomos, ideales para convertir a JSON).
"""

from pyswip import Prolog


class MotorSaludBienestar:
    """Wrapper en Python sobre el motor de inferencia Prolog."""

    def __init__(self, ruta_archivo_pl="salud_bienestar.pl"):
        self.prolog = Prolog()
        self.prolog.consult(ruta_archivo_pl)

    @staticmethod
    def _lista_prolog(condiciones_python):
        """Convierte ['diabetes_tipo2', 'obesidad'] -> '[diabetes_tipo2, obesidad]'."""
        return "[" + ", ".join(condiciones_python) + "]"

    def alimentos_recomendados(self, condiciones: list[str]) -> list[str]:
        cond = self._lista_prolog(condiciones)
        consulta = f"alimentos_recomendados({cond}, X)"
        resultados = list(self.prolog.query(consulta))
        return resultados[0]["X"] if resultados else []

    def rutina_segura(self, condiciones: list[str], nivel_actividad: str) -> list[str]:
        cond = self._lista_prolog(condiciones)
        consulta = f"rutina_segura_nombres({cond}, {nivel_actividad}, X)"
        resultados = list(self.prolog.query(consulta))
        return resultados[0]["X"] if resultados else []

    def beneficios_de_actividad(self, nombre_actividad: str) -> list[str]:
        consulta = f"beneficios_actividad({nombre_actividad}, X)"
        resultados = list(self.prolog.query(consulta))
        return resultados[0]["X"] if resultados else []

    def habitos_descanso(self, nivel_estres: str, horas_actuales: int) -> dict:
        consulta = f"habitos_descanso_flat({nivel_estres}, {horas_actuales}, Min, Max, P)"
        resultados = list(self.prolog.query(consulta))
        if not resultados:
            return {}
        r = resultados[0]
        return {
            "horas_sueno_min": r["Min"],
            "horas_sueno_max": r["Max"],
            "practicas_higiene_sueno": r["P"],
        }

    def combinacion_optima(self, objetivo: str, condiciones: list[str],
                            nivel_actividad: str) -> dict:
        cond = self._lista_prolog(condiciones)
        consulta = (
            f"combinacion_optima_flat({objetivo}, {cond}, "
            f"{nivel_actividad}, Dieta, Ejercicio)"
        )
        resultados = list(self.prolog.query(consulta))
        if not resultados:
            return {"dieta": [], "ejercicio": []}
        r = resultados[0]
        return {"dieta": r["Dieta"], "ejercicio": r["Ejercicio"]}

    def perfil_completo(self, condiciones: list[str], nivel_actividad: str,
                         objetivo: str, nivel_estres: str, horas_sueno: int) -> dict:
        """
        Ejemplo de lo que el microservicio llamaria al recibir el
        perfil de un usuario desde el front-end: junta las 4 consultas
        en un solo diccionario listo para:
          a) devolver como JSON estructurado, o
          b) pasarlo como contexto a la IA generativa para redactar
             el consejo final en lenguaje natural.
        """
        return {
            "condiciones": condiciones,
            "alimentos_recomendados": self.alimentos_recomendados(condiciones),
            "rutina_segura": self.rutina_segura(condiciones, nivel_actividad),
            "habitos_descanso": self.habitos_descanso(nivel_estres, horas_sueno),
            "combinacion_optima_objetivo": self.combinacion_optima(
                objetivo, condiciones, nivel_actividad
            ),
        }


if __name__ == "__main__":
    import json

    motor = MotorSaludBienestar("salud_bienestar.pl")

    print("=== Caso: persona con diabetes tipo 2 y obesidad, sedentaria ===")
    perfil = motor.perfil_completo(
        condiciones=["diabetes_tipo2", "obesidad"],
        nivel_actividad="sedentario",
        objetivo="perdida_peso",
        nivel_estres="alto",
        horas_sueno=5,
    )
    print(json.dumps(perfil, indent=2, ensure_ascii=False))

    print("\n=== Caso: persona con hipertension, sedentaria ===")
    rutina = motor.rutina_segura(["hipertension"], "sedentario")
    print("Rutina segura:", rutina)
    for actividad in rutina:
        print(f"  - {actividad}: {motor.beneficios_de_actividad(actividad)}")
