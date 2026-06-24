export class EventBus {
  constructor() {
    this.handlers = new Map();
    this.history = [];
  }

  on(type, handler) {
    if (!this.handlers.has(type)) this.handlers.set(type, []);
    this.handlers.get(type).push(handler);
  }

  emit(type, payload = {}) {
    const event = {
      id: crypto.randomUUID?.() ?? `${Date.now()}-${Math.random()}`,
      type,
      payload,
      ts: new Date().toISOString()
    };

    this.history.push(event);

    for (const handler of this.handlers.get(type) || []) {
      handler(event);
    }

    for (const handler of this.handlers.get("*") || []) {
      handler(event);
    }

    return event;
  }
}
