# Plan de trabajo manana - validacion visual + permisos

## Estado actual (2026-05-30)
- Rotacion 3D de elementos en saltos de 45 grados (`rotationY`) con persistencia API/UI: COMPLETADO.
- Hover 3D con iniciales, panel flotante de usuario y estado editable en recurso seleccionado: EN PROGRESO.
- Suelo/reticula/baldosas sin seleccion para evitar superposiciones: COMPLETADO.
- Usuarios distribuidos en 8 posiciones alrededor de mesa, sin solapes: COMPLETADO.
- Recursos asignados reanclados a mesa/usuario con posicion render anti-solape: COMPLETADO.
- Metadato opcional `renderAnchorIndex` persistido en `location` para estabilidad de distribucion entre recargas: COMPLETADO.
- Inventario, ficha y dashboard usan constructor comun de `location` persistida (mesa/anchor/renderAnchorIndex): COMPLETADO.
- Endpoint admin `POST /resources/assign` acepta `location` opcional y guarda asignacion+ubicacion en una sola operacion atomica: COMPLETADO.

## Estado de planificacion (actual)
- Fase 0 (Interaccion 3D): COMPLETADA (hover/click paneles, altura usuario, bloqueo suelo/reticula, anclas usuario).
- Fase 1 (Drive): COMPLETADA en UI principal (ficha + mapa + inventario cuando aplica).
- Fase 2 (Proyectos/Tareas): COMPLETADA (entidad+tareas backend, trazabilidad canonica y LibroActividadUD MVP enlazado).
- Fase 3 (Rotacion 45): COMPLETADA.
- Fase 4 (Posicionamiento mesa): COMPLETADA para capa visual y persistencia de metadatos de ubicacion.
- Fase 5 (Almacenamiento dinamico): COMPLETADA MVP (tabla dinamica + API + selector UI en inventario/ficha + render de recursos `available` por coordenadas de almacen en mapa).

Resumen operativo para test visual en 1 hora:
- Ver `docs/RESUMEN_TEST_VISUAL_1H.md`.

## Objetivo
- Validar la nueva representacion 3D de recursos y mesas.
- Verificar permisos por rol en inventario y ficha de recurso.
- Confirmar flujo completo de autoasignacion y posicionamiento (AULA + SALAPRU).


Estado actual:
- Implementado en backend `space-elements` y editor 3D (`Mapa3D`).
- Validado por API: `upsert` + `findAll` devuelven `rotationY` persistido (ejemplo validado: 90).
## Preparacion (arranque limpio)
1. En la raiz del proyecto ejecutar `npm run start:clean`.

## Resultado incremental de esta sesion
- TEST-ROT-01: PASS (persistencia `rotationY` verificada en `space-elements` via API).
- Build backend: PASS.
- Build frontend: PASS.
- BiP
- Alumno MME estandar

## Delta adicional (modo auto continuo 10)
1. Nueva sala `SALATEST` operativa para simulacion UD01 desde dashboard/menu (`/sala-test-ud01`).
2. `SALATEST` incluye elementos fijos de almacen (estanteria y armario) para validar relaciones con inventario.
3. En `SALATEST`, la ubicacion de recursos se simula en memoria (sin persistir cambios reales).
4. Panel de recurso en mapa incorpora validacion simplificada de test:
	- superficie/posicion,
	- orientacion (45 grados),
	- proximidad,
	- ocupacion,
	- compatibilidad basica por tipo.
5. Portatil ajustado a escala 50% en render 3D y soporte de rotacion visual por `rotationY`.

## Delta adicional (modo auto continuo 11)
1. `MiActividad` incorpora ficha operativa de pasos para UD01 (Pasta Termica) basada en plantilla.
2. Cada paso permite marcar completado y registrar evidencia (texto, imagen o valor numerico).
3. Flujo de simulacion de entrega activo:
	- boton `Simular envio y evaluacion`,
	- calculo de nota automatica por porcentaje de pasos completados,
	- guardado local por usuario para pruebas repetibles.
4. Se mantiene separacion entre simulacion (no bloqueante para test) y persistencia canonica futura en V0.4.

