# Anàlisi de Gaps, Dubtes i Millores
**Data:** 2026-06-01  
**Basat en:** Objectius generals v0.3 vs. estat real del codi

---

## 🔴 GAPS CRÍTICS (bloquegen objectius)

### G1 — Rol BIP no existeix al model
**On:** `src/users/user.model.ts`  
**Problema:** `role` només permet `'user'` | `'admin'`. Tot el sistema de permisos BIP definit a la matriu de rols és inimplementable sense un tercer rol.  
**Proposta:** Afegir `role: 'user' | 'bip' | 'admin'` al model i actualitzar els guards.

---

### G2 — Whitelist en Excel, no en BD
**On:** `src/admin/admin.service.ts` + `data/whitelist.xlsx`  
**Problema:** L'spec defineix `academicYear`, `module`, `canEdit`, `approvedBy`, `approvedAt`. El fitxer Excel actual només guarda emails. Impossibilita gestió multi-curs i tancament de curs en mode consulta.  
**Proposta:** Migrar a entitat `whitelist` a SQLite.

---

### G3 — `resource.status` inconsistent
**On:** `src/resources/dto/update-resource.dto.ts` i `create-resource.dto.ts`  
**Problema:** El DTO valida `@IsIn(['available', 'shared', 'occupied'])` però l'endpoint `/resources/assign` escriu `status: 'assigned'` a la BD. Enviament directe via PATCH de `status:'assigned'` falla.  
**Proposta:** Ampliar l'enum a `['available', 'shared', 'occupied', 'assigned', 'maintenance', 'review', 'recycle']`.

---

### G4 — History model no coincideix amb l'spec
**On:** `src/history/history.model.ts`  
**Problema:** Model actual té `details: string`. L'spec requereix `oldValue`, `newValue`, `notes`, `activityId`, `createdBy` (email), `metadata`. Sense això no és possible l'exportació estructurada ni les anotacions per rol.  
**Proposta:** Ampliar el model (addint columnes nullable per compatibilitat amb dades existents).

---

### G5 — `user_activities` no existeix
**On:** Manca mòdul  
**Problema:** `UdActivity` té un sol `status` per a l'activitat global. No es pot fer seguiment individual per alumne (progrés, nota, checkmarks completats, entrega). Objectiu #2 és inimplementable.  
**Proposta:** Crear model `user_activity_progress` amb les columnes de l'spec.

---

### G6 — Endpoints de api.js sense backend
**On:** `frontend/src/services/api.js`  
**Problema:** Existeixen `getMyResources()` → `GET /resources/my` i `selfAssignResource()` → `POST /resources/self-assign` al frontend però **no hi ha cap ruta al controller**. El frontend crida endpoints inexistents.  
**Proposta:** Implementar o confirmar si estan planificats.

---

## 🟡 GAPS MODERATS (limiten funcionalitat)

### G7 — `element_templates` no existeix
Objectiu #1 (Editor 3D amb versionat) no té cap base. El camp `type` a `resources` fa de plantilla improvisada. Caldrà crear el mòdul complet.

### G8 — `resource_assignments` inexistent com a entitat separada
L'assignació actual és un camp `assignedToUserId` nullable a `resources`. No suporta: assignació a grup, a projecte, tipus no bloquejant, historial d'assignacions.

### G9 — `space_versions` inexistent
No hi ha snapshots de sala. `SpaceElement.updatedAt` i `History` no substitueixen un sistema de versions complet.

### G10 — Notificacions no implementades
Cap mòdul, cap canal (SSE/WebSocket/polling). L'spec diu "efímeres" però el backend ha d'emetre algun event.

### G11 — UdActivity model no coincideix amb l'spec
L'spec defineix `steps`, `checkmarks`, `dueDate`, `published`, `approved`, `latePenaltyRate`, `maxPenalty`, `points`. El model actual té `statement`, `date`, `status`. Noms i camps diferents.

---

## ❓ DUBTES A ACLARIR (decisions de disseny)

### D1 — Rol BIP: automàtic o manual?
L'spec diu "BIP automàtic si 100% activitats completades O aprovació manual Admin Master".  
- **Pregunta:** L'assignació automàtica es fa en el moment d'entregar l'última activitat (event-driven) o per un job periòdic?  
- **Impacte:** Si és event-driven cal modificar `releaseActivityResources`. Si és job, cal un cron.

### D2 — Notificacions: estat React o BD?
L'spec diu "efímeres (desapareixen en recarregar)".  
- **Opció A:** Només estat React/Zustand al frontend. Zero backend. El frontend consulta novetats en cada càrrega.
- **Opció B:** Taula temporal a SQLite amb TTL de sessió. Permet notificar events mentre l'usuari no té la pàgina oberta.
- **Pregunta:** Ha de saber l'alumne, en entrar, que algú li ha alliberat un recurs mentre era fora?

