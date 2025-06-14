import React, { useRef, useEffect } from 'react';

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

export default function App() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current!;
    const ctx = canvas.getContext('2d')!;

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

    const cloud = {
      x: canvas.width / 2,
      y: 100,
      width: 100,
      height: 60,
      speed: 5,
    };

    const plantCount = 6;
    const plants: Plant[] = [];
    const plantWidth = 80;

    for (let i = 0; i < plantCount; i++) {
      plants.push({
        x: i * (plantWidth + 10) + 30,
        y: canvas.height,
        height: 0,
        grown: false,
        petals: Array.from({ length: 5 }, () => getRandomRainbowColor()),
      });
    }

    let rainDrops: RainDrop[] = [];
    let gameWon = false;

    function drawCloud() {
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

    function updateRain() {
      // Move each raindrop down
      rainDrops.forEach((drop) => {
        drop.y += 6; // Adjust speed as needed
      });
      plants.forEach((plant) => {
        if (
          !plant.grown &&
          Math.abs(cloud.x - (plant.x + plantWidth / 2)) < plantWidth / 2
        ) {
          rainDrops.push({
            x: cloud.x + (Math.random() * 60 - 30),
            y: cloud.y + 40,
          });
        }
      });

      rainDrops = rainDrops.filter((drop) => drop.y < canvas.height);
    }

    function update() {
      if (gameWon) {
        return;
      }

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

    function drawRainbow() {
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

    function drawWinScreen() {
      drawRainbow();
      ctx.fillStyle = '#FFD700';
      ctx.font = '48px Arial';
      ctx.fillText('You Win!', canvas.width / 2 - 100, canvas.height / 2);
    }

    function draw() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      drawPlants();
      drawCloud();
      drawRain();

      if (gameWon) {
        drawWinScreen();
      }
    }

    function handleKeyDown(e: KeyboardEvent) {
      if (e.code === 'ArrowLeft') {
        cloud.x -= cloud.speed;
      } else if (e.code === 'ArrowRight') {
        cloud.x += cloud.speed;
      }
      cloud.x = Math.max(
        cloud.width / 2,
        Math.min(canvas.width - cloud.width / 2, cloud.x)
      );
    }

    let requestId: number;
    window.addEventListener('keydown', handleKeyDown);
    function gameLoop() {
      updateRain();
      update();
      draw();
      requestId = requestAnimationFrame(gameLoop);
    }
    gameLoop();

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      cancelAnimationFrame(requestId);
    };
  }, []);

  return (
    <>
      <canvas ref={canvasRef} width={600} height={800} />
    </>
  );
}
