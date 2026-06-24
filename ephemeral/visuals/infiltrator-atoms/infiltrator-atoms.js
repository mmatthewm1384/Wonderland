const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

class InfiltratorAtom {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.size = Math.random() * 4 + 1;
        this.speed = Math.random() * 2 + 0.5;
        this.angle = Math.random() * Math.PI * 2;
        this.alpha = 0;
        this.collected = 0;
        this.lifespan = 300 + Math.random() * 200;
    }

    update() {
        this.alpha = Math.min(this.alpha + 0.05, 1);
        this.x += Math.cos(this.angle) * this.speed;
        this.y += Math.sin(this.angle) * this.speed;
        this.lifespan--;
        if (this.lifespan <= 0) this.alpha -= 0.05;
    }

    draw() {
        ctx.save();
        ctx.globalAlpha = this.alpha;
        ctx.fillStyle = `hsl(${this.collected * 30}, 100%, 70%)`;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
        ctx.restore();
    }
}

const atoms = [];

function animate() {
    ctx.fillStyle = 'rgba(0,0,0,0.1)';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    if (Math.random() < 0.3) {
        atoms.push(new InfiltratorAtom(Math.random() * canvas.width, Math.random() * canvas.height));
    }

    for (let i = atoms.length - 1; i >= 0; i--) {
        const atom = atoms[i];
        atom.update();
        atom.draw();
        if (atom.alpha <= 0) atoms.splice(i, 1);
    }

    requestAnimationFrame(animate);
}

animate();
