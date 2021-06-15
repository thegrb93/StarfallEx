import React from 'react';
import SideBar from './Components/Sidebar';
import Page from './Components/Page';
import { HashRouter, useRouteMatch } from 'react-router-dom';


function AppBody(props)
{
  const routeMatch = useRouteMatch("/:page");
  let currentPagePath = "contributors";

  if(routeMatch !== null && routeMatch.params !== undefined && routeMatch.params.page !== undefined)
  {
    currentPagePath = routeMatch.params.page.toLowerCase();
  }

  const currentPage = props.pages[currentPagePath];

  return (
    <React.Fragment>
      <SideBar items = {props.sidebarItems} currentPage = {currentPagePath} />
      <div className="page-container">
        <Page {...currentPage}/>
      </div>
    </React.Fragment>
  );
}


function App(props) {
  return (
    <div className="app">
      <HashRouter hashType="noslash">
        <AppBody {...props} />
      </HashRouter>
    </div>
  );
}

export default App;