### D3 — QR URL: localhost vs. producció?
L'spec diu `http://localhost:3000/recursos/{id}`.  
- **Problema:** En producció la URL serà diferent.  
- **Pregunta:** Hi ha `BASE_URL` configurable al `.env`? O el QR sempre apunta a localhost per ús intern a l'aula?

### D4 — "Cursos" vs. "Actividades" al menú
Ambdós menús filtren per UD. "Cursos" afegeix un filtre d'any (2026/2027).  
- **Pregunta:** Quin és el criteri per aparèixer a "Cursos" vs. "Actividades"? ¿Haurien de fusionar-se en un sol menú amb filtre any+UD? El menú actual és hardcoded (UD01/UD03/UD05), no reflecteix la BD.

### D5 — Space versions: tamany dels snapshots
Si l'Aula té 100+ SpaceElements, cada versió és un JSON de varios KB.  
- **Pregunta:** Cal arxivar versions antigues? Quantes versions es volen conservar per sala? (impacte a SQLite)

### D6 — Tancament de curs: què passa amb els recursos?
L'spec diu "Curs tancat → usuaris només consulta, no edició".  
- **Pregunta:** Els recursos assignats a usuaris d'un curs tancat s'alliberen automàticament? O es mantenen fins que l'admin ho faci manualment?

### D7 — `resource_assignments` vs. camp actual
El camp `assignedToUserId` a `resources` no pot representar assignació a grup ni a projecte.  
- **Pregunta:** Es manté el camp actual per compatibilitat i s'afegeix la nova taula en paral·lel? O es migra tot?

---

## 🔵 MILLORES DE MENÚ (usabilitat)

### M1 — Menú BIP diferenciat
Els usuaris BIP han de veure els menús d'usuari + opcions addicionals (validar activitats, assignar a qualsevol, estadístiques). Ara reben el menú estàndard d'usuari.

**Proposta:**
```
Usuario normal:     Usuario → BIP → Admin
                    Menú user ⊂ Menú BIP ⊂ Menú admin
```

### M2 — Secció "Historial" al menú usuari
L'spec diu "Alumne pot veure el seu propi historial complet". Cap ítem de menú ho ofereix ara.  
**Proposta:** Afegir a `Usuario`:
- Historial de recursos (quins he tingut)
- Historial d'activitats (entregues, notes)

### M3 — Indicador de notificacions
Cap indicació visual de notificacions pendents. Mínim un badge (⚡3) al menú.

### M4 — "Config General > Diseño recursos" → "Editor 3D"
El nom "Diseño recursos" no reflecteix l'Objectiu #1. Proposta:
```
Config General
  ├── Editor 3D (templates, versions)   ← renombrar
  ├── Versions de sala
  └── Generals
```

### M5 — "Sala Test UD01" duplicada
Apareix tant a "Visualización" com a "Recursos". Unificar sota "Visualización".

### M6 — Menú "Cursos" → dinàmic
Els ítems UD01/UD03/UD05 i anys 2026/2027 estan hardcoded a `MenuAdmin.jsx`.  
**Proposta:** Carregar des de `GET /ud-activities?grouped=true` en muntar el component.

### M7 — Ruta QR Scanner sense menú ni ruta
`QREscanner.jsx` existeix però `App.jsx` no té la ruta `/qr-escaner`.  
**Proposta:** Afegir ruta i ítem a "Recursos" → "Llegir QR".

### M8 — "Mis grupos" sense implementació
El menú apunta a `/dashboard?section=my-groups` però el Dashboard no renderitza res per a `section=my-groups`.  
**Proposta:** Implementar o eliminar l'ítem fins que estigui.

---

## ✅ TASQUES PENDENTS PRIORITZADES

| Prioritat | Tasca | Depèn de |
|---|---|---|
| 🔴 P1 | Afegir `role: 'bip'` a User model | — |
| 🔴 P1 | Corregir `resource.status` enum al DTO | — |
| 🔴 P1 | Implementar `GET /resources/my` i `POST /resources/self-assign` | — |
| 🔴 P2 | Migrar whitelist a BD amb `academicYear` i `module` | — |
| 🔴 P2 | Ampliar History model amb `oldValue`, `newValue`, `activityId`, `notes`, `metadata` | — |
| 🟡 P3 | Crear `user_activity_progress` model i endpoints | UdActivity ok |
| 🟡 P3 | Menú BIP diferenciat al frontend | rol BIP |
| 🟡 P3 | Menú "Cursos" dinàmic des de BD | ud-activities API |
| 🟡 P4 | Afegir ruta i menú QR Scanner | — |
| 🟡 P4 | Implementar "Historial" al menú usuari | History API |
| 🟢 P5 | Crear `element_templates` mòdul | — |
| 🟢 P5 | Crear `space_versions` mòdul | — |
| 🟢 P5 | Notificacions (decidir arquitectura D2 primer) | D2 |
| 🟢 P6 | `resource_assignments` taula separada | History ok |
