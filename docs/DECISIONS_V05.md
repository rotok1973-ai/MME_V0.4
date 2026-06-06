# Decisions i Plans per V0.5
**Data:** 2026-06-01

---

## G1 — Rol BIP: pla d'implementació

### Situació actual
`user.role` accepta `'user'` | `'admin'`. El frontend ja detecta BIP via
`group === 'BIP' || role === 'bip'` però el backend no ho aplica als guards.

### Pla (V0.5)
**Pas 1 — Model:**
```typescript
// user.model.ts
@Column({ default: 'user' })
role!: 'user' | 'bip' | 'admin';
```

**Pas 2 — Guard/Decorator:**
```typescript
// src/guards/roles.guard.ts
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}
  canActivate(ctx: ExecutionContext): boolean {
    const required = this.reflector.get<string[]>('roles', ctx.getHandler());
    if (!required) return true;
    const { user } = ctx.switchToHttp().getRequest();
    return required.includes(user.role);
  }
}

// src/decorators/roles.decorator.ts
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);
```

**Pas 3 — Aplica als endpoints:**
```typescript
// Exemple: validar activitat (BIP + Admin)
@Roles('bip', 'admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@Patch('ud-activities/:id/validate')
```

**Pas 4 — BIP automàtic per contabilitzar entregues:**
```typescript
// Condicions mínimes (a decidir el número exacte):
const MIN_ACTIVITIES = 4;  // ex: 4 activitats entregades

// En validar una activitat, comprovar:
if (userProgress.totalActivitiesCompleted >= MIN_ACTIVITIES) {
  user.role = 'bip';  // upgrade automàtic
}
```

**Nota "Cursos hardcoded":**
El menú mostra UD01-UD06 amb anys 2026/2027 hardcoded perquè la BD no té
el camp `academicYear` a `ud_activities`. En V0.5 afegir:
```typescript
// ud_activities.model.ts
@Column({ nullable: true })
academicYear?: string;  // "2025-26", "2026-27"
```
Aleshores el menú podrà fer `GET /ud-activities?grouped=year` i renderitzar
dinàmicament. Per ara el hardcode és funcional.

---

## G2 — Whitelist: migrar Excel → SQLite

### Situació actual
`data/whitelist.xlsx` — columna única `Email`. Gestió via ExcelJS.

### Per què SQLite és millor aquí
- Consulta per `academicYear` i `module` → SQLite O(log n), Excel O(n) amb re-lectura
- Suport multi-curs sense fitxers separats
- API `/admin/whitelist` més ràpida (no I/O de disc per cada petició)
- Tancament de curs: `UPDATE whitelist SET canEdit=false WHERE academicYear='2025-26'`

### Pla de migració (V0.5)

**Pas 1 — Nova entitat:**
```typescript
// src/admin/whitelist.model.ts
@Entity('whitelist')
export class WhitelistEntry {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ unique: true })
  email!: string;

  @Column({ nullable: true })
  academicYear?: string;    // "2025-26", "2026-27"

  @Column({ nullable: true })
  module?: string;          // "MME", "SOX"

  @Column({ default: true })
  isActive!: boolean;

  @Column({ default: true })
  canEdit!: boolean;        // false = mode consulta (curs tancat)

  @Column({ nullable: true })
  approvedBy?: string;

  @Column()
  approvedAt!: string;
}
```

**Pas 2 — Script de migració (una sola vegada):**
```javascript
// scripts/migrate-whitelist.js
const ExcelJS = require('exceljs');
const Database = require('better-sqlite3');

const wb = new ExcelJS.Workbook();
await wb.xlsx.readFile('./data/whitelist.xlsx');
const ws = wb.getWorksheet(1);
const db = new Database('./database.sqlite');

ws.eachRow((row, i) => {
  if (i === 1) return; // skip header
  const email = row.getCell(1).value;
  if (email) db.prepare(
    'INSERT OR IGNORE INTO whitelist (email, isActive, canEdit, approvedAt) VALUES (?,1,1,?)'
  ).run(email, new Date().toISOString());
});
```

**Pas 3 — Nous endpoints admin:**
```
GET  /admin/whitelist?year=2025-26&module=MME
POST /admin/whitelist/close-year  { academicYear: "2025-26" }
  → UPDATE canEdit=false, isActive=false WHERE academicYear='2025-26'
```

**D6 — Curs tancat: alliberament automàtic de recursos**
Quan `POST /admin/whitelist/close-year`:
```typescript
// 1. Marcar whitelist com canEdit=false
// 2. Buscar tots els usuaris del curs
// 3. Alliberar tots els recursos assignats a ells
// 4. Registrar historial per cada alliberament
```

---

## G4 — History model: ampliació

### Pla (addint columnes nullable — retrocompatible)

```typescript
// src/history/history.model.ts  (afegir camps)
@Column({ nullable: true })
activityId?: string;        // "UD01_ACT01"

@Column({ nullable: true })
oldValue?: string;          // valor anterior (JSON stringified)

@Column({ nullable: true })
newValue?: string;          // valor nou (JSON stringified)

@Column({ nullable: true })
notes?: string;             // anotació manual

@Column({ nullable: true })
createdBy?: string;         // email de qui va fer l'acció

@Column({ nullable: true, type: 'simple-json' })
metadata?: object;          // IP, navegador, etc.
```

**Perquè SQLite ho suporta sense migració destructiva:**
TypeORM amb `synchronize: true` afegeix columnes noves automàticament.
Les files existents tindran `null` als nous camps — acceptable.

---

## G5 — user_activity_progress: pla V0.5

### Objectiu
Permetre que cada alumne tingui el seu propi estat per a cada activitat UD.

### Model nou

```typescript
// src/ud-activities/user-activity-progress.model.ts
@Entity('user_activity_progress')
export class UserActivityProgress {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column()
  userId!: number;

  @Column()
  activityId!: number;        // FK a ud_activities.id

  @Column({ default: 'pending' })
  status!: 'pending' | 'in_progress' | 'submitted' | 'validated' | 'returned';

  @Column({ default: 0 })
  progressPercent!: number;

  @Column({ nullable: true, type: 'simple-json' })
  completedSteps?: string[];

  @Column({ nullable: true, type: 'simple-json' })
  completedCheckmarks?: string[];

  @Column({ nullable: true })
  grade?: number;             // null fins que l'admin valida

  @Column({ nullable: true })
  submittedAt?: string;

  @Column({ nullable: true })
  validatedBy?: string;       // email de l'admin/BIP

  @Column({ nullable: true })
  returnedReason?: string;

  @Column({ nullable: true, type: 'simple-json' })
  resourcesUsed?: number[];   // IDs de recursos

  @Column()
  createdAt!: string;

  @Column()
  updatedAt!: string;
}
```

### Endpoints (nous)
```
GET  /ud-activities/:id/progress          → tots els alumnes (Admin/BIP)
GET  /ud-activities/:id/progress/me       → progrés propi (tots)
POST /ud-activities/:id/progress          → crear/iniciar (alumne)
PATCH /ud-activities/:id/progress/me      → actualitzar passos/checkmarks
POST /ud-activities/:id/progress/submit   → entregar (alumne)
POST /ud-activities/:id/progress/validate → validar (Admin/BIP)
POST /ud-activities/:id/progress/return   → retornar amb motiu (Admin/BIP)
```

### Accés des de Configuració i Informes (Admin Master)
```
GET /admin/reports/activities?year=2025-26&udCode=UD01
  → Retorna: { totalStudents, submitted, validated, avgGrade, pending }

GET /admin/reports/student/:userId
  → Historial complet d'activitats d'un alumne

GET /history/export/student/:userId   → CSV/PDF
```

---

## D1 — BIP automàtic: implementació V0.5

**Decisió:** Event-driven al moment de validació (no job periòdic).

```typescript
// En validar una activitat:
async validateActivity(activityProgressId, adminEmail) {
  const progress = await this.repo.findOne(activityProgressId);
  progress.status = 'validated';
  progress.grade = calculatedGrade;
  await this.repo.save(progress);

  // Comprovar upgrade BIP
  const MIN_FOR_BIP = 4;  // ajustable
  const count = await this.repo.count({
    where: { userId: progress.userId, status: 'validated' }
  });
  if (count >= MIN_FOR_BIP) {
    await this.usersService.upgradeRole(progress.userId, 'bip');
    // Notificació in-app
  }
}
```

---

## D2 — Notificacions: decisió arquitectura

**Decisió:** SSE (Server-Sent Events) — més versàtil que React pur, sense
complexitat de WebSockets.

**Per què SSE aquí:**
- Unidireccional servidor→client: perfecte per notificacions
- NestJS té suport natiu (`@Sse()`, `EventEmitter2`)
- No requereix BD (efímer): l'EventEmitter llença l'event i SSE el transmet
- Fallback automàtic: si la connexió es talla, el browser reconnecta sol

```typescript
// src/notifications/notifications.controller.ts
@UseGuards(JwtAuthGuard)
@Sse('stream')
stream(@Req() req): Observable<MessageEvent> {
  return this.notificationsService.getStream(req.user.userId);
}

// Frontend:
const es = new EventSource('/api/notifications/stream', {
  headers: { Authorization: `Bearer ${token}` }
});
es.onmessage = (e) => dispatch(addNotification(JSON.parse(e.data)));
```

---

## D3 — QR URL configurable (V0.5)

**Decisió:** Mostrar a la fitxa del recurs, inactive per ara.

```typescript
// resource.model.ts — ja té qrCode: string
// En crear recurs, generar URL:
const qrUrl = `${process.env.BASE_URL || 'http://localhost:3000'}/recursos/${resource.id}`;
resource.qrCode = qrUrl;
```

**A afegir al `.env`:**
```
BASE_URL=http://localhost:3000
```

La fitxa (`FichaRecurso.jsx`) ja pot mostrar el camp `qrCode` com a text/link.
La generació visual del QR (imatge) es fa en V0.5 amb `qrcode` npm package.

---

## D5 — Space versions: política de retencions

**Decisió:** Conservar les últimes **10 versions** per sala. Auto-purga les més antigues.

**Impacte SQLite:** 10 versions × ~50KB snapshot × 3 sales = ~1.5MB.
Acceptable per SQLite.

```typescript
// En crear nova versió:
async createVersion(spaceId, snapshot, createdBy, comment) {
  await this.repo.save({ spaceId, snapshot, createdBy, comment, createdAt: ... });
  // Purga versions antigues (conserva les 10 més recents)
  const old = await this.repo.find({
    where: { spaceId },
    order: { id: 'DESC' },
    skip: 10,
  });
  if (old.length) await this.repo.remove(old);
}
```

---

## D7 — resource_assignments: estratègia de migració

**Decisió:** Camp `assignedToUserId` es manté per compatibilitat.
La nova taula `resource_assignments` s'afegeix en paral·lel per a casos avançats
(grup, projecte, activitat).

**Regla:** L'endpoint `/resources/assign` continua escrivint `assignedToUserId`
(compatibilitat) I a més crea un registre a `resource_assignments`.