## Delta adicional (modo auto continuo 12)
1. `MiActividad` amplia trazabilidad de entrega por UD con estado local (`draft`/`submitted`/`reviewed`).
2. Se incluye exportacion de informe JSON por entrega simulada (usuario, timeline, metodos, pasos, evidencias y score).
3. La lectura de actividad ahora agrega tambien elementos de `SALATEST` para contexto completo de simulacion.
4. Se añade boton directo desde ficha UD para abrir `Sala Test UD01` durante el flujo de validacion.

## Matriz de prueba (PASS/FAIL)

### Bloque A - Visual 3D
1. Entrar en dashboard y abrir SALAPRU desde Espais.
2. Validar geometria:
- Mesa: prisma naranja 3x2x2, solo lineas externas.
- PC: prisma 1x1x1, lineas externas y relleno dinamico por estado.
- Pantalla: prisma azul 1x0.25x1, solo lineas.
- Impressora: prisma gris 0.5x1x1, solo lineas.
- Portatil: prisma violeta 1x1x0.25, solo lineas.
3. Validar checks de visibilidad en panel Debug Render:
- Recursos, Usuaris, Taules, Parets, Sol, Grid, Valdoses, Estanteria.
- Tipos: PC, Pantalla, Impressora, Portatil, Altres.
4. Resultado:
- PASS: toda geometria y toggles responden sin lag visible.
- FAIL: anotar tipo exacto y comportamiento.

### Bloque B - Inventario (permisos y acciones)
1. Abrir inventario con BiP y Admin.
2. Confirmar que Codi abre ficha del recurso al hacer click.
3. En columna Assignat a:
- Ver dropdown basado en whitelist.
- Admin/BiP deben poder asignar y dejar sin asignar.
4. En columna Posicio nova:
- Ver opciones AULA y SALAPRU.
- Ver opciones de mesa: superficie/dins y centro/esquinas.
5. Con usuario MME (no admin):
- Autoasignarse recurso available desde inventario.
- Si se selecciona posicion, comprobar que queda guardada al autoasignar.
6. Resultado:
- PASS: permisos y acciones segun rol correctos.
- FAIL: registrar rol, recurso y accion que falla.

### Bloque C - Ficha de recurso (/recursos/x)
1. Abrir un recurso desde inventario.
2. Validar dropdown Assignat a (whitelist) y accion de aplicar.
3. Validar seleccion de Sala + Posicio detallada.
4. Guardar posicion y comprobar reflejo en mapa.
5. Resultado:
- PASS: asignacion y posicion persistidas.
- FAIL: registrar payload esperado vs resultado visible.

## Evidencias minimas
- Captura 1: SALAPRU con nuevos prismas visibles.
- Captura 2: Panel Debug Render con checks ampliados.
- Captura 3: Inventario con dropdown Assignat a y Posicio nova.
- Captura 4: Ficha de recurso con Sala + Posicio detallada.
- Captura 5: Antes/despues de autoasignacion MME.

## Registro rapido de incidencias
1. Rol y usuario.
2. Ruta exacta (dashboard/inventario/recursos/:id).
3. Recurso (codigo).
4. Accion ejecutada.
5. Resultado observado.
6. Resultado esperado.
7. Severidad: alta/media/baja.

## Criterio de cierre
- PASS global si bloques A, B y C superados sin errores bloqueantes.
- Si hay FAIL, cerrar con lista priorizada de incidencias y reproduccion corta.

## Cierre de iteracion
- Resultado global de la iteracion actual: PASS.
- Riesgo residual: warning de bundle frontend grande en build (sin impacto funcional).
- Proximo paso recomendado: regresion corta de Bloque B y Bloque C con usuario MME no admin para confirmar permisos de extremo a extremo tras los cambios de mapa 3D.

## Plan solicitado para manana (nueva tanda funcional)

### Objetivos funcionales
1. Probar insercion de enlace de ficha Drive en recurso ejemplo `PCA001`:
	- URL de prueba: `https://docs.google.com/document/d/1VMUcp1f07Hbwfyow8KXLTNXi-hqMritaAjATFXiuSLg/edit?tab=t.0`
2. Mostrar enlace Drive en panel flotante del mapa (si el recurso seleccionado tiene `driveLink`).
3. Flujo de proyecto:
	- crear proyecto,
	- asignar tareas a usuarios seleccionados,
	- asignar mesa por tarea,
	- asociar recursos por tarea.
