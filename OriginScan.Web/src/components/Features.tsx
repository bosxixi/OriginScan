import React from 'react';
import '../styles/Features.css';

const Features: React.FC = () => {
  const features = [
    {
      icon: 'barcode',
      title: 'Instant Scanning',
      description: 'Quickly scan any product barcode with our advanced camera technology'
    },
    {
      icon: 'globe',
      title: 'Country Origin',
      description: 'Instantly discover the country of origin for any product'
    },
    {
      icon: 'language',
      title: 'Multi-language',
      description: 'Supports multiple languages for a global user experience'
    },
    {
      icon: 'bolt',
      title: 'Fast & Accurate',
      description: 'Lightning-fast results with high accuracy'
    }
  ];

  return (
    <section id="features" className="features">
      <h2>Key Features</h2>
      <div className="feature-grid">
        {features.map((feature, index) => (
          <div key={index} className="feature-card">
            <i className={`fas fa-${feature.icon}`}></i>
            <h3>{feature.title}</h3>
            <p>{feature.description}</p>
          </div>
        ))}
      </div>
    </section>
  );
};

export default Features; 