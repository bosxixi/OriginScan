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
      <h2>How It Works</h2>
      <div className="steps">
        {steps.map((step, index) => (
          <div key={index} className="step">
            <div className="step-number">{step.number}</div>
            <h3>{step.title}</h3>
            <p>{step.description}</p>
          </div>
        ))}
      </div>
    </section>
  );
};

export default HowItWorks; 