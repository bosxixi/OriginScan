import React from 'react';
import { Link } from 'react-router-dom';
import '../styles/Hero.css';
import lightPortrait from '../images/light-portrait.png';
import darkPortrait from '../images/dark-portrait.png';

const Hero: React.FC = () => {
  return (
    <section className="hero">
      <div className="hero-content">
        <h1>Discover Product Origins Instantly</h1>
        <p>Scan any barcode to instantly know where your products come from. Make informed purchasing decisions with OriginScan.</p>
        <div className="cta-buttons">
          <Link to="/#download" className="cta-primary">Download Now</Link>
          <Link to="/#how-it-works" className="cta-secondary">Learn More</Link>
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