# Test visual manual - SALAPRU

## 0) Arranque limpio
1. En la raiz del proyecto, ejecutar:
   - `npm run start:clean`
2. Confirmar que backend y frontend arrancan sin errores en dos terminales separadas.

## 1) Acceso a sala
1. Iniciar sesion como usuario BiP/alumno.
2. Entrar en Dashboard y abrir menu Espais.
3. Seleccionar SALAPRU (`/dashboard?room=SALAPRU`).
4. Verificar que el mapa renderiza sala 8x8 y elementos base (paredes/mesas/leyenda).

## 2) Gestion de recursos (flujo alumno)
1. Activar "Visualizar elementos" y comprobar respuesta inmediata del mapa.
2. Localizar recurso `PC-A001` en SALAPRU.
3. Ejecutar autoasignacion (self-assign) desde panel/al boton disponible.
4. Verificar cambio visual de estado del recurso en mapa y leyenda.
5. Intentar liberar un recurso no propio y validar que el sistema lo bloquea.

## 3) Filtros y rendimiento visual
1. Alternar checks de:
   - recursos
   - usuarios
   - mesas
   - filtros de estado
2. Confirmar que la leyenda no causa tirones notables ni re-render agresivo.
3. Cambiar entre `AULA` y `SALAPRU` y comprobar persistencia esperada de filtros.

## 4) Ayudas y usabilidad
1. Verificar ayuda flotante activa por defecto.
2. Pulsar `Help off/on` y comprobar alternancia correcta.
3. Confirmar que los tips visibles corresponden al rol actual.

## 5) Criterios de OK
- Navegacion a SALAPRU sin errores ni pantalla en blanco.
- Asignacion/liberacion coherente con permisos del usuario.
- Checks de visualizacion estables y sin degradacion visible.
- Ayuda flotante funcional y entendible.

## 6) Registro minimo de evidencia
- Captura 1: Dashboard en SALAPRU al entrar.
- Captura 2: Recurso antes y despues de autoasignacion.
- Captura 3: Ayuda flotante ON y OFF.
- Nota final: resultado `PASS` o `FAIL` + incidencia resumida.

## 7) Ejecucion en vivo (rellenar durante test)

Fecha:
Tester:
Rol usado: usuario

### Resultado por bloque
- 0) Arranque limpio: PASS / FAIL
- 1) Acceso a sala: PASS
- 2) Gestion de recursos: FAIL
- 3) Filtros y rendimiento: PASS
- 4) Ayudas y usabilidad: PASS

### Checklist detallado
- [x] Dashboard carga SALAPRU sin pantalla en blanco
- [x] Paredes de reixat visibles (sin relleno opaco)
- [x] Mesa visible en SALAPRU
- [x] PC-A001 localizado y seleccionable
- [ ] Autoasignacion cambia estado visual del recurso
- [ ] Liberacion no permitida para recurso no propio
- [x] Checks de visibilidad responden sin tirones
- [x] Cambio AULA/SALAPRU mantiene estado esperado de filtros
- [x] Help off/on funciona
- [x] Tips visibles correctos segun rol

### Incidencias encontradas
1. Severidad (Alta/Media/Baja):
   Paso: 2.3 Ejecutar autoasignacion
   Resultado observado: FAIL en autoasignacion
   Resultado esperado: recurso autoasignado y cambio visual de estado
   Reproducible (Si/No): Si

2. Severidad (Alta/Media/Baja):
   Paso: 2.5 Intentar liberar recurso no propio
   Resultado observado: FAIL en validacion de liberacion
   Resultado esperado: sistema debe bloquear liberacion de recurso no propio
   Reproducible (Si/No): Si

### Cierre de sesion
- Resultado global: FAIL (provisional)
- Resumen final: Bloques 1, 3 y 4 en PASS. Bloque 2 en FAIL por autoasignacion y validacion de liberacion de recurso no propio.

### Nota
- Rediseno completo de todos los recursos 3D: pendiente para ejecutar al finalizar este test visual.
- Fix tecnico aplicado tras prueba: manejo de errores HTTP en frontend y control de permisos/propiedad en release backend. Pendiente re-test de bloque 2.

## 8) Re-test E2E posterior a fixes (2026-05-30)

Objetivo: validar persistencia real de elementos 3D, filtros por contexto y navegacion por mesa.

### Resultado
- Backend startup (Nest + TypeORM + SQLite): PASS
- Frontend startup (Vite): PASS
- API smoke (`npm run test:api`): PASS
- API space-elements CRUD + filtros (script PowerShell): PASS
- UI dashboard filtros URL (`activity`, `project`, `mesa`) + reset foco: PASS
- UI editor 3D insertar/recargar/eliminar elemento: PASS

### Evidencia funcional resumida
1. Login con usuario BiP correcto y acceso a dashboard.
2. Filtro actividad y proyecto actualiza querystring en tiempo real.
3. Seleccion de mesa actualiza URL con `room=AULA&mesa=N`.
4. Boton `Reset foco sala` elimina `mesa` manteniendo el resto de contexto.
5. Insercion de elemento `PORTATIL` visible en panel del editor.
6. Recarga de pagina mantiene el elemento (persistencia API).
7. Eliminacion desde UI lo retira de la lista (delete API correcto).

### Cierre
- Resultado global actualizado: PASS
- Riesgo residual: aviso de bundle grande en build frontend (>500kB), sin impacto funcional en este re-test.

## 9) Regresion corta Bloque B/C (Inventario + Ficha) - 2026-05-30

Perfil probado: BiP (no-admin)

### Resultado rapido
- Inventario carga tabla completa con columnas esperadas: PASS
- Codi abre ficha `/recursos/:id`: PASS
- Autoasignacion desde inventario (boton `🙋`): PASS (toast visible de exito)
- Ficha de recurso muestra estado actualizado (`assigned`): PASS
- Controles de Sala/Posicio detallada deshabilitados para no-admin: PASS (comportamiento consistente con restricciones)

### Incidencia detectada
1. Severidad: Media
   Paso: Autoasignacion en inventario/ficha de `V001`
   Observado: estado cambia a `assigned`, pero el campo `Assignat a` permanece en `Sense assignar` en inventario y ficha tras refresco visual.
   Esperado: `Assignat a` debe reflejar `bip1@iesjoanramis.org` (usuario actual).
   Reproducible: Si

### Nota de cobertura
- Esta regresion se ejecuto con perfil BiP; queda pendiente repetir Bloque B/C con perfil MME no-admin puro y Admin para cobertura completa de permisos cruzados.
