# PROYECTO API MME

## Objetivos
- Unificar la gestion de recursos, usuarios, proyectos, actividades UD y espacios 3D en una API consistente.
- Monitorizar en contexto de produccion la disponibilidad, el uso y la asignacion de recursos durante la ejecucion de actividades.
- Validar con una sala test la simulacion completa de una actividad UD antes de aplicar cambios a registros reales.
- Asegurar trazabilidad canonica de eventos para auditoria tecnica y seguimiento docente.
- Permitir flujos reales de trabajo para admin, BiP y alumno con permisos diferenciados.
- Mantener sincronizacion entre inventario, ficha, dashboard y mapa 3D.
- Preparar una base escalable para mejoras IA/OCR y automatizaciones futuras.

## Caracteristicas
- Autenticacion JWT para operaciones protegidas.
- CRUD completo de recursos con asignacion, autoasignacion y liberacion controlada.
- Persistencia de ubicacion enriquecida (`room`, `mesaId`, `placement`, `anchor`, `renderAnchorIndex`, coordenadas).
- Editor/visualizador 3D con elementos de sala y filtros de contexto.
- Gestion de proyectos y tareas con exportacion PDF server-side.
- Libro de actividades UD (`ud-activities`) integrado con tareas de proyecto.
- Trazabilidad canonica en tabla `history` para eventos de proyecto, tarea y actividad UD.
- Tabla dinamica de almacenamiento (`storage-locations`) con render de marcadores en mapa.
- Soporte de adjuntos basico con subida real de imagenes:
  - `POST /api/projects/:id/upload-image`
  - `POST /api/ud-activities/:id/upload-image`
- Sala de simulacion `SALATEST` para UD01 con:
  - elementos fijos (estanteria y armario),
  - ubicacion simulada no persistente,
  - menu de giro en pasos de 45 grados,
  - validacion simplificada (superficie, orientacion, proximidad, ocupacion, compatibilidad).
- Ficha de pasos UD01 integrada en `Mi actividad` con:
  - checklist por pasos,
  - captura de evidencias (texto, imagen referenciada, valor numerico),
  - simulacion de envio y evaluacion automatica por progreso.
- Entrega simulada ampliada con:
  - estado de entrega (`draft`/`submitted`/`reviewed`),
  - exportacion de informe JSON para revision tecnica/docente.

## Funcionamiento
1. Cliente frontend consume endpoints bajo prefijo `/api`.
2. Backend NestJS resuelve reglas de negocio y persiste en SQLite (TypeORM).
3. El mapa 3D renderiza recursos y usuarios en base a ubicacion persistida.
4. Inventario y ficha actualizan asignacion/ubicacion con payload consistente.
5. La sala test permite simular posicion, disponibilidad y asignacion sin afectar datos reales.
6. Proyectos y actividades UD generan eventos de historial para trazabilidad cruzada.
7. Exportacion PDF de proyecto se genera en backend y se descarga desde frontend.
8. Las imagenes subidas quedan accesibles en rutas publicas `/uploads/...`.

## Estructura del servicio
### Backend principal
- Framework: NestJS
- ORM: TypeORM
- DB: SQLite (`better-sqlite3`)
- Seguridad: JWT guard por controlador/modulo
- Archivos estaticos:
  - `/public`
  - `/uploads` (adjuntos)

### Modulos funcionales principales
- `auth`: login/registro/estrategia JWT
- `users`: gestion de usuarios y recursos por usuario
- `resources`: inventario, asignaciones y autoasignacion
- `space-elements`: elementos 3D y asignaciones visuales
- `projects`: proyectos, tareas, PDF y trazabilidad
- `ud-activities`: libro UD, enlace con tareas y trazabilidad
- `storage-locations`: ubicaciones dinamicas de almacen
- `history`: entidad de historial canonico
- `admin`: whitelist y utilidades de ayuda
- `import-export`: importacion de datos

## Estructura de archivos
### Backend relevante
- `src/main.ts`
- `src/app.module.ts`
- `src/resources/*`
- `src/projects/project.model.ts`
- `src/projects/project-task.model.ts`
- `src/projects/projects.controller.ts`
- `src/projects/projects.service.ts`
- `src/ud-activities/ud-activity.model.ts`
- `src/ud-activities/ud-activities.controller.ts`
- `src/ud-activities/ud-activities.service.ts`
- `src/storage-locations/storage-location.model.ts`
- `src/storage-locations/storage-locations.controller.ts`
- `src/storage-locations/storage-locations.service.ts`
- `src/history/history.model.ts`