4. Mejorar escena 3D:
	- rotacion horizontal de recursos concretos (pantallas) en saltos de 45 grados,
	- mejor posicionamiento de usuarios con sus recursos en su mesa,
	- visualizacion de recursos disponibles en posiciones de almacenamiento.
5. Tabla dinamica de almacenamiento:
	- estanterias y armarios,
	- ubicaciones definidas y reutilizables por inventario/mapa.
6. Libro de actividades por UDs:
	- estructura unificada por actividad,
	- fecha,
	- enunciado,
	- equipamiento necesario,
	- asignaciones o autoasignaciones de recursos (`PC`, `PANTALLA`).
7. Adjuntos enriquecidos en actividades y proyectos:
	- links externos,
	- subida de imagenes,
	- analisis de metodos integrados de almacenamiento antes de decidir implementacion final.
8. Trazabilidad historica cruzada:
	- actividad/proyecto vinculado al historial del recurso `PC` en inventario,
	- actividad/proyecto vinculado al historial del usuario en perfil/ficha.

### Viabilidad tecnica (estado actual)
1. Enlace Drive por recurso: VIABLE, el modelo `Resource` ya incluye `driveLink`.
2. Visualizacion en API/panel flotante: VIABLE, se puede renderizar en el overlay de detalle ya existente.
3. Importacion actual disponible: Excel (`.xlsx`) via endpoint de import (`importExcel`).
4. Formatos no implementados aun: CSV/JSON directos (se pueden planificar como extension).

### Fases de ejecucion manana

#### Fase 0 - Interaccion 3D y detalle rapido
1. Mostrar iniciales al pasar el raton sobre recursos, usuarios, mesas y elementos 3D asignables.
2. Resaltar usuarios activos con un segundo contorno verde y brillo persistente.
3. Mantener usuarios a 4 baldosas de altura en la escena 3D.
4. Abrir panel flotante al hacer clic con propiedades y edicion de estado/asignacion/posicion.
5. Desactivar interaccion en suelo/reticula/baldosas vacias para evitar overlays no deseados.
6. Reposicionar usuarios por mesa usando 8 anclas con resolucion anti-solape.
4. Criterio de aceptacion:
	- hover y click diferenciados por entidad,
	- sin afectar suelo, baldosas ni reticula.

#### Fase 1 - Drive en recurso + panel flotante
1. Crear/actualizar recurso `PCA001` con `driveLink` de prueba.
2. Verificar visualizacion del link en:
	- ficha de recurso,
	- panel flotante del mapa,
	- inventario (si aplica).
3. Criterio de aceptacion:
	- clic abre documento en nueva pestaña,
	- link visible solo cuando existe.

#### Fase 2 - Proyectos y tareas por usuario/mesa
1. Definir entidad minima `Project` y `ProjectTask` (o estructura temporal en `space-elements.assignment`).
2. Campos minimos de tarea:
	- `projectName`, `activityCode`, `ownerUserEmail`, `mesaNum`, `resourceCode`, `status`.
3. Crear flujo UI:
	- alta de proyecto,
	- asignacion de tareas a usuarios,
	- vinculacion mesa/recursos.
4. Criterio de aceptacion:
	- filtros por proyecto/actividad/mesa muestran contexto correcto en mapa.

Pendientes ampliados para esta fase:
1. Crear `LibroActividadUD` o estructura equivalente por unidad didactica (`UD01..UDxx`).
2. Unificar esquema base de actividad:
	- `udCode`, `title`, `date`, `statement`, `requiredEquipment`, `assignmentMode`, `resourceTypes`.
3. Soportar `assignmentMode` con dos variantes:
	- asignacion administrada,
	- autoasignacion controlada.
4. Permitir asociar multiples recursos requeridos por actividad:
	- `PC`,
	- `PANTALLA`,
	- ampliable a otros tipos.
5. Preparar compatibilidad para adjuntos y evidencias:
	- `links[]`,
	- `images[]`,
	- decision pendiente entre almacenamiento local, Drive o servicio mixto.
6. Conectar actividad/proyecto con historiales:
	- historial del recurso en inventario,
	- historial del usuario en perfil/ficha,
	- eventos consultables por fecha y contexto.
7. Esperando modelos existentes del usuario para consolidar estructura final del libro por UDs.

