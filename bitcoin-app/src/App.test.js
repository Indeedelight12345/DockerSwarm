import { render, screen } from '@testing-library/react';
import React from 'react';
import App from './App';

test('renders React app', () => {
  render(<App />);
  expect(screen.getByText(/bitcoin/i)).toBeInTheDocument();
});
