import React, { useEffect, useState } from 'react';
import SideBar from './Components/Sidebar';
import Page from './Components/Page';



function App(props) {
  const [currentPage, setPage] = useState(props.pages[Object.keys(props.pages)[0]].path);
  function changePage(newPage)
  {
    const title = props.pages[newPage].name
    const type = props.pages[newPage].class
    if(type === "category")
    {
      return;
    }

    document.title = "SF Reference: "+title
    setPage(newPage);
  }

  return (
    <div className="app">
      <SideBar items = {props.sidebarItems} changePage = {changePage} currentPage = {currentPage} />
      <Page {...props.pages[currentPage]} changePage = {changePage} />
    </div>
  );
}

export default App;
