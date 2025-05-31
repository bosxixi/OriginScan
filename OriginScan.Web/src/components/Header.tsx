import React from 'react';
import { Link } from 'react-router-dom';
import '../styles/Header.css';
import logo from '../images/logo.png';

const Header: React.FC = () => {
  return (
    <header className="header">
      <div className="header-content">
        <Link to="/" className="logo">
          <img src={logo} alt="OriginScan Logo" />
          <span>OriginScan</span>
        </Link>
        <nav className="nav-links">
          <Link to="/#features">Features</Link>
          <Link to="/#how-it-works">How It Works</Link>
          <Link to="/#download">Download</Link>
          <Link to="/privacy">Privacy</Link>
        </nav>
      </div>
    </header>
  );
};

export default Header; 