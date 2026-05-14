import { useEffect, useRef, useState } from "react";

type GameStatus = "ready" | "playing" | "ended";

type Unicorn = {
  x: number;
  y: number;
  velocity: number;
  rotation: number;
};

type Gate = {
  x: number;
  gapY: number;
  scored: boolean;
};

type Sparkle = {
  x: number;
  y: number;
  size: number;
  speed: number;
  phase: number;
};

type GameState = {
  unicorn: Unicorn;
  gates: Gate[];
  sparkles: Sparkle[];
  score: number;
  highScore: number;
  status: GameStatus;
  backgroundX: number;
  lastGateX: number;
};

const canvasWidth = 900;
const canvasHeight = 600;
const unicornWidth = 108;
const unicornHeight = 74;
const gravity = 0.08;
const flapVelocity = -4.2;
const gateWidth = 86;
const gateGap = 280;
const gateSpacing = 470;
const gateSpeed = 1.65;
const groundHeight = 58;
const assetBasePath = import.meta.env.BASE_URL;
const skyImagePath = `${assetBasePath}assets/sky-background.jpg`;
const unicornImagePath = `${assetBasePath}assets/unicorn.png`;
const highScoreKey = "vanessas-unicorn-game-high-score";
const rainbowStops = ["#ff4f86", "#ff9f1c", "#ffe45e", "#58d95b", "#43b5ff", "#8d6bff"];

function createGate(x: number): Gate {
  return {
    x,
    gapY: 150 + Math.random() * 210,
    scored: false,
  };
}

function createSparkle(): Sparkle {
  return {
    x: Math.random() * canvasWidth,
    y: 40 + Math.random() * (canvasHeight - groundHeight - 80),
    size: 1 + Math.random() * 2.8,
    speed: 0.4 + Math.random() * 0.9,
    phase: Math.random() * Math.PI * 2,
  };
}

function getStoredHighScore(): number {
  const storedScore = window.localStorage.getItem(highScoreKey);
  return storedScore ? Number(storedScore) || 0 : 0;
}

function makeInitialState(highScore = 0): GameState {
  return {
    unicorn: {
      x: 170,
      y: canvasHeight / 2 - unicornHeight / 2,
      velocity: 0,
      rotation: 0,
    },
    gates: [createGate(760), createGate(760 + gateSpacing), createGate(760 + gateSpacing * 2)],
    sparkles: Array.from({ length: 38 }, createSparkle),
    score: 0,
    highScore,
    status: "ready",
    backgroundX: 0,
    lastGateX: 760 + gateSpacing * 2,
  };
}

function loadImage(src: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.addEventListener("load", () => resolve(image), { once: true });
    image.addEventListener("error", () => reject(new Error(`Unable to load image: ${src}`)), {
      once: true,
    });
    image.src = src;
  });
}

function drawRoundedRect(
  ctx: CanvasRenderingContext2D,
  x: number,
  y: number,
  width: number,
  height: number,
  radius: number,
) {
  ctx.beginPath();
  ctx.roundRect(x, y, width, height, radius);
  ctx.fill();
  ctx.stroke();
}

function intersectsGate(unicorn: Unicorn, gate: Gate): boolean {
  const hitbox = {
    x: unicorn.x + 18,
    y: unicorn.y + 14,
    width: unicornWidth - 34,
    height: unicornHeight - 26,
  };
  const gateLeft = gate.x;
  const gateRight = gate.x + gateWidth;
  const gapTop = gate.gapY;
  const gapBottom = gate.gapY + gateGap;

  if (hitbox.x + hitbox.width < gateLeft || hitbox.x > gateRight) {
    return false;
  }

  return hitbox.y < gapTop || hitbox.y + hitbox.height > gapBottom;
}

