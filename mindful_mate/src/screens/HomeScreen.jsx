import React from "react";
import { Line } from "react-chartjs-2";
import {
  Chart as ChartJS,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Tooltip,
  Legend,
} from "chart.js";
import { Card, CardContent } from "../components/card";
import { Button } from "../components/button";

// Register chart.js components
ChartJS.register(
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Tooltip,
  Legend
);

const moodData = {
  labels: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Mon"],
  datasets: [
    {
      label: "Mood Tracker",
      data: [3, 5, 4, 5, 2, 3, 4, 5, 4],
      borderColor: "#A855F7",
      tension: 0.4,
      fill: false,
    },
  ],
};

const moodOptions = {
  responsive: true,
  maintainAspectRatio: false,
  scales: {
    y: {
      beginAtZero: true,
    },
  },
};

// Different emojis for moods
const moodEmojis = ["😞", "😐", "🙂", "😄", "🤩"];

const HomeScreen = () => {
  return (
    <div className="min-h-screen w-screen bg-purple-100 text-gray-800 p-4">
      <nav className="flex justify-between items-center p-4 bg-purple-300 rounded-xl shadow-md mb-6">
        <div className="flex space-x-4">
          {["Home", "Chat", "Mood Tracker", "Songs", "Quotes"].map((item) => (
            <Button
              key={item}
              variant="ghost"
              className="rounded-full px-4 py-2 !bg-purple-600 text-white hover:bg-purple-700 transition-colors"
            >
              {item}
            </Button>
          ))}
        </div>
        <Button className="!bg-purple-500 text-white px-4 py-2 rounded-full">
          Sign in
        </Button>
      </nav>

      <div className="bg-purple-200 p-6 rounded-3xl shadow-md">
        <h1 className="text-2xl font-semibold mb-4">Hi, How are You?</h1>

        <Card className="bg-white mb-6 h-[300px]">
          <CardContent>
            <h2 className="text-lg font-semibold mb-2 ">Mood Tracker</h2>
            <div className="h-[220px]">
              {" "}
              {/* Set your desired chart height */}
              <Line data={moodData} options={moodOptions} />
            </div>
          </CardContent>
        </Card>

        <h2 className="text-lg font-semibold mb-4">How are you Feeling?</h2>
        <div className="flex justify-between mb-6">
          {moodEmojis.map((emoji, i) => (
            <div
              key={i}
              className="bg-purple-300 p-4 rounded-xl shadow hover:scale-105 transition-transform cursor-pointer"
            >
              <span className="text-3xl">{emoji}</span>
            </div>
          ))}
        </div>

        <div className="grid grid-cols-3 gap-4">
          <Card className="text-center p-6 bg-purple-300">
            <CardContent>
              <span className="text-2xl">✔️</span>
              <p className="mt-2">Chat with Mate</p>
            </CardContent>
          </Card>
          <Card className="text-center p-6 bg-purple-400">
            <CardContent>
              <span className="text-2xl">🧘</span>
              <p className="mt-2">Meditation</p>
            </CardContent>
          </Card>
          <Card className="text-center p-6 bg-purple-200">
            <CardContent>
              <p className="font-semibold">Motivational Quotes</p>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default HomeScreen;
