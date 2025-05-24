import { useState } from "react";
import SplashScreen from "./screens/SplashScreen";
import LoginScreen from "./screens/LoginScreen";
import HomeScreen from "./screens/HomeScreen";
import ChatScreen from "./screens/ChatScreen";
import LoginReminder from "./screens/LoginReminder";

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
     {/* <LoginScreen/> */}
     {/* <HomeScreen/> */}
     {/* <ChatScreen/> */}
     <LoginReminder/>
    </>
  );
}

export default App;
