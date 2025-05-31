import React from 'react';
import '../styles/Download.css';

const Download: React.FC = () => {
  return (
    <section id="download" className="download-section">
      <div className="download-container">
        <h2 className="download-title">Download OriginScan</h2>
        <p className="download-description">Available now on the App Store</p>
        <a 
          href="https://apps.apple.com/us/app/scorpio-player-2025/id1617922279?platform=iphone" 
          target="_blank" 
          rel="noopener noreferrer" 
          className="app-store-button"
        >
          <img 
            src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" 
            alt="Download on the App Store" 
            className="app-store-badge"
          />
        </a>
      </div>
    </section>
  );
};

export default Download; 