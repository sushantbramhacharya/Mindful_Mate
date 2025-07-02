import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import MusicManager from './screens/MusicManagerScreen'
import ExerciseManager from './screens/ExerciseManagerScreen'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
    {/* <MusicManager/> */}
      <ExerciseManager/>
    </>
  )
}

export default App