### Frontend relevante
- `frontend/src/services/api.js`
- `frontend/src/pages/Dashboard.jsx`
- `frontend/src/pages/Inventario.jsx`
- `frontend/src/components/FichaRecurso.jsx`
- `frontend/src/components/Mapa3D.jsx`
- `frontend/src/components/LocationSelector.jsx`

### Documentacion operativa
- `docs/PLAN_TRABAJO_MANANA.md`
- `docs/TEST_VISUAL_SALAPRU.md`
- `docs/REESTRUCTURA_MENUS_API_3D.md`
- `docs/PROYECTO_API_MME.md`

## Fases del desarrollo
1. Base de autenticacion, usuarios e inventario.
2. Integracion de mapa/espacios 3D y persistencia de elementos.
3. Mejora UX de localizacion, filtros y asignaciones por contexto.
4. Modulo proyectos/tareas y migracion desde MVP local a backend real.
5. Trazabilidad canonica de eventos en historial.
6. Exportacion PDF de proyectos en servidor.
7. LibroActividadUD MVP enlazado con tareas/proyectos.
8. Almacenamiento dinamico con API y render en mapa.
9. Adjuntos de imagenes (subida real) para proyectos y actividades UD.

## Posibles mejoras
- Flujo completo de subida de imagenes en UI (selector, preview, borrado, validacion de tamano/tipo).
- OCR/IA para validacion automatica de pasos de actividad.
- Proyecciones de historial por usuario/recurso en endpoints dedicados.
- Politica de retencion y versionado de adjuntos.
- Compresion y optimizacion de chunk frontend para reducir warning de build.
- Test E2E automatizado por rol (Admin, BiP, Alumno MME).
- Control fino de permisos por accion y por recurso (RBAC/ABAC).
- Endpoint de consulta consolidada para panel docente (KPIs UD/proyecto/uso de recursos).
- Nuevo editor 3D aislado para Admin Master (`SalaEditor`) con salas clonadas para pruebas.
- Restricciones de posicion por tipo de objeto y validacion de colisiones antes de aplicar a sala real.
- Persistencia de propiedades visuales individuales por elemento (color, rotacion, transparencia, dimensiones).
- Boton `Aplicar` para guardar posiciones despues de validar la SalaPU.
- Posicionamiento automatico de PCs sin coordenadas dentro de la grilla de mesa.
- Rotacion limitada a pasos de 45 grados para pantallas y objetos compatibles.
- Mesa alineada a la reticula base del suelo con snapping de coordenadas.
- Copia de la sala taller base para edicion sin impacto sobre la original.

## Nuevas mejoras solicitadas en backlog
- Restricciones de posiciones por tipo de objeto.
- Sala 3D exclusiva `SalaEditor` para Admin Master.
- Persistencia de propiedades individuales por elemento.
- Test de posicionamiento en SalaPU antes de aplicar a sala real.
- Copia de la sala taller base.
- PCs asociados a mesa sin coordenadas absolutas.
- Monitores en superficie superior con rotacion.
- Boton `Aplicar` para guardar posiciones.
- Revision de dimensiones y representacion visual.
- Lista cerrada de posiciones para evitar solapes.
- Mesa pegada a la cuadrícula del suelo.

## Estado de implementacion basica
- Bloques basicos funcionales: completados en MVP operativo.
- Queda como siguiente nivel: mejoras avanzadas (OCR/IA, analitica avanzada, hardening de adjuntos y UX extendida).

## Guia rapida de test de uso (alumno)
1. Login con usuario alumno/BiP.
2. Dashboard en SALAPRU y AULA, validar recursos visibles por sala.
3. Autoasignar recurso disponible y verificar `Assignat a`.
4. Cambiar ubicacion (incluyendo storage dinamico) y comprobar reflejo en mapa.
5. Abrir ficha de recurso y validar estado/ubicacion.
6. Verificar navegacion y filtros por actividad/proyecto/mesa.
7. Abrir `Sala Test UD01` y validar simulacion sin persistencia real:
  - mover recurso por selector de ubicacion,
  - aplicar giro desde menu,
  - revisar panel de validacion.

## Registro tecnico durante test
Para cada incidencia capturar:
- rol y usuario
- ruta
- accion ejecutada
- resultado observado
- resultado esperado
- evidencia (captura/log)

Este registro se usara para aplicar correcciones incrementales en modo automatico.
