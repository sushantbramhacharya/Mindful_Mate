import { useState } from "react";
import SplashScreen from "./screens/SplashScreen";
import LoginScreen from "./screens/LoginScreen";
import HomeScreen from "./screens/HomeScreen";

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
     {/* <LoginScreen/> */}
     <HomeScreen/>
    </>
  );
}

export default App;