export default function App() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const stateRef = useRef<GameState | null>(null);
  const imagesRef = useRef<{
    background: HTMLImageElement | null;
    unicorn: CanvasImageSource | null;
  }>({ background: null, unicorn: null });
  const [status, setStatus] = useState<GameStatus>("ready");
  const [score, setScore] = useState(0);
  const [highScore, setHighScore] = useState(0);

  function syncOverlay(state: GameState) {
    setStatus(state.status);
    setScore(state.score);
    setHighScore(state.highScore);
  }

  function resetGame(nextStatus: GameStatus) {
    const nextHighScore = Math.max(stateRef.current?.highScore ?? 0, getStoredHighScore());
    const nextState = makeInitialState(nextHighScore);
    nextState.status = nextStatus;
    if (nextStatus === "playing") {
      nextState.unicorn.velocity = flapVelocity;
    }
    stateRef.current = nextState;
    syncOverlay(nextState);
  }

  function flap() {
    const state = stateRef.current;
    if (!state) return;

    if (state.status === "ended") {
      resetGame("playing");
      return;
    }

    if (state.status === "ready") {
      state.status = "playing";
    }

    state.unicorn.velocity = flapVelocity;
    syncOverlay(state);
  }

  function handlePointerFlap(event: React.PointerEvent<HTMLElement>) {
    event.preventDefault();
    flap();
  }

  useEffect(() => {
    stateRef.current = makeInitialState(getStoredHighScore());
    syncOverlay(stateRef.current);

    let isMounted = true;
    Promise.all([loadImage(skyImagePath), loadImage(unicornImagePath)])
      .then(([background, unicorn]) => {
        if (!isMounted) return;
        imagesRef.current = {
          background,
          unicorn,
        };
      })
      .catch(() => {
        imagesRef.current = {
          background: null,
          unicorn: null,
        };
      });

    return () => {
      isMounted = false;
    };
  }, []);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return undefined;

    const context = canvas.getContext("2d");
    if (!context) return undefined;
    const ctx = context;

    let animationFrame = 0;

    function drawBackground(state: GameState) {
      const background = imagesRef.current.background;
      const offset = state.backgroundX % canvasWidth;

      if (background) {
        ctx.drawImage(background, -offset, 0, canvasWidth, canvasHeight);
        ctx.drawImage(background, canvasWidth - offset, 0, canvasWidth, canvasHeight);
      } else {
        const skyGradient = ctx.createLinearGradient(0, 0, 0, canvasHeight);
        skyGradient.addColorStop(0, "#58cfff");
        skyGradient.addColorStop(0.62, "#b9f1ff");
        skyGradient.addColorStop(1, "#f5d8ff");
        ctx.fillStyle = skyGradient;
        ctx.fillRect(0, 0, canvasWidth, canvasHeight);
      }

      state.sparkles.forEach((sparkle) => {
        const twinkle = 0.45 + Math.sin(Date.now() / 280 + sparkle.phase) * 0.35;
        ctx.globalAlpha = Math.max(0.12, twinkle);
        ctx.fillStyle = "#ffffff";
        ctx.beginPath();
        ctx.arc(sparkle.x, sparkle.y, sparkle.size, 0, Math.PI * 2);
        ctx.fill();
      });
      ctx.globalAlpha = 1;

      ctx.fillStyle = "rgba(255, 255, 255, 0.56)";
      ctx.fillRect(0, canvasHeight - groundHeight, canvasWidth, groundHeight);
    }

    function drawGate(gate: Gate) {
      const topHeight = gate.gapY;
      const bottomY = gate.gapY + gateGap;
      const bottomHeight = canvasHeight - groundHeight - bottomY;

      rainbowStops.forEach((color, index) => {
        const stripeWidth = gateWidth / rainbowStops.length;
        ctx.fillStyle = color;
        ctx.strokeStyle = "rgba(255, 255, 255, 0.72)";
        ctx.lineWidth = 2;
        drawRoundedRect(
          ctx,
          gate.x + stripeWidth * index,
          -16,
          stripeWidth + 1,
          topHeight + 16,
          10,
        );
        drawRoundedRect(
          ctx,
          gate.x + stripeWidth * index,
          bottomY,
          stripeWidth + 1,
          bottomHeight + 18,
          10,
        );
      });

      ctx.fillStyle = "#fff8c9";
      ctx.strokeStyle = "#9f72ff";
      ctx.lineWidth = 4;
      drawRoundedRect(ctx, gate.x - 10, gate.gapY - 18, gateWidth + 20, 18, 8);
      drawRoundedRect(ctx, gate.x - 10, bottomY, gateWidth + 20, 18, 8);
    }

    function drawUnicorn(state: GameState) {
      const { unicorn } = state;
      ctx.save();
      ctx.translate(unicorn.x + unicornWidth / 2, unicorn.y + unicornHeight / 2);
      ctx.rotate(unicorn.rotation);

      const unicornImage = imagesRef.current.unicorn;
      if (unicornImage) {
        ctx.drawImage(
          unicornImage,
          -unicornWidth / 2,
          -unicornHeight / 2,
          unicornWidth,
          unicornHeight,
        );
      } else {
        ctx.fillStyle = "#fff7fb";
        ctx.strokeStyle = "#8d6bff";
        ctx.lineWidth = 3;
        ctx.beginPath();
        ctx.ellipse(0, 4, 42, 24, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        ctx.fillStyle = "#ff68a7";
        ctx.fillRect(-44, -4, 20, 8);
        ctx.fillStyle = "#ffd166";
        ctx.beginPath();
        ctx.moveTo(38, -22);
        ctx.lineTo(56, -34);
        ctx.lineTo(47, -12);
        ctx.fill();
      }

      ctx.restore();
    }

    function drawScore(state: GameState) {
      ctx.fillStyle = "#ffffff";
      ctx.strokeStyle = "rgba(89, 64, 141, 0.72)";
      ctx.lineWidth = 8;
      ctx.font = "700 58px Inter, Arial, sans-serif";
      ctx.textAlign = "center";
      ctx.strokeText(String(state.score), canvasWidth / 2, 86);
      ctx.fillText(String(state.score), canvasWidth / 2, 86);
    }

    function endGame(state: GameState) {
      state.status = "ended";
      state.highScore = Math.max(state.highScore, state.score);
      window.localStorage.setItem(highScoreKey, String(state.highScore));
      syncOverlay(state);
    }

    function update(state: GameState) {
      state.backgroundX += state.status === "playing" ? 0.34 : 0.24;
      state.sparkles.forEach((sparkle) => {
        sparkle.x -= sparkle.speed;
        if (sparkle.x < -6) {
          sparkle.x = canvasWidth + Math.random() * 80;
          sparkle.y = 40 + Math.random() * (canvasHeight - groundHeight - 80);
        }
      });

      if (state.status !== "playing") {
        state.unicorn.y = canvasHeight / 2 - unicornHeight / 2 + Math.sin(Date.now() / 360) * 9;
        state.unicorn.rotation = Math.sin(Date.now() / 460) * 0.08;
        return;
      }

      state.unicorn.velocity += gravity;
      state.unicorn.y += state.unicorn.velocity;
      state.unicorn.y = Math.max(state.unicorn.y, -unicornHeight);
      state.unicorn.rotation = Math.max(-0.45, Math.min(0.72, state.unicorn.velocity / 14));
      state.gates.forEach((gate) => {
        gate.x -= gateSpeed;
      });

      const firstGate = state.gates[0];
      if (firstGate && firstGate.x + gateWidth < -20) {
        state.gates.shift();
        state.lastGateX += gateSpacing;
        state.gates.push(createGate(state.lastGateX));
      }

      state.gates.forEach((gate) => {
        if (!gate.scored && gate.x + gateWidth < state.unicorn.x) {
          gate.scored = true;
          state.score += 1;
          syncOverlay(state);
        }
      });

      const hitGate = state.gates.some((gate) => intersectsGate(state.unicorn, gate));
      const visualBottom = state.unicorn.y + unicornHeight - 16;
      const hitBounds = visualBottom > canvasHeight - groundHeight + 36;
      if (hitGate || hitBounds) {
        endGame(state);
      }
    }

    function render() {
      const state = stateRef.current;
      if (!state) return;

      update(state);
      ctx.clearRect(0, 0, canvasWidth, canvasHeight);
      drawBackground(state);
      state.gates.forEach(drawGate);
      drawUnicorn(state);
      drawScore(state);

      animationFrame = requestAnimationFrame(render);
    }

    render();

    return () => {
      cancelAnimationFrame(animationFrame);
    };
  }, []);

  useEffect(() => {
    function handleKeyDown(event: KeyboardEvent) {
      if (event.code === "Space" || event.code === "ArrowUp") {
        event.preventDefault();
        flap();
      }

      if (event.code === "Enter" && stateRef.current?.status !== "playing") {
        event.preventDefault();
        resetGame("playing");
      }
    }

    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  const showStart = status === "ready";
  const showEnded = status === "ended";

  return (
    <div className="game-shell">
      <canvas
        ref={canvasRef}
        aria-label="Vanessa's Unicorn Game"
        className="game-canvas"
        width={canvasWidth}
        height={canvasHeight}
        onPointerDown={handlePointerFlap}
      />
      <div className="hud" aria-live="polite">
        <span>Score {score}</span>
        <span>Best {highScore}</span>
      </div>
      {(showStart || showEnded) && (
        <div className="title-screen">
          <div className="title-panel">
            <img className="title-unicorn" src={unicornImagePath} alt="" draggable={false} />
            <h1>Vanessa's Unicorn Game</h1>
            <p>
              {showStart
                ? "Tap, click, or press space to fly through the rainbow gates."
                : `Score ${score}`}
            </p>
            <button type="button" onClick={() => resetGame("playing")}>
              {showStart ? "Start" : "Play Again"}
            </button>
          </div>
        </div>
      )}
      <button
        className="flap-button"
        type="button"
        onPointerDown={handlePointerFlap}
        aria-label="Flap"
      >
        Flap
      </button>
    </div>
  );
}
