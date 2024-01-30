import React from 'react';
import ReactDOM from 'react-dom/client';
// import { BrowserRouter, Route, Routes } from "react-router-dom";
// import Empty from "./Empty";
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>

// --------------------------------------------------------------------------------------------------------

  // <>
  //   <BrowserRouter>
  //     <Routes>
  //       <Route element={<App />}>
  //         <Route path="/" element={<Empty />} />
  //         <Route path="/notes" element={<Empty />} />
  //         <Route
  //           path="/notes/:noteId/edit"
  //           element={<WriteBox edit={true} />}
  //         />
  //         <Route path="/notes/:noteId" element={<WriteBox edit={false} />} />
  //         {/* any other path */}
  //         <Route path="*" element={<Empty />} />
  //       </Route>
  //     </Routes>
  //   </BrowserRouter>
  // </>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
