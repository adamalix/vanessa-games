import React, { useRef, useEffect, useState } from 'react';

type Plant = {
  x: number;
  y: number;
  height: number;
  grown: boolean;
  petals: string[];
};

type RainDrop = {
  x: number;
  y: number;
};

// Define a type for the cloud object
type Cloud = {
  x: number;
  y: number;
  width: number;
  height: number;
  speed: number;
};

export default function App() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  // Add state for cloud position to allow touch controls to update UI
  const [cloudX, setCloudX] = useState<number | null>(null);

  // MoveCloud functions must be defined here so they are in scope for both JSX and useEffect
  function moveCloudLeft() {
    setCloudX((prev) => {
      const canvas = canvasRef.current;
      if (!canvas) return prev;
      const cloudWidth = 100;
      const speed = 10;
      const newX = (prev !== null ? prev : canvas.width / 2) - speed;
      return Math.max(
        cloudWidth / 2,
        Math.min(canvas.width - cloudWidth / 2, newX)
      );
    });
  }
  function moveCloudRight() {
    setCloudX((prev) => {
      const canvas = canvasRef.current;
      if (!canvas) return prev;
      const cloudWidth = 100;
      const speed = 10;
      const newX = (prev !== null ? prev : canvas.width / 2) + speed;
      return Math.max(
        cloudWidth / 2,
        Math.min(canvas.width - cloudWidth / 2, newX)
      );
    });
  }

  // Helper must be defined before plantsRef
  function getRandomRainbowColor(): string {
    const colors = [
      '#FF0000',
      '#FF7F00',
      '#FFFF00',
      '#00FF00',
      '#0000FF',
      '#4B0082',
      '#8B00FF',
    ];
    return colors[Math.floor(Math.random() * colors.length)];
  }
  // Persist plants across renders and effect runs
  const plantCount = 6;
  const plantWidth = 80;
  // Only initialize once
  const plantsRef = useRef<Plant[]>(
    Array.from({ length: plantCount }, (_, i) => ({
      x: i * (plantWidth + 10) + 30,
      y: 800, // canvas height
      height: 0,
      grown: false,
      petals: Array.from({ length: 5 }, () => getRandomRainbowColor()),
    }))
  );
  const plants = plantsRef.current;

  // Use a ref for cloud position for animation, but keep setCloudX for UI updates
  const cloudXRef = useRef<number>(null);
  // Sync cloudXRef with cloudX when it changes
  useEffect(() => {
    cloudXRef.current = cloudX;
  }, [cloudX]);

  useEffect(() => {
    const canvas = canvasRef.current!;
    const ctx = canvas.getContext('2d')!;

    let rainDrops: RainDrop[] = [];
    let gameWon = false;

    // Helper to get latest cloud object
    function getCloud(): Cloud {
      return {
        x: cloudXRef.current !== null ? cloudXRef.current : canvas.width / 2,
        y: 100,
        width: 100,
        height: 60,
        speed: 5,
      };
    }

    function drawCloud(cloud: Cloud) {
      ctx.beginPath();
      ctx.arc(cloud.x, cloud.y, 30, Math.PI, 2 * Math.PI);
      ctx.arc(cloud.x - 30, cloud.y + 10, 30, Math.PI, 2 * Math.PI);
      ctx.arc(cloud.x + 30, cloud.y + 10, 30, Math.PI, 2 * Math.PI);
      ctx.fillStyle = 'white';
      ctx.fill();
      ctx.closePath();

      ctx.beginPath();
      ctx.arc(cloud.x - 15, cloud.y + 5, 5, 0, 2 * Math.PI);
      ctx.arc(cloud.x + 15, cloud.y + 5, 5, 0, 2 * Math.PI);
      ctx.fillStyle = 'black';
      ctx.fill();
      ctx.closePath();

      ctx.beginPath();
      ctx.arc(cloud.x, cloud.y + 15, 10, 0, Math.PI);
      ctx.strokeStyle = 'black';
      ctx.lineWidth = 2;
      ctx.stroke();
      ctx.closePath();
    }

    // Fix: move updateRain, update, draw, etc. to top-level of useEffect so they are in scope for gameLoop
    function updateRain(cloud: Cloud) {
      rainDrops.forEach((drop) => {
        drop.y += 6;
      });
      rainDrops.push({
        x: cloud.x + (Math.random() * 60 - 30),
        y: cloud.y + 40,
      });
      rainDrops = rainDrops.filter((drop) => drop.y < canvas.height);
    }
    function update(cloud: Cloud) {
      if (gameWon) return;
      plants.forEach((plant) => {
        if (
          !plant.grown &&
          Math.abs(cloud.x - (plant.x + plantWidth / 2)) < plantWidth / 2
        ) {
          plant.height += 1;
          if (plant.y - plant.height <= cloud.y + cloud.height / 2) {
            plant.height = plant.y - cloud.y - cloud.height / 2;
            plant.grown = true;
          }
        }
      });
      if (plants.every((p) => p.grown)) {
        gameWon = true;
      }
    }
    function drawPlants() {
      plants.forEach((plant) => {
        ctx.beginPath();
        ctx.moveTo(plant.x + plantWidth / 2, plant.y);
        ctx.lineTo(plant.x + plantWidth / 2, plant.y - plant.height);
        ctx.strokeStyle = '#228B22';
        ctx.lineWidth = 4;
        ctx.stroke();
        ctx.closePath();

        if (plant.height > 0) {
          const centerX = plant.x + plantWidth / 2;
          const centerY = plant.y - plant.height;
          plant.petals.forEach((color, index) => {
            const angle = (index / plant.petals.length) * 2 * Math.PI;
            const petalX = centerX + Math.cos(angle) * 10;
            const petalY = centerY + Math.sin(angle) * 10;
            ctx.beginPath();
            ctx.arc(petalX, petalY, 6, 0, 2 * Math.PI);
            ctx.fillStyle = color;
            ctx.fill();
            ctx.closePath();
          });
          ctx.beginPath();
          ctx.arc(centerX, centerY, 5, 0, 2 * Math.PI);
          ctx.fillStyle = 'yellow';
          ctx.fill();
          ctx.closePath();
        }
      });
    }

    function drawRain() {
      ctx.fillStyle = '#00BFFF';
      rainDrops.forEach((drop) => {
        ctx.beginPath();
        ctx.arc(drop.x, drop.y, 3, 0, 2 * Math.PI);
        ctx.fill();
        ctx.closePath();
      });
    }

    function drawRainbow(cloud: Cloud) {
      const rainbowColors = [
        '#FF0000',
        '#FF7F00',
        '#FFFF00',
        '#00FF00',
        '#0000FF',
        '#4B0082',
        '#8B00FF',
      ];
      const centerX = canvas.width / 2;
      const centerY = cloud.y + 50;
      const radius = 200;

      rainbowColors.forEach((color, i) => {
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius - i * 10, Math.PI, 2 * Math.PI);
        ctx.strokeStyle = color;
        ctx.lineWidth = 10;
        ctx.stroke();
        ctx.closePath();
      });
    }

    function drawWinScreen(cloud: Cloud) {
      drawRainbow(cloud);
      ctx.fillStyle = '#FFD700';
      ctx.font = '48px Arial';
      ctx.fillText('You Win!', canvas.width / 2 - 100, canvas.height / 2);
    }

    function draw(cloud: Cloud) {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      drawPlants();
      drawCloud(cloud);
      drawRain();

      if (gameWon) {
        drawWinScreen(cloud);
      }
    }

    // Fix handleKeyDown to use getCloud() for cloud values
    function handleKeyDown(e: KeyboardEvent) {
      const cloud = getCloud();
      let newX = cloud.x;
      if (e.code === 'ArrowLeft') {
        newX -= cloud.speed;
      } else if (e.code === 'ArrowRight') {
        newX += cloud.speed;
      }
      newX = Math.max(
        cloud.width / 2,
        Math.min(canvas.width - cloud.width / 2, newX)
      );
      setCloudX(newX);
    }

    // Touch gesture support (must be defined here for useEffect)
    let touchStartX: number | null = null;
    function handleTouchStart(e: TouchEvent) {
      touchStartX = e.touches[0].clientX;
    }
    function handleTouchEnd(e: TouchEvent) {
      if (touchStartX === null) return;
      const touchEndX = e.changedTouches[0].clientX;
      const dx = touchEndX - touchStartX;
      if (Math.abs(dx) > 30) {
        if (dx < 0) moveCloudLeft();
        else moveCloudRight();
      }
      touchStartX = null;
    }

    // Add touch controls
    canvas.addEventListener('touchstart', handleTouchStart);
    canvas.addEventListener('touchend', handleTouchEnd);

    let requestId: number;
    window.addEventListener('keydown', handleKeyDown);
    function gameLoop() {
      const cloud = getCloud();
      updateRain(cloud);
      update(cloud);
      draw(cloud);
      requestId = requestAnimationFrame(gameLoop);
    }
    gameLoop();

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      canvas.removeEventListener('touchstart', handleTouchStart);
      canvas.removeEventListener('touchend', handleTouchEnd);
      cancelAnimationFrame(requestId);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps -- plants is a ref, safe to omit
  }, []); // Only run once on mount

  // Overlay touch buttons
  return (
    <div
      style={{
        position: 'relative',
        width: 600,
        height: 800,
        margin: '0 auto',
      }}
    >
      <canvas ref={canvasRef} width={600} height={800} />
      <button
        aria-label="Move Left"
        style={{
          position: 'absolute',
          left: 10,
          bottom: 30,
          width: 60,
          height: 60,
          borderRadius: '50%',
          opacity: 0.5,
          fontSize: 32,
          zIndex: 2,
        }}
        onTouchStart={moveCloudLeft}
        onMouseDown={moveCloudLeft}
      >
        ◀️
      </button>
      <button
        aria-label="Move Right"
        style={{
          position: 'absolute',
          right: 10,
          bottom: 30,
          width: 60,
          height: 60,
          borderRadius: '50%',
          opacity: 0.5,
          fontSize: 32,
          zIndex: 2,
        }}
        onTouchStart={moveCloudRight}
        onMouseDown={moveCloudRight}
      >
        ▶️
      </button>
    </div>
  );
}
