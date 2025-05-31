import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../styles/Hero.css';
import lightPortrait from '../images/light-portrait.png';
import darkPortrait from '../images/dark-portrait.png';

const Hero: React.FC = () => {
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
    <section className="hero">
      <div className="hero-content">
        <h1>Discover Product Origins Instantly</h1>
        <p>Scan any barcode to instantly know where your products come from. Make informed purchasing decisions with OriginScan.</p>
        <div className="cta-buttons">
          <a href="#download" className="cta-primary" onClick={e => handleNavClick(e, 'download')}>Download Now</a>
          <a href="#how-it-works" className="cta-secondary" onClick={e => handleNavClick(e, 'how-it-works')}>Learn More</a>
        </div>
      </div>
      <div className="hero-image">
        <img src={lightPortrait} alt="OriginScan App Preview (Light Mode)" className="light-mode" />
        <img src={darkPortrait} alt="OriginScan App Preview (Dark Mode)" className="dark-mode" />
      </div>
    </section>
  );
};

export default Hero; 