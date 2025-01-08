import React, { Component } from 'react';
import architecture from '../../assets/3TierArch.png';

class Home extends Component {
  render() {
    return (
      <div>
        <h1 style={{ color: "white" }}>AWS 3-TIER DEMO by Uzair Gabol</h1>
        <img 
          src={architecture} 
          alt="3T Web App Architecture" 
          style={{ height: "auto", width: "100%", maxWidth: 825 }} 
        />
      </div>
    );
  }
}

export default Home;