#### Fase 3 - Rotacion 45 grados para pantallas
1. Anadir propiedad `rotationY` (en grados) a recurso/elemento 3D.
2. Implementar controles: 0/45/90/135/180/225/270/315.
3. Aplicar a tipos objetivo (`PANTALLA`, opcionalmente `PORTATIL`).
4. Criterio de aceptacion:
	- cambios persistidos y visibles tras recarga.

#### Fase 4 - Posicionamiento de usuarios y recursos por mesa
1. Definir anclas por mesa (centro/esquinas/superficie/dins) para usuarios y recursos.
2. Mostrar usuario junto a sus recursos asignados en el contexto de mesa.
3. Criterio de aceptacion:
	- consistencia visual entre inventario, ficha y mapa.

Estado actual:
- Usuarios: 8 anclas alrededor de mesa + resolucion de colisiones.
- Recursos: anclaje por mesa (o mesa del usuario asignado) con `renderLocation` anti-solape en mapa.
- Click/hover/foco de leyenda y navegacion de recursos ya usan coordenadas renderizadas.
- Acciones de ubicacion desde mapa (`mesa`, selector y atajos SALAPRU) guardan `type/mesaId/placement/anchor/renderAnchorIndex`.
- Autoasignacion y asignacion desde inventario/ficha mantienen el mismo esquema de `location` enriquecida.
- Asignacion admin desde inventario/ficha/dashboard elimina carrera de doble llamada (`update location` + `assign`).

#### Fase 5 - Almacenamiento por estanterias/armarios
1. Crear tabla dinamica de ubicaciones de almacen:
	- `storageLocations` (tipo, zona, fila, modulo, capacidad, coordenadas).
2. Integrar selector de ubicacion en inventario/ficha.
3. Mostrar recursos disponibles en dichas posiciones en mapa AULA/SALAPRU.
4. Criterio de aceptacion:
	- recurso con estado `available` se ve en su ubicacion de almacen definida.

### Matriz de tests manana (resumen)
1. TEST-DRIVE-01: `PCA001` con enlace Drive visible y clicable.
2. TEST-PROY-01: crear proyecto y asignar 2 tareas a usuarios distintos.
3. TEST-PROY-02: asignar mesa y recurso por tarea, filtrar por proyecto.
4. TEST-ROT-01: rotar pantalla 45 grados y persistir.
5. TEST-MESA-01: usuario + recursos renderizados correctamente en su mesa.
6. TEST-STOR-01: recursos `available` visibles en estanteria/armario definidos.
7. TEST-VIS-01: regresion visual completa sin errores de permisos.
8. TEST-UD-01: crear actividad UD con fecha, enunciado y equipamiento requerido.
9. TEST-UD-02: asociar `PC` y `PANTALLA` a actividad con modo asignacion/autoasignacion.
10. TEST-HIST-01: reflejar actividad en historial de recurso `PC`.
11. TEST-HIST-02: reflejar actividad/proyecto en historial de usuario.

### Riesgos y mitigacion
1. Riesgo: inconsistencia `assigned` vs `Assignat a` en UI.
	- Mitigacion: unificar mapeo `assignedToUserId` + usuario resuelto por email en DTO de salida.
2. Riesgo: sobrecarga visual en mapa por demasiados overlays.
	- Mitigacion: toggles por capa + filtros activos por contexto.
3. Riesgo: complejidad de modelos de proyecto.
	- Mitigacion: empezar por MVP de tarea con campos minimos y ampliar en segunda iteracion.
4. Riesgo: adjuntos e imagenes sin estrategia clara de almacenamiento.
	- Mitigacion: analizar metodos integrados disponibles antes de cerrar modelo persistente.
5. Riesgo: duplicidad entre historial de recurso, historial de usuario y libro de actividades.
	- Mitigacion: definir una tabla/evento canonico reutilizable para trazabilidad.

## Tareas pendientes anotadas por peticion
1. Esperar modelos existentes del libro de actividades por UDs para unificar estructura final.
2. Definir MVP de `LibroActividadUD` con fecha, enunciado, equipamiento y modo de asignacion.
3. Evaluar soporte integrado para links e imagenes en actividades y proyectos.
4. Diseñar relacion entre actividades/proyectos y el historial del recurso `PC`.
5. Diseñar relacion entre actividades/proyectos y el historial del usuario visible en perfil/ficha.
6. Decidir si la trazabilidad se implementa como historial comun de eventos o como historiales separados con proyecciones.

