import React, { useState } from 'react'

const LoginComponent = ({setLoginSwitch, loginSwitch }) => {
  return (
    <div className="bg-purple-300 bg-opacity-30 backdrop-blur-md p-8 rounded-2xl shadow-md w-80 md:w-96 text-center">
          <h2 className="text-xl font-semibold text-purple-900 mb-6">{loginSwitch?'Register':'Login'}</h2>

          {loginSwitch?<RegisterForm/>:<LoginForm/>}

          <div className="flex justify-between text-xs mt-4 ">
            <a href="#" className="!text-purple-900 hover:underline" onClick={(e) => {e.preventDefault();setLoginSwitch(!loginSwitch)}}>
              {loginSwitch?'Already Have an Account':'Create an Account'}
            </a>
            {loginSwitch?<></>:<a href="#" className="!text-purple-900 hover:underline">
              Forgot Password?
            </a>}
            
          </div>
        </div>
  )
}

const RegisterForm =()=>{
  return(
  <form className="flex flex-col space-y-4">
            <div>
              <label className="block text-left text-purple-900 font-medium mb-1">
                Email
              </label>
              <input
                type="email"
                className="w-full border-b border-purple-900 bg-transparent outline-none py-1 text-purple-900"
                placeholder="Enter your email"
              />
            </div>

            <div>
              <label className="block text-left text-purple-900 font-medium mb-1">
                Password
              </label>
              <input
                type="password"
                className="w-full border-b border-purple-900 bg-transparent outline-none py-1 text-purple-900"
                placeholder="Enter your password"
              />
            </div>

            <div>
              <label className="block text-left text-purple-900 font-medium mb-1">
                Confirm Password
              </label>
              <input
                type="password"
                className="w-full border-b border-purple-900 bg-transparent outline-none py-1 text-purple-900"
                placeholder="Enter your password"
              />
            </div>
            <button className="bg-gradient-to-r from-purple-500 to-purple-800 text-white px-6 py-2 rounded-full">
              Login
            </button>
          </form>)
}

const LoginForm =()=>{
  const [email,setEmail]=useState("");
  const [password,setPassword]=useState("");
  const RequestLogin=(e)=>{
    e.preventDefault()
    fetch("http://127.0.0.1:5000/api/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        email: email,
        password: password,
      })
    })
    .then(response => response.json())
    .then(data => console.log("Response:", data))
    .catch(error => console.error("Error:", error));
  }
  return(
  <form className="flex flex-col space-y-4">
            <div>
              <label className="block text-left text-purple-900 font-medium mb-1">
                Email
              </label>
              <input
              onChange={(e)=>setEmail(e.target.value)}
              value={email}
                type="email"
                className="w-full border-b border-purple-900 bg-transparent outline-none py-1 text-purple-900"
                placeholder="Enter your email"
              />
            </div>

            <div>
              <label className="block text-left text-purple-900 font-medium mb-1">
                Password
              </label>
              <input
              onChange={(e)=>setPassword(e.target.value)}
              value={password}
                type="password"
                className="w-full border-b border-purple-900 bg-transparent outline-none py-1 text-purple-900"
                placeholder="Enter your password"
              />
            </div>

            <button onClick={RequestLogin} className="bg-gradient-to-r from-purple-500 to-purple-800 text-white px-6 py-2 rounded-full">
              Login
            </button>
          </form>
  )
}

export default LoginComponent