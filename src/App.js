import React from 'react';
import SideBar from './Components/Sidebar';
import Page from './Components/Page';

function App(props) {
  return (
    <div className="app">
      <SideBar items = {props.sidebarItems} />
      <Page />
    </div>
  );
}

export default App;
