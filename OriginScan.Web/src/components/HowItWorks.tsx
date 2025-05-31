import React from 'react';
import '../styles/HowItWorks.css';

const HowItWorks: React.FC = () => {
  const steps = [
    {
      number: 1,
      title: 'Open the App',
      description: 'Launch OriginScan on your iOS device'
    },
    {
      number: 2,
      title: 'Scan Barcode',
      description: 'Point your camera at any product barcode'
    },
    {
      number: 3,
      title: 'Get Results',
      description: 'Instantly see the country of origin'
    }
  ];

  return (
    <section id="how-it-works" className="how-it-works">
      <div className="how-it-works-container">
        <h2 className="how-it-works-title">How It Works</h2>
        <div className="steps-container">
          {steps.map((step, index) => (
            <div key={index} className="step">
              <div className="step-number">{step.number}</div>
              <h3 className="step-title">{step.title}</h3>
              <p className="step-description">{step.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default HowItWorks; 