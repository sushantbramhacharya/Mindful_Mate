import React from 'react';

export const Card = ({ children, className }) => (
  <div className={`rounded-xl shadow-md ${className}`}>{children}</div>
);

export const CardContent = ({ children }) => (
  <div className="p-4">{children}</div>
);
