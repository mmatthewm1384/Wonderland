import "./style.css";

const app = document.querySelector("#app");

app.innerHTML = `
  <section class="shell">
    <header class="topbar">
      <div>
        <p class="eyebrow">Wonderland Matrix</p>
        <h1>Fluderation</h1>
      </div>
      <div id="status" class="status active">LOCAL VISUAL</div>
    </header>

    <section class="panel">
      <label>Watch Path</label>
      <input id="watchPath" value="$HOME/Wonderland" />
      <div class="actions">
        <button id="start">Start Visual Stream</button>
        <button id="test">Add Test Event</button>
        <button id="clear">Clear</button>
      </div>
    </section>

    <section class="grid">
      <article class="card">
        <span class="metric-label">Events</span>
        <strong id="eventCount">0</strong>
      </article>
      <article class="card">
        <span class="metric-label">Mode</span>
        <strong>Local</strong>
      </article>
      <article class="card">
        <span class="metric-label">Target</span>
        <strong>Tauri</strong>
      </article>
    </section>

    <section class="events">
      <h2>Event Stream</h2>
      <ol id="events"></ol>
    </section>
  </section>
`;

const events = document.querySelector("#events");
const eventCount = document.querySelector("#eventCount");
const status = document.querySelector("#status");

let count = 0;
let timer = null;

function addEvent(kind, path) {
  count += 1;
  eventCount.textContent = String(count);

  const item = document.createElement("li");
  item.innerHTML = `
    <span class="time">${new Date().toLocaleTimeString()}</span>
    <span class="kind">${kind}</span>
    <span class="path">${path}</span>
  `;

  events.prepend(item);
}

document.querySelector("#start").addEventListener("click", () => {
  status.textContent = "ACTIVE";
  status.className = "status active";

  if (timer) clearInterval(timer);

  timer = setInterval(() => {
    addEvent("VISUAL_HEARTBEAT", document.querySelector("#watchPath").value);
  }, 2500);
});

document.querySelector("#test").addEventListener("click", () => {
  addEvent("MATRIX_FLUDERATION_TEST", document.querySelector("#watchPath").value + "/.fluderation-visual-test");
});

document.querySelector("#clear").addEventListener("click", () => {
  count = 0;
  eventCount.textContent = "0";
  events.innerHTML = "";
});

addEvent("BOOT", "Matrix Fluderation local visual mode loaded");
