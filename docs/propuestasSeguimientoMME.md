🎯 OBJECTIUS GENERALS
#	Objectiu	Descripció
1	Editor 3D amb versionat	Sistema de templates amb versions i herència
2	Visualització d'activitats per UD	Filtratge, ordenació, progrés i penalitzacions
3	Assignació de recursos	Recurs = usuari o grup. Projectes amb llistes no bloquejants
4	Control de versions de sales	Historial complet amb data, autor i càrrega per activitat
5	QR automàtic per recurs	URL completa. Test amb càmera PC a V0.5
6	Notificacions in-app	Tots els esdeveniments clau. Efímeres
7	Registre individual per invitació	Llista blanca + auto-registre
8	Traçabilitat completa	Historial exportable, anotacions per rol
1️⃣ EDITOR 3D I VERSIONAT D'ELEMENTS
📌 Especificacions
Concepte	Decisió
Nova versió	Actualització automàtica de tots els recursos existents
Rollback	Manual amb restitució de codi comentat
Vista prèvia	Sala de proves abans d'aplicar canvis
Herència	Elements personalitzats hereden de template base per categoria
Conflictes	Només Admin Master pot modificar templates base. Usuaris BIP creen còpies personalitzades
📁 Estructura de dades
javascript
// element_templates.model.ts
{
  id: string;              // "PANTALLA_V1"
  type: string;            // "PANTALLA", "PC", "PORTATIL", "IMPRESORA"
  version: number;
  isActive: boolean;
  isBase: boolean;         // true si és template base de categoria
  inheritsFrom: string;    // null o ID del template base
  visualProps: {
    colorPerfil: string;   // "#888888"
    colorRelleno: string;  // "rgba(136,136,136,0.2)"
    width: number;         // en rajoles
    height: number;
    depth: number;
    rotationY: number;     // 0-315 (múltiples 45)
    wireframe: boolean;
    blinkSpeed: number;    // ms, només per estats específics
  };
  stateOverrides: {        // personalització per estat
    occupied: { colorRelleno: "#aa66ff" },
    review: { blinkSpeed: 500, colorPerfil: "#888" }
  };
  createdBy: string;       // email del creador
  createdAt: string;
  deprecatedAt: string | null;
  previousVersionId: string | null;
  changeNotes: string;     // comentari amb paràmetres antics
}

// resources.model.ts (camp afegit)
{
  ...
  elementTemplateId: string;  // FK a element_templates
  customOverrides: object;    // per a personalitzacions individuals
}
🔄 Flux d'actualització
text
Admin Master edita template PANTALLA_V1
        ↓
Crea PANTALLA_V2 amb canvis + changeNotes
        ↓
Vista prèvia a SalaPU
        ↓
Confirmació → Activació
        ↓
Actualització automàtica de tots els recursos tipus PANTALLA
        ↓
Registre d'historial del canvi
2️⃣ VISUALITZACIÓ D'ACTIVITATS (UD)
📌 Especificacions
Concepte	Decisió
Filtratge	Per UD (UD01..UD06)
Ordenació per defecte	Per UD. Destacades: lliurament pendent (més properes primer)
Popup d'avís	En obrir sessió, mostrar activitats amb data límit propera
Activitats expirades	Bloquejades, o permeses amb penalització (segons configuració admin)
Activitats futures	Visibles però no accessibles fins que Admin les publica
Progrés visual	Barra + checkmarks + percentatge (nota)
📊 Càlcul de nota
javascript
nota_base = (passos_completats / total_passos) * 100

// Penalització per retard
dies_retard = max(0, data_entrega - data_limitz)
if (dies_retard > 0) {
  penalitzacio = min(50, dies_retard * 10)  // màxim -50%
  nota_final = nota_base * (1 - penalitzacio / 100)
} else {
  nota_final = nota_base
}

// Penalització per checkmarks no completats
checkmarks_pendents = total_checkmarks - checkmarks_completats
nota_final -= checkmarks_pendents * 5  // cada checkmark = -5%
📁 Estructura d'activitat
javascript
// ud_activities.model.ts
{
  id: string;                // "UD01_ACT01"
  udCode: string;            // "UD01"
  title: string;             // "Pasta Tèrmica"
  description: string;
  steps: [];                 // array de passos de l'activitat
  checkmarks: [];            // llista de verificacions
  dueDate: string;
  published: boolean;        // controla accessibilitat
  approved: boolean;         // per a activitats del curs següent
  allowedLatePenalty: boolean;
  latePenaltyRate: number;   // % penalització per setmana
  maxPenalty: number;        // màxim % de penalització
  resourcesRequired: [];     // llista de recursos necessaris
  points: number;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
}

