export class EntityRegistry {
  constructor() {
    this.entities = new Map();
  }

  create(entity) {
    const id = entity.id ?? crypto.randomUUID?.() ?? `${Date.now()}-${Math.random()}`;
    const record = {
      id,
      type: entity.type,
      energy: entity.energy ?? 0.5,
      integrity: entity.integrity ?? 1.0,
      position: entity.position ?? { x: 0, y: 0 },
      velocity: entity.velocity ?? { x: 0, y: 0 },
      metadata: entity.metadata ?? {},
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    this.entities.set(id, record);
    return record;
  }

  get(id) {
    return this.entities.get(id);
  }

  list(type = null) {
    const all = Array.from(this.entities.values());
    return type ? all.filter(e => e.type === type) : all;
  }

  update(id, patch = {}) {
    const entity = this.entities.get(id);
    if (!entity) return null;

    const next = {
      ...entity,
      ...patch,
      metadata: {
        ...entity.metadata,
        ...(patch.metadata ?? {})
      },
      updatedAt: new Date().toISOString()
    };

    next.energy = Math.max(0, Math.min(1, next.energy));
    next.integrity = Math.max(0, Math.min(1, next.integrity));

    this.entities.set(id, next);
    return next;
  }

  damage(id, amount) {
    const entity = this.entities.get(id);
    if (!entity) return null;
    return this.update(id, { integrity: entity.integrity - amount });
  }

  heal(id, amount) {
    const entity = this.entities.get(id);
    if (!entity) return null;
    return this.update(id, { integrity: entity.integrity + amount });
  }

  boost(id, amount) {
    const entity = this.entities.get(id);
    if (!entity) return null;
    return this.update(id, { energy: entity.energy + amount });
  }

  snapshot() {
    return this.list().map(e => ({ ...e }));
  }
}

export function seedMatrixEntities(registry) {
  return {
    atomCore: registry.create({
      id: "atom-core",
      type: "atom-core",
      energy: 0.72,
      integrity: 1,
      metadata: { role: "impulse-source" }
    }),

    arielShield: registry.create({
      id: "ariel-shield",
      type: "ariel-shield",
      energy: 0.64,
      integrity: 1,
      metadata: { role: "protective-field" }
    }),

    spinRings: registry.create({
      id: "spin-rings",
      type: "spin-rings",
      energy: 0.58,
      integrity: 1,
      metadata: { role: "rotation-field", rings: 8 }
    }),

    waveField: registry.create({
      id: "wave-field",
      type: "wave-field",
      energy: 0.48,
      integrity: 1,
      metadata: { role: "agitation-medium" }
    }),

    pressureField: registry.create({
      id: "pressure-field",
      type: "pressure-field",
      energy: 0.42,
      integrity: 1,
      metadata: { role: "fluderation-medium" }
    })
  };
}
