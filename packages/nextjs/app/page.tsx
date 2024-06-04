"use client";

//import Link from "next/link";
import type { NextPage } from "next";

//import { useAccount } from "wagmi";
//import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
//import { Address } from "~~/components/scaffold-eth";


import React, { useEffect, useRef } from 'react';

const Home: NextPage = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    if (!canvasRef.current) return;

    const canvas = canvasRef.current;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    const asteroids: { x: number; y: number; radius: number; vx: number; vy: number; color: string }[] = [];

    const initAsteroids = () => {
      for (let i = 0; i < 300; i++) {
        const x = Math.random() * canvas.width;
        const y = Math.random() * canvas.height;
        const radius = Math.random() * 2 + 1; // Even smaller asteroid radius
        const vx = (Math.random() - 0.5) * 2;
        const vy = (Math.random() - 0.5) * 2;
        const color = `rgb(${Math.random() * 100 + 155}, ${Math.random() * 100 + 155}, ${Math.random() * 100 + 155})`;
        asteroids.push({ x, y, radius, vx, vy, color });
      }
    };

    const drawAsteroids = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      asteroids.forEach((asteroid) => {
        ctx.beginPath();
        ctx.arc(asteroid.x, asteroid.y, asteroid.radius, 0, Math.PI * 2);
        ctx.fillStyle = asteroid.color;
        ctx.fill();

        asteroid.x += asteroid.vx;
        asteroid.y += asteroid.vy;

        if (asteroid.x + asteroid.radius > canvas.width || asteroid.x - asteroid.radius < 0) {
          asteroid.vx = -asteroid.vx;
        }
        if (asteroid.y + asteroid.radius > canvas.height || asteroid.y - asteroid.radius < 0) {
          asteroid.vy = -asteroid.vy;
        }
      });

      requestAnimationFrame(drawAsteroids);
    };

    initAsteroids();
    drawAsteroids();
  }, []);

  return (
    <div className="min-h-screen flex items-center justify-center bg-black">
      <canvas ref={canvasRef} className="absolute" />
      <div className="flex flex-col items-center p-10 bg-black bg-opacity-50 rounded-xl shadow-2xl transform hover:scale-105 transition-transform duration-300 hover:blur-sm hover:grayscale-0 grayscale hover:shadow-2xl">
        <h1 className="text-center text-transparent bg-gradient-to-r from-indigo-400 via-purple-500 to-pink-600 bg-clip-text animate-flicker">
          <span className="block text-2xl mb-2 tracking-wider font-bold animate-bounce">Welcome to</span>
          <span className="block text-8xl font-extrabold">Morphex</span>
        </h1>
        <div className="flex items-center mt-6">
          <div className="w-6 h-6 bg-indigo-400 rounded-full mr-4 animate-pulse"></div>
          <div className="w-6 h-6 bg-purple-500 rounded-full mr-4 animate-pulse delay-75"></div>
          <div className="w-6 h-6 bg-pink-600 rounded-full animate-pulse delay-150"></div>
        </div>
        <div className="mt-8 animate-spin-slow">
          <svg
            className="w-16 h-16 text-white"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <polygon points="12 2 2 9 12 16 22 9 12 2"></polygon>
          </svg>
        </div>
      </div>
    </div>
  );
};

export default Home;