## Millores proposades (nova entrada)

### Millora 1 - Integracio amb mapa 3D per localitzar recursos en temps real
Estat:
- Implementacio parcial completada en producte actual.

Inclou:
1. Localitzacio per `resourceCode` via query (`resourceCode/resource/resource_code`) en dashboard.
2. Seleccio automatica de recurs + focus de camera a `highlightedLocation`.
3. Ressaltat parpadejant temporal del recurs localitzat.
4. Base preparada per invocar-ho des de futura `FichaActividad`.

Pendent:
1. Botó directe "Localitzar al mapa" integrat al `AlumnoWorkflowPanel` per recursos assignats (fase transitòria fins `FichaActividad`).
2. Normalitzar navegacio des de llibre d'activitats cap a dashboard amb query canonic.

### Millora 2 - Validacio automatica de passos amb IA/OCR
Estat:
- Pendent d'analisi tecnica abans d'implementacio.

Analisi a completar:
1. OCR local vs servei extern (cost, privacitat, latencia).
2. Definicio de patrons validables per pas (`regex`, rangs, paraules clau).
3. Gestio d'errors i tolerancia de lectura (qualitat imatge, idioma, soroll).
4. Flux de revisio manual quan la validacio automatica no sigui concloent.
5. Traçabilitat de validacions al perfil d'usuari i historial de recurs.

Proposta MVP OCR:
1. Validar un subconjunt de passos amb text numeric (ex. temperatura `NN°C`).
2. Feedback immediat a l'alumne (`valid/invalid/revisio manual`).
3. Guardar resultat, text extret i evidencies al historial.

## Ampliacion solicitada (diseño + menu proyecto + menu usuario)

### A) Nuevos recursos 3D especiales
1. Recurso `ROBOT`:
	- geometria: cubo de `1/2` baldosa,
	- posicion inicial: centrado en baldosa,
	- comportamiento: desplazamiento por sala cuando un usuario ejecuta actividad asociada.
2. Recurso `CAMARA`:
	- geometria: esfera de `1/4` baldosa,
	- visual: relleno azul,
	- posicion por defecto: sobre superficie de mesa.

### B) Menu de proyecto (acceso completo)
1. Confirmar accesos desde menu:
	- abrir proyecto,
	- editar proyecto,
	- crear proyecto nuevo.
2. Crear proyecto nuevo debe abrir espacio de trabajo con:
	- mesa sin asignar por defecto,
	- campos de texto:
	  - titulo,
	  - links a dosier,
	  - descripcion,
	  - estado del proyecto,
	  - usuarios participantes.
3. Exportacion:
	- exportar proyecto a PDF,
	- incluir vistas del proyecto (resumen + estado + participantes + tareas/recursos).

### C) Pantallas de proyecto y links en 3D
1. Permitir insertar links asociados a pantallas del proyecto.
2. Visualizar esos links directamente en el espacio 3D (overlay o tooltip clicable).

### D) Recurso existente PCA001 (vista extendida)
1. Crear menu de detalle para `PCA001` con:
	- historial de asignaciones,
	- grafico de estadisticas de uso,
	- estado actual.

### E) Menu Usuario (perfil + actividades)
1. Perfil de usuario:
	- ver perfil,
	- crear/editar ficha de usuario,
	- permitir links a proyectos externos en campo de texto.
2. Actividades de usuario:
	- lista de actividades,
	- separacion completadas / pendientes,
	- estadisticas nuevas de actividad.

### F) Criterios de aceptacion para esta ampliacion
1. `ROBOT` y `CAMARA` visibles en 3D con geometria, color y posicion esperados.
2. `ROBOT` se mueve al disparar actividad asociada (evento reproducible).
3. Menu de proyecto permite crear/editar/abrir sin errores.
4. Proyecto exporta PDF con contenido minimo definido.
5. Links de pantallas se ven y abren desde vista 3D.
6. `PCA001` muestra historial + estadisticas + estado en su menu.
7. Menu usuario permite editar ficha y guardar links externos.
8. Actividades de usuario muestran completadas, pendientes y estadisticas.