// user_activities.model.ts (progrés individual)
{
  userId: number;
  activityId: string;
  status: "programada" | "pendent" | "realitzada" | "finalitzada" | "retornada";
  progress: number;          // % completat
  completedSteps: [];
  completedCheckmarks: [];
  grade: number | null;
  submittedAt: string | null;
  validatedBy: string | null;  // email de l'admin que va validar
  returnedReason: string | null; // motiu de retorn
  resourcesUsed: [];           // recursos que va utilitzar l'alumne
}
🔄 Flux de validació d'activitat
text
Alumne entrega activitat
        ↓
Admin Master revisa
        ↓
├── Correcta → Validar → Nota final + Alliberar recursos
└── Incorrecta → Retornar + Raó → Alumne torna a treballar
3️⃣ ASSIGNACIÓ DE RECURSOS
📌 Especificacions
Concepte	Decisió
Assignació base	Un recurs = un usuari o un grup
Projectes	Llistes de recursos necessaris. NO bloquegen
Recursos compartits	Assignació simultània dins del mateix projecte
Visualització recurs projecte	Perfil verd si està assignat a projecte actiu
Bloqueig real	Només a Activitats UD i projectes actius nous
Grup vs Projecte	Grup = activitat conjunta, entrega individual. Projecte = entrega conjunta
📁 Estructura
javascript
// resource_assignments.model.ts
{
  id: number;
  resourceId: number;
  userId: number | null;
  groupId: number | null;
  projectId: number | null;
  activityId: string | null;
  assignmentType: "individual" | "group" | "project" | "activity";
  isBlocking: boolean;     // true només per activitats UD
  assignedAt: string;
  assignedBy: string;
  releasedAt: string | null;
}

// project_resources.model.ts (llista de recursos necessaris per projecte)
{
  projectId: number;
  resourceId: number;
  quantity: number;
  isRequired: boolean;
}
👥 Llista blanca per curs
javascript
// whitelist.model.ts
{
  email: string;
  academicYear: string;    // "2026", "2027"
  module: string;          // "MME", "SOX"
  isActive: boolean;
  canEdit: boolean;        // false per "convidat"
  approvedBy: string;
  approvedAt: string;
}

// Curs tancat → usuaris només consulta, no edició
⭐ Progrés per obtenir rol BIP
javascript
// user_progress.model.ts
{
  userId: number;
  totalActivitiesCompleted: number;
  totalPoints: number;
  isBipRequested: boolean;
  bipGrantedAt: string | null;
  bipGrantedBy: string | null;
}

// Condicions per BIP automàtic:
// - 100% activitats completades d'un curs
// - O aprovació manual per Admin Master
4️⃣ CONTROL DE VERSIONS DE SALES
📌 Especificacions
Concepte	Decisió
Càrrega d'activitat	Mostra recursos assignats a usuaris. Recursos es bloquegen durant l'activitat
Alliberament automàtic	Quan l'usuari entrega l'activitat
Consulta històrica	Usuari pot veure quin PC va utilitzar en activitat anterior
Versió per defecte	Alumne veu versió associada a la seva activitat/projecte actual
Historial de canvis	Només programador Admin pot modificar elements fixos (armaris, taules, estanteries)
Restauració parcial	Només en mode programador de proves
Conflictes	Accés limitat a un sol administrador alhora (lock)
📁 Estructura
javascript
// space_versions.model.ts
{
  id: number;
  spaceId: string;         // "AULA", "SALAPRU", "MESA_1", etc.
  version: number;
  snapshot: object;        // JSON complet de la disposició
  createdBy: string;
  createdAt: string;
  activityId: string | null; // si està associada a una activitat
  comment: string;
}

