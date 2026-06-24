class Particle {
    constructor(x, y, vx, vy, life, color) {
        this.x = x;
        this.y = y;
        this.vx = vx;
        this.vy = vy;
        this.life = life;
        this.alpha = 1;
        this.color = color;
        this.size = 3;
    }

    update(gravity = 0.1) {
        this.vy += gravity;
        this.x += this.vx;
        this.y += this.vy;
        this.life--;
        this.alpha = this.life / 100;
    }

    draw(ctx) {
        ctx.save();
        ctx.globalAlpha = this.alpha;
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
}

class ParticleEngine {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.particles = [];
    }

    emit(x, y, count = 20, vxRange = 4, vyRange = 4, life = 100, color = '#0ff') {
        for (let i = 0; i < count; i++) {
            const vx = (Math.random() - 0.5) * vxRange;
            const vy = (Math.random() - 0.5) * vyRange - 2; // upward bias for slam
            this.particles.push(new Particle(x, y, vx, vy, life, color));
        }
    }

    updateAndDraw() {
        this.ctx.fillStyle = 'rgba(0,0,0,0.1)';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

        for (let i = this.particles.length - 1; i >= 0; i--) {
            const p = this.particles[i];
            p.update(0.05); // low gravity for ethereal feel
            p.draw(this.ctx);
            if (p.life <= 0) this.particles.splice(i, 1);
        }
    }
}

// Integration example
const engine = new ParticleEngine(canvas);
engine.emit(canvas.width / 2, canvas.height / 2, 50, 5, 5, 150, '#f0f'); // Infiltrator slam