### G) Tests recomendados (nuevo bloque)
1. TEST-ROBOT-01: insertar robot y validar desplazamiento por actividad.
2. TEST-CAM-01: insertar camara y validar posicion por defecto en mesa.
3. TEST-PROJ-UI-01: crear proyecto desde menu con todos los campos.
4. TEST-PROJ-PDF-01: exportar proyecto y validar contenido PDF.
5. TEST-LINK3D-01: link en pantalla visible y clicable en mapa 3D.
6. TEST-PCA001-01: historial y grafico de uso se renderizan correctamente.
7. TEST-USER-01: editar perfil y guardar links externos.
8. TEST-ACT-01: actividades completadas/pendientes + estadisticas visibles.

## Avance modo auto (2026-05-30 tarde)

Implementado en esta iteracion:
1. Menu Usuario operativo con accesos directos a:
	- `Mi actividad` (pendientes/completadas),
	- `Mi perfil`.
2. Nueva pantalla `Mi actividad`:
	- estados pendientes/completadas por UD,
	- estadisticas (total, completadas, pendientes, progreso, recursos asignados),
	- boton de localizacion de recurso en mapa 3D cuando hay recurso detectado.
3. Nueva pantalla `Mi perfil`:
	- edicion de ficha base,
	- guardado de links externos de proyecto (persistencia local),
	- vista previa de enlaces.
4. Workspace de proyecto integrado en Dashboard (modo `section=projects`):
	- crear/editar proyecto,
	- campos: titulo, links dosier, descripcion, estado, participantes, mesa,
	- guardar listado local,
	- exportacion PDF via vista imprimible.
5. Recurso especial `CAMARA` ajustado para usar preset de mesa por defecto si existe.

Pendiente de siguientes iteraciones:
1. Persistir proyectos/actividad en backend dedicado (actualmente localStorage como MVP funcional).
2. Vincular links de pantallas de proyecto directamente en elementos 3D y overlay clicable. (COMPLETADO en editor/overlay `space-elements.assignment.screenLink`)
3. Definir exportacion PDF de servidor (no dependiente del navegador) para entorno productivo.

### Delta adicional (modo auto continuo)
1. `space-elements` ampliado con `assignment.screenLink` para guardar enlaces de pantalla/proyecto.
2. Mapa 3D renderiza boton "Link pantalla" clicable sobre elementos `PANTALLA`/`CAMARA` cuando existe enlace.
3. Ficha de recurso añade bloque extendido para `PCA001`:
	- historial de eventos (asignacion, liberacion, estado, ubicacion, drive),
	- estadisticas de uso por tipo de evento.
4. Historial de `PCA001` implementado como MVP local (persistencia en `localStorage`) hasta disponer de endpoint canonico de historial cruzado.

### Delta adicional (modo auto continuo 2)
1. Nuevo modulo backend `projects` implementado con persistencia SQLite:
	- entidad `Project`,
	- entidad `ProjectTask`,
	- endpoints CRUD de proyectos y tareas.
2. Dashboard `section=projects` conectado a API real (ya no solo localStorage):
	- guardar/editar/eliminar proyecto contra backend,
	- crear tareas con `activityCode`, `ownerUserEmail`, `mesaNum`, `resourceCode`, `status`, `notes`,
	- toggle de estado y borrado de tarea.
3. Exportacion PDF (navegador) ampliada para incluir listado de tareas del proyecto.

Pendiente despues de este avance:
1. Enlazar eventos de proyecto/tarea con historial canonico de recurso/usuario (backend). (COMPLETADO)
2. Sustituir exportacion PDF por endpoint de servidor para uso productivo. (COMPLETADO)
3. Implementar modelo dedicado de `LibroActividadUD` y unificarlo con tareas/proyectos. (COMPLETADO)

### Delta adicional (modo auto continuo 3)
1. `projects.service` registra eventos canonicos en tabla `history` para:
	- alta/edicion/borrado de proyecto,
	- alta/edicion/borrado de tarea.
2. Enlace de trazabilidad resuelve contexto de usuario y recurso cuando existe:
	- usuario por `actorEmail`/`ownerUserEmail`,
	- recurso por `resourceCode`.
3. `projects.controller` propaga identidad JWT (`req.user.email`) en acciones mutables para firmar historial.
4. `projects.module` incorpora entidades `History`, `User` y `Resource` para soporte de enlace canonico.

