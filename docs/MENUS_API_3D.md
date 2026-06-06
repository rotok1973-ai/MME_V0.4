# Reestructuracion Menus + API + Salas 3D (Fase de definicion)

## 1. Top Nav Final

### 1.1 Admin Master
- Curso
  - 2026
  - 2027
- Proyectos
  - Human Machine
  - Nuevo proyecto
  - Editar proyecto
- Actividades
  - UD01, UD02, UD03, UD04, UD05, UD06
  - Nueva actividad
- Gestion de Recursos
  - Espacios
  - Inventario
- Gestion de usuarios
  - Lista blanca
  - Anadir
  - Editar
- Gestion de grupos
  - Ver existentes
  - Ver actividad
  - Crear nuevo
- Configuraciones generales
  - Diseno de recursos
  - Generales
- Ayuda
- Acerca de

### 1.2 Usuario MME (incluye BiP)
- Proyectos
  - Human Machine
  - Nuevo proyecto
  - Editar mi proyecto
- Actividades
  - UD01.. abrir
  - Entregar
  - Realizadas
- Ver recursos
  - Espacios
  - Inventari
  - Asignarse recursos en sala vacia
- Mi actividad
  - Programadas
  - Pendientes
  - Realizadas
  - Finalizadas
- Mis grupos
  - Ver actuales
  - Ver actividad
  - Crear nuevo
- Configuraciones generales
  - Mis entregas
- Ayuda
- Acerca de

## 2. Menu flotante SALAS 3D (todas)

### 2.1 Selector de predisenados
- USUARIO
- USUARIOBIP
- ADMIN_MASTER
- GRUPOSPC
- PORTATIL
- PANTALLA
- IMPRESORA
- MESA
- ESTANTERIA
- ARMARIO
- RACK_PORTATILES_TALLER
- Crear nuevo recurso

### 2.2 Crear nuevo recurso (editor)
Campos obligatorios:
- nombre
- dimensiones: ancho, largo, alto
- colorPerfil (borde)
- colorRelleno

Campos opcionales:
- capacidad
- tipoPosicionamiento (superficie, dentro, balda)
- estados visuales por estado logico
- animacion (parpadeo, velocidad)

## 3. Definiciones visuales 3D

- Usuarios se renderizan a altura de 4 baldosas sobre el suelo.
- USUARIO: esfera sin relleno blanca, parpadeo lento.
- USUARIOBIP: esfera sin relleno cyan, cruz central, parpadeo lento a blanco.
- ADMIN_MASTER: esfera sin relleno roja, cruz cyan, portatil cyan encima, parpadeo lento a blanco.
- PORTATIL: prisma 1, 1, 0.25 perfil azul, relleno cyan.
- PANTALLA: prisma 1, 0.25, 1 perfil gris, relleno amarillo.
- IMPRESORA: prisma 1, 1, 0.5 perfil blanco.
- ESTANTERIA: prisma malla exterior/interior 5 alto x 2 ancho, 20 posiciones.
- RACK_PORTATILES_TALLER: prisma 1, 1, 2.5 con 10 posiciones fijas.
- ARMARIO: prisma malla interior 2, 1, 4 con 4 baldas.

Estados visuales:
- ocupado: violeta
- revisar: gris parpadeante
- seleccionado: contorno exterior verde

## 4. Modelo funcional de negocio

- Recursos asignables a usuarios para ejercicios y proyectos.
- Contexto de produccion: monitorizar disponibilidad, uso y asignacion de recursos mientras se ejecuta una actividad.
- Contexto de validacion: usar una sala test aislada para simular la actividad UD01 Pasta Termica antes de aplicar cambios reales.
- Actividad o proyecto siempre ligado a una mesa de Aula Taller.
- Asignacion de mesa: admin o autoasignacion.
- Actividades MME: UD01..UD06.
- Estados de actividad de alumno: programadas, pendientes, realizadas, finalizadas.

Datos visibles por actividad:
- fecha de entrega
- fecha de realizacion
- recursos vinculados
- puntos
- estado

Metodos de evaluacion y seguimiento:
- registro de pasos completados
- envio de evidencias segun plantilla
- validacion manual o semiautomatica por Admin Master
- comprobacion de disponibilidad y asignacion de recursos en tiempo de uso

## 5. Navegacion entre salas

- SALAPRU:
  - sala de diseno y prueba (sin suelo)
  - insercion de elementos en posiciones preestablecidas
  - sin paredes en rediseno solicitado
- Aula Taller:
  - posiciones de mesas fijas
  - asociacion a actividades individuales y de grupo
  - visualizacion de usuarios y recursos asignados por actividad
- Sala Mesa (1..9):
  - inventario de actividad
  - asignacion de recursos
  - estado de tareas
  - importacion/edicion de fichas de recursos

## 6. Contrato API propuesto (siguiente fase)

Rutas nuevas objetivo:
- GET /api/catalog/resource-templates
- POST /api/resources/custom
- PATCH /api/resources/:id/visual
- POST /api/spaces/:spaceId/elements
- PATCH /api/spaces/:spaceId/elements/:elementId
- GET /api/spaces/:spaceId/elements
- POST /api/activities
- PATCH /api/activities/:id
- GET /api/activities?ud=UD01&state=pending
- POST /api/activities/:id/assign-resource
- POST /api/activities/:id/assign-user
- POST /api/activities/:id/assign-table
- GET /api/tables/:tableId/room-view

## 7. Implementacion por fases

Fase 1 (aplicada ahora):
- top nav por rol en frontend
- documento de estructura funcional y API

Fase 2:
- menu flotante 3D con selector predisenados
- alta de recurso custom en cliente

Fase 3:
- endpoints backend para elementos 3D y plantillas
- persistencia de configuraciones visuales por estado

Fase 4:
- actividades UD01..UD06 + historial
- salas Mesa 1..9 y navegacion operativa


quiero revisar objetivos y mejorar la apariencia de los recursos separando 3 tipos recursos: 1. de trabajo (Mesas son 9), 2. de almacenamiento de recursos (estanterias, armarios...) y 3. los recursos asignables a usuarios (PCs, impresoras, pantallas, discos duros, portatiles...) . Los recursos asignables son utilizados (autoasignados o asignados por el admin master) por los usuarios para realizar las Actividades y proyectos. els registro de estas actividades y el seguimiento se utiliza para gestionar los recursos mientas se realizan las actividades y quedan asociados a su progreso y consulta.