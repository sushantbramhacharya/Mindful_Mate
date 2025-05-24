import React from 'react';

const ChatScreen = () => {
  const messages = [
    { from: 'bot', text: 'Hello?' },
    { from: 'user', text: 'Hi, How are you?' },
    { from: 'bot', text: 'I am doing great. How are you feeling today?' },
    { from: 'user', text: '..........' },
  ];

  return (
    <div className="min-h-screen w-screen bg-purple-100 flex flex-col p-4">
      {/* Header */}
      <div className="flex items-center justify-between bg-purple-400 p-4 rounded-full shadow-md mb-4">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-gray-300 rounded-full flex items-center justify-center">🧠</div>
          <h2 className="text-white text-lg font-semibold">Mindful Mate</h2>
        </div>
        <div className="w-8 h-8 bg-purple-200 rounded-full flex items-center justify-center">✔️</div>
      </div>

      {/* Messages */}
      <div className="flex flex-col space-y-4 flex-1 overflow-y-auto px-2">
        {messages.map((msg, i) => (
          <div
            key={i}
            className={`max-w-[70%] px-4 py-2 rounded-2xl shadow-md ${
              msg.from === 'bot'
                ? 'bg-purple-400 text-white self-start rounded-tl-none'
                : 'bg-purple-300 text-white self-end rounded-tr-none'
            }`}
          >
            {msg.text}
          </div>
        ))}
      </div>

      {/* Input Box */}
      <div className="mt-4 flex items-center bg-purple-400 rounded-full px-4 py-2 shadow-md">
        <span className="text-white text-xl mr-3">＋</span>
        <span className="text-white text-xl mr-3">⟳</span>
        <input
          className="flex-1 bg-transparent outline-none text-white placeholder-white px-2"
          placeholder="How are you feeling today?"
        />
        <button className="bg-purple-600 text-white rounded-full p-2 ml-2">
          ⬆️
        </button>
      </div>
    </div>
  );
};

export default ChatScreen;
