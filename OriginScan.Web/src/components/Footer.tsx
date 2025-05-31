import React from 'react';
import { Link } from 'react-router-dom';
import '../styles/Footer.css';

const Footer: React.FC = () => {
  return (
    <footer>
      <div className="footer-content">
        <div className="footer-section">
          <h4>OriginScan</h4>
          <p>Making product origins transparent</p>
        </div>
        <div className="footer-section">
          <h4>Links</h4>
          <Link to="/#features">Features</Link>
          <Link to="/#how-it-works">How It Works</Link>
          <Link to="/#download">Download</Link>
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