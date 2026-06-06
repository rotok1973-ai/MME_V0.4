# ESTRUCTURA 3D FINAL

## Definiciones de posición

### Mesa (centro de sala)
- Posición: (0, 0.5, 0)
- Dimensiones: ancho 1.5, alto 1.0, profundo 1.0

### Usuarios (perímetro fijo)
- 12 posiciones fijas
- Distancia desde centro mesa: 1.2 unidades
- Altura Y: 1.25

### PCs (sobre mesa)
- 6 posiciones fijas en grid 2x3
- Altura Y: 1.06

### Estanterías (esquinas)
- 4 posiciones fijas: (-2.2, -2.0), (2.2, -2.0), (-2.2, 2.0), (2.2, 2.0)
- Altura Y: 0.6

### Cubos actividades
- Posiciones dinámicas (sin límite)
- Tamaño: 0.5
- Altura Y: 0.25

### Pirámides proyectos
- Posiciones dinámicas (sin límite)
- Radio: 0.35, Altura: 0.5
- Altura Y: 0.25

## Colores por tipo
| Tipo | Color relleno | Color borde | Opacidad | Wireframe |
|------|---------------|-------------|----------|-----------|
| Mesa | #ff8a1f | #ffaa44 | 0.15 | true |
| Usuario | #00d4ff | #88ddff | 0.5 | false |
| PC | #00ff88 | #88ffaa | 0.7 | false |
| Estantería | #4dabff | #7ac4ff | 0.3 | true |
| Cubo actividad | #ffaa44 | #ffcc66 | 0.7 | false |
| Pirámide proyecto | #00d4ff | #88ddff | 0.7 | false |