### Delta adicional (modo auto continuo 4)
1. Exportacion PDF de proyecto migrada a backend (`GET /projects/:id/export/pdf`) con generacion de archivo real y descarga directa en frontend.
2. `Dashboard` deja de usar `window.print` y ahora consume exportacion PDF de servidor.
3. Nuevo modulo `ud-activities` (LibroActividadUD MVP) con CRUD protegido por JWT:
	- entidad `UdActivity` con `udCode`, `title`, `date`, `statement`, `requiredEquipment`, `assignmentMode`, `resourceTypes`, `links`, `images`, `projectId`, `status`.
4. Integracion con proyectos/tareas:
	- `ProjectTask` incorpora `udActivityId` nullable,
	- endpoints para enlazar/desenlazar tarea de actividad UD (`/ud-activities/:id/link-task/:taskId`, `/ud-activities/unlink-task/:taskId`).
5. Trazabilidad canonica tambien para UD:
	- alta/edicion/borrado de actividad UD,
	- enlace/desenlace de tareas UD,
	- eventos guardados en `history`.

### Delta adicional (modo auto continuo 5)
1. Nuevo modulo backend `storage-locations` para almacenamiento dinamico:
	- entidad `StorageLocation` con `type`, `zone`, `row`, `module`, `label`, `room`, `capacity`, `active`, `coordinates`.
2. Endpoints CRUD protegidos por JWT:
	- `GET/POST/PATCH/DELETE /storage-locations`.
3. Cliente frontend preparado con metodos API:
	- `getStorageLocations`, `createStorageLocation`, `updateStorageLocation`, `deleteStorageLocation`.
4. Estado pendiente de Fase 5 tras este avance:
	- conectar selector visual en inventario/ficha,
	- renderizar recursos `available` en posiciones de almacen en mapa AULA/SALAPRU.

### Delta adicional (modo auto continuo 6)
1. Inventario integra ubicaciones dinamicas reales de `storage-locations` en `Posicio nova`:
	- mezcla opciones estaticas (mesa/estanteria base) con opciones dinamicas de backend por coordenadas.
2. Ficha de recurso integra ubicaciones dinamicas en selector `Posicio detallada`.
3. Mapa 3D ajustado para filtrar recursos por sala (`location.room`) y mantener render consistente por contexto AULA/SALAPRU.
4. Correccion de robustez en visualizacion de `Assignat a`:
	- fallback ampliado (`assignedUser.email`, `assignedToUser.email`, `user_email`, `userEmail`) para evitar casos de "Sense assignar" tras autoasignacion.

### Delta adicional (modo auto continuo 7)
1. Dashboard carga `storage-locations` junto a recursos/usuarios para contexto visual completo de sala.
2. Mapa 3D renderiza marcadores de ubicaciones dinamicas de almacenamiento (estanteria/armario) por sala activa.
3. Recursos `available` en coordenadas de almacen ahora se visualizan con referencia fisica explicita de su ubicacion.

### Delta adicional (modo auto continuo 8)
1. Adjuntos enriquecidos pasan de diseno a implementacion basica real:
	- subida de imagen para proyecto: `POST /projects/:id/upload-image`,
	- subida de imagen para actividad UD: `POST /ud-activities/:id/upload-image`.
2. Archivos subidos expuestos por backend en ruta publica `/uploads/...`.
3. Proyecto incorpora campo `attachments[]` persistente para trazabilidad de adjuntos.
4. API frontend incorpora metodos:
	- `uploadProjectImage(projectId, file)`,
	- `uploadUdActivityImage(udActivityId, file)`.
5. Documentacion tecnica consolidada creada:
	- `docs/PROYECTO_API_MME.md` con objetivos, caracteristicas, funcionamiento, estructura, fases y mejoras.

### Delta adicional (modo auto continuo 9)
1. Nuevo backlog priorizado antes de la simulacion de actividad con usuario de prueba:
	- `SalaEditor` aislada para Admin Master,
	- restriccion por tipo de objeto y validacion de colisiones,
	- persistencia de propiedades visuales individuales por elemento,
	- copia de sala base para pruebas,
	- boton `Aplicar` para guardar posiciones tras validacion,
	- PCs sin coordenadas con slot automatico por mesa,
	- pantallas con rotacion 45° en superficie superior,
	- mesa alineada a la reticula del suelo,
	- lista cerrada de posiciones para evitar solapes.
2. En gestion de usuarios queda visible el acceso `Entregar actividad` para Admin Master con navegacion a informes y entrega.
