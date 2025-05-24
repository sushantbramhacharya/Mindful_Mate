import { useState } from "react";
import SplashScreen from "./screens/SplashScreen";
import LoginScreen from "./screens/LoginScreen";

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
     <LoginScreen/>
    </>
  );
}

export default App;