// resource_activity_lock.model.ts (bloqueig durant activitat)
{
  resourceId: number;
  activityId: string;
  userId: number;
  lockedAt: string;
  releasedAt: string | null;
}
🔄 Alliberament automàtic
javascript
// Quan l'usuari entrega l'activitat
async function releaseActivityResources(userId, activityId) {
  const locks = await getResourceLocks(userId, activityId);
  for (const lock of locks) {
    await releaseResource(lock.resourceId);
    await createHistoryEvent({
      resourceId: lock.resourceId,
      action: "auto_released",
      details: `Alliberat automàticament en entregar activitat ${activityId}`
    });
  }
}
5️⃣ LECTORS QR
📌 Especificacions
Concepte	Decisió
Format QR	URL completa: http://localhost:3000/recursos/{id}
Validació offline	No implementada a V0.5
Test	Càmera PC com a lector a l'aula
📁 Generació
javascript
// Generació automàtica en crear recurs
function generateQRCode(resourceId, baseUrl = 'http://localhost:3000') {
  const url = `${baseUrl}/recursos/${resourceId}`;
  // Retorna URL per generar QR amb llibreria externa
  return url;
}
6️⃣ NOTIFICACIONS IN-APP
📌 Especificacions
Concepte	Decisió
Tipus	Assignació, alliberament, nova activitat, data límit (24h), canvi d'estat
Persistència	Efímeres (desapareixen en recarregar)
📁 Estructura
javascript
// notifications.model.ts (efímer, pot ser només en memòria o DB temporal)
{
  id: string;
  userId: number;
  type: "assignment" | "release" | "new_activity" | "deadline" | "status_change";
  title: string;
  message: string;
  data: object;           // dades addicionals (resourceId, activityId, etc.)
  createdAt: string;
  read: boolean;
}
7️⃣ REGISTRE D'USUARIS
📌 Especificacions
Concepte	Decisió
Mètode	Registre individual amb email a llista blanca
API externa	No implementada
Registre per invitació	Sí, usuaris es registren ells mateixos
8️⃣ HISTORIAL I TRAÇABILITAT
📌 Especificacions
Concepte	Decisió
Visualització	Alumne pot veure el seu propi historial complet
Exportació	Admin pot exportar en CSV/PDF
Retenció	Indefinida. Admin pot configurar eliminació manual
Events a registrar	Assignació, alliberament, canvi d'ubicació, canvi d'estat d'activitat, login/logout, edició de perfil
Anotacions manuals	Usuaris normals: només sobre recursos assignats. Usuaris BIP: sobre qualsevol recurs sense assignar. Admin Master: sempre.
📁 Estructura
javascript
// history.model.ts
{
  id: number;
  userId: number | null;
  resourceId: number | null;
  activityId: string | null;
  action: string;          // "assign", "release", "move", "login", "logout", "profile_edit", "activity_status_change"
  oldValue: string | null;
  newValue: string | null;
  notes: string | null;    // anotacions manuals
  createdBy: string;       // email de qui va fer l'acció (o va afegir la nota)
  createdAt: string;
  metadata: object;        // informació addicional (IP, navegador, etc.)
}

// statistics.model.ts (per a ús de recursos)
{
  resourceId: number;
  usageCount: number;      // nombre d'assignacions
  lastUsedAt: string;
  averageUsageDuration: number; // en hores
  needsReview: boolean;     // marcat per BIP si recurs no funciona
  reviewNote: string | null;
}
📊 Exportació
javascript
// Endpoint: GET /api/history/export/:entityType/:entityId
// Suporta CSV i PDF
// Admin pot filtrar per data, tipus d'acció, etc.
🔄 RESUM DE ROLS I PERMISOS
Acció	Admin Master	BiP	Usuari MME
Modificar templates base	✅	❌	❌
Crear element personalitzat	✅	✅ (heretat)	❌
Gestionar llista blanca per curs	✅	❌	❌
Tancar curs (mode només consulta)	✅	❌	❌
Assignar recurs a qualsevol	✅	✅	❌
Autoassignar-se recurs	✅	✅	✅
Assignar recurs a projecte (no bloquejant)	✅	✅	✅
Bloquejar recurs per activitat UD	✅	✅	❌
Alliberar recurs propi	✅	✅	✅
Alliberar recurs aliè	✅	❌	❌
Crear/editar activitats UD	✅	❌	❌
Publicar activitat	✅	❌	❌
Validar activitat entregada	✅	✅	❌
Retornar activitat per correcció	✅	✅	❌
Veure estadístiques d'ús recurs	✅	✅	❌
Marcar recurs per revisió	✅	✅	❌ (només els seus)
Afegir anotacions a historial	✅ (tots)	✅ (tots)	❌ (només assignats)
Exportar historial	✅	❌	❌
Modificar elements fixos sala	❌ (només programador)	❌	❌
