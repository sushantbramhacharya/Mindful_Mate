import React from 'react';

export const Button = ({ children, className, onClick, variant = 'default' }) => {
  return (
    <button
      onClick={onClick}
      className={`px-4 py-2 rounded ${variant === 'ghost' ? 'bg-transparent' : 'bg-purple-600 text-white'} ${className}`}
    >
      {children}
    </button>
  );
};
