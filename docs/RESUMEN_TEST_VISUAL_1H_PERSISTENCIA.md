# Resumen test visual (T+1h)

## Objetivo
Validar en 60 minutos la experiencia 3D y el flujo de asignacion/ubicacion con los ultimos cambios de anclaje y persistencia atomica.

## Alcance del test (esta hora)
- Mapa 3D: hover, click, panel flotante, usuarios activos, no seleccion de suelo/reticula/baldosas vacias.
- Posicionamiento por mesa: usuarios y recursos sin solapes.
- Persistencia: ubicacion enriquecida (`type/mesaId/placement/anchor/renderAnchorIndex`) tras asignar desde inventario/ficha/mapa.
- Flujo atomico admin: asignacion + ubicacion en una sola operacion (`POST /api/resources/assign`).

## Preparacion (5 min)
1. Ejecutar arranque limpio.
2. Confirmar backend en `GET /api/health`.
3. Entrar con usuario admin y con usuario BiP/MME para contraste de permisos.

## Guion de prueba (45 min)

### Bloque A - Interaccion visual 3D (15 min)
1. Abrir dashboard en `AULA` y `SALAPRU`.
2. Comprobar que suelo, reticula y baldosas vacias no reaccionan a hover/click.
3. Verificar hover con iniciales en:
- recursos,
- usuarios,
- mesas,
- elementos 3D asignables.
4. Click en recurso: panel flotante con estado, asignacion y posicion.
5. Click en usuario: panel flotante con datos y foco.
6. Usuarios activos: doble perfil verde visible.

PASS
- No hay overlays sobre suelo/reticula.
- Hover/click solo en entidades activas.

FAIL
- Cualquier seleccion de baldosa vacia, conflicto de paneles o parpadeo incoherente.

### Bloque B - Posicionamiento por mesa (15 min)
1. Forzar escenario con varios usuarios en una mesa.
2. Verificar 8 anclas alrededor de mesa y sin superposicion.
3. Asignar varios recursos a usuarios de la misma mesa.
4. Validar recursos en anclas de mesa sin solapes.
5. Navegar entre recursos (prev/next) y confirmar foco correcto.

PASS
- Usuarios y recursos se distribuyen sin colision visible.

FAIL
- Dos entidades en mismo punto o foco en coordenada incorrecta.

### Bloque C - Persistencia atomica de ubicacion (15 min)
1. Inventario: seleccionar `Posicio nova`, asignar usuario y guardar.
2. Ficha: cambiar ubicacion y asignacion, guardar.
3. Mapa: mover/seleccionar ubicacion y asignar.
4. Recargar pagina y verificar persistencia visual.
5. Confirmar en detalle de recurso que ubicacion mantiene metadatos.

PASS
- Tras recarga se conserva distribucion y contexto de mesa.

FAIL
- Se pierde ancla/mesa o cambia posicion sin accion de usuario.

## Evidencias requeridas (10 min)
- Captura A1: hover iniciales en recurso y usuario.
- Captura A2: usuario activo con segundo contorno verde.
- Captura B1: mesa con multiples usuarios sin solape.
- Captura B2: mesa con recursos asignados sin solape.
- Captura C1: asignacion desde inventario con posicion.
- Captura C2: ficha con ubicacion persistida tras recarga.

## Registro de incidencias
Para cada incidencia:
1. Ruta exacta.
2. Usuario/rol.
3. Recurso o mesa.
4. Pasos de reproduccion.
5. Resultado observado.
6. Resultado esperado.
7. Severidad (`alta/media/baja`).

## Criterio de cierre de esta hora
- PASS global: bloques A, B y C superados sin errores bloqueantes.
- Si FAIL: cerrar con top 3 incidencias priorizadas y accion correctiva propuesta.

## Riesgo conocido
- Puede reaparecer `EADDRINUSE` en puerto 3000 por procesos previos; validar listener antes de iniciar test visual.
