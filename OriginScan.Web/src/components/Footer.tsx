import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../styles/Footer.css';

const Footer: React.FC = () => {
  const navigate = useNavigate();

  const handleNavClick = (e: React.MouseEvent<HTMLAnchorElement>, id: string) => {
    e.preventDefault();
    const el = document.getElementById(id);
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' });
    } else {
      navigate('/');
      setTimeout(() => {
        const el = document.getElementById(id);
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      }, 100);
    }
  };

  return (
    <footer>
      <div className="footer-content">
        <div className="footer-section">
          <h4>OriginScan</h4>
          <p>Making product origins transparent</p>
        </div>
        <div className="footer-section">
          <h4>Links</h4>
          <a href="#features" onClick={e => handleNavClick(e, 'features')}>Features</a>
          <a href="#how-it-works" onClick={e => handleNavClick(e, 'how-it-works')}>How It Works</a>
          <a href="#download" onClick={e => handleNavClick(e, 'download')}>Download</a>
          <Link to="/privacy">Privacy Policy</Link>
        </div>
        <div className="footer-section">
          <h4>Contact</h4>
          <a href="mailto:support@scorpioplayer.com">support@scorpioplayer.com</a>
        </div>
      </div>
      <div className="footer-bottom">
        <p>&copy; 2024 OriginScan. All rights reserved.</p>
      </div>
    </footer>
  );
};

export default Footer; 