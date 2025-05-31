import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../styles/Header.css';
import logo from '../images/logo.png';

const Header: React.FC = () => {
  const navigate = useNavigate();

  const handleNavClick = (e: React.MouseEvent<HTMLAnchorElement>, id: string) => {
    e.preventDefault();
    const el = document.getElementById(id);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    } else {
      // If not on home page, navigate home first, then scroll after render
      navigate('/');
      setTimeout(() => {
        const el = document.getElementById(id);
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      }, 100);
    }
  };

  return (
    <header className="header">
      <div className="header-content">
        <Link to="/" className="logo">
          <img src={logo} alt="OriginScan Logo" />
          <span>OriginScan</span>
        </Link>
        <nav className="nav-links">
          <a href="#features" onClick={e => handleNavClick(e, 'features')}>Features</a>
          <a href="#how-it-works" onClick={e => handleNavClick(e, 'how-it-works')}>How It Works</a>
          <a href="#download" onClick={e => handleNavClick(e, 'download')}>Download</a>
          <Link to="/privacy">Privacy</Link>
        </nav>
      </div>
    </header>
  );
};

export default Header; 