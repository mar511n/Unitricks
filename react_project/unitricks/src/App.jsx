import { useState } from 'react'
import Tricks from './Tricks'
import Playlists from './Playlists'
import Users from './Users'
import './App.css'

function App() {
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [activePage, setActivePage] = useState('home')

  const toggleDrawer = () => {
    setDrawerOpen(!drawerOpen)
  }

  const handleMenuSelect = (page) => {
    setActivePage(page)
    setDrawerOpen(false) // Optionally close the drawer after selection
  }

  // Helper to get the page title
  const getPageTitle = () => {
    switch(activePage) {
      case 'tricks': return 'Tricks'
      case 'playlists': return 'Playlists'
      case 'users': return 'Users'
      default: return 'Home'
    }
  }

  return (
    <div className="app-container">
      <div className={`drawer ${drawerOpen ? 'open' : ''}`}>
        <button className="close-btn" onClick={toggleDrawer}>
          <span className="material-icons">close</span>
        </button>
        <ul className="menu-list">
          <li onClick={() => handleMenuSelect('home')}>Home</li>
          <li onClick={() => handleMenuSelect('tricks')}>Tricks</li>
          <li onClick={() => handleMenuSelect('playlists')}>Playlists</li>
          <li onClick={() => handleMenuSelect('users')}>Users</li>
        </ul>
      </div>

      <div className="content">
        {/* App bar */}
        <header className="app-bar">
          <button className="menu-icon" onClick={toggleDrawer}>
            <span className="material-icons">menu</span>
          </button>
          <h2>{getPageTitle()}</h2>
        </header>

        <main>
          {activePage === 'home' && <h1>Welcome to our website!</h1>}
          {activePage === 'tricks' && <Tricks />}
          {activePage === 'playlists' && <Playlists />}
          {activePage === 'users' && <Users />}
        </main>
      </div>
    </div>
  )
}

export default App
