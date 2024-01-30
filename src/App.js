import React, { useState } from 'react';
import Empty from "./Empty";
import NewObituary from './NewObituary';

function App() { 
  // const addObituary = () => {

  // };

  const [isToggled, setIsToggled] = useState(false);

  const toggle = () => {
    setIsToggled(!isToggled);
  };
  


  return (
    <div id="container">

      <header>
        <span id="title">The Last Show</span>
        <button onClick={toggle} className="new-obituary-button">+ New Obituary</button>
      </header>

      <div id="main-container">
        {/* when new obiturary is added, the empty component should disappear */}
        {/* if isToggled is true, call the newObituary component */}
        { isToggled && <NewObituary toggleFunc={toggle}/> }

      <Empty/>
      </div>
    </div>
  );
}

export default App;