const canvas = document.getElementById('canvas');
const gl = canvas.getContext('webgl');
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

const vertexShaderSource = `
attribute vec2 position;
void main() {
    gl_Position = vec4(position, 0.0, 1.0);
    gl_PointSize = 3.0;
}
`;

const fragmentShaderSource = `
precision mediump float;
uniform vec4 color;
void main() {
    gl_FragColor = color;
}
`;

function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    return shader;
}

const program = gl.createProgram();
gl.attachShader(program, createShader(gl, gl.VERTEX_SHADER, vertexShaderSource));
gl.attachShader(program, createShader(gl, gl.FRAGMENT_SHADER, fragmentShaderSource));
gl.linkProgram(program);
gl.useProgram(program);

const positionBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

const positionLocation = gl.getAttribLocation(program, "position");
gl.enableVertexAttribArray(positionLocation);
gl.vertexAttribPointer(positionLocation, 2, gl.FLOAT, false, 0, 0);

const colorLocation = gl.getUniformLocation(program, "color");

const particles = [];

function emit(count = 100) {
    for (let i = 0; i < count; i++) {
        particles.push({
            x: Math.random() * 2 - 1,
            y: Math.random() * 2 - 1,
            vx: (Math.random() - 0.5) * 0.05,
            vy: (Math.random() - 0.5) * 0.05,
            life: 100 + Math.random() * 100
        });
    }
}

function animate() {
    gl.clearColor(0, 0, 0, 0.1);
    gl.clear(gl.COLOR_BUFFER_BIT);

    const positions = [];
    for (let i = particles.length - 1; i >= 0; i--) {
        const p = particles[i];
        p.x += p.vx;
        p.y += p.vy;
        p.life--;
        if (p.life > 0) {
            positions.push(p.x, p.y);
        } else {
            particles.splice(i, 1);
        }
    }

    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.DYNAMIC_DRAW);
    gl.uniform4f(colorLocation, 0.0, 1.0, 1.0, 1.0); // Cyan
    gl.drawArrays(gl.POINTS, 0, positions.length / 2);

    if (Math.random() < 0.1) emit(50); // Infiltrator spawn

    requestAnimationFrame(animate);
}

animate();
