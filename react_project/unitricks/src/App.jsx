import { useState, useEffect, useRef } from 'react'
import { ToastContainer, toast } from 'react-toastify';
import Cookies from 'universal-cookie';
import Tricks from './Tricks'
import Playlists from './Playlists'
import Users from './Users'
import MatIcon from './icon';
import './App.css'
import axios from "axios";

const baseWebsite = "https://marvin.henke-email.de";
const databaseWebsite = `${baseWebsite}/databaseAccess.php`;

function App() {
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [activePage, setActivePage] = useState('home')
  const [loginPopupOpen, setLoginPopupOpen] = useState(false)
  const [accountPopupOpen, setAccountPopupOpen] = useState(false)
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [loginStatus, setLoginStatus] = useState(false)
  const drawerRef = useRef(null)
  const cookies = new Cookies();

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
      case 'settings': return 'Settings'
      case 'help': return 'Help'
      default: return 'Home'
    }
  }

  const handleLogin = async (uname, passwd) => {
    // console.log(`Login attempt with Username: ${username}, Password: ${password}`);
    const id = toast('Logging in...', { autoClose: false, isLoading: true});
    try {
      const axiosInstance = axios.create({
        baseURL: databaseWebsite,
        method: 'get',
        auth: {
          username: uname,
          password: passwd
        },
        withCredentials: true
      });
      const response = await axiosInstance.request();
      console.log('server response:', response.data);
      setLoginStatus(response.data === 'Access granted');
      if (response.data === 'Access granted') {
        toast.update(id, { render: 'Login successful', type: 'success' , autoClose: 2000, isLoading: false}); 
        cookies.set('username', uname, { path: '/' });
        cookies.set('password', passwd, { path: '/' });
        setUsername(uname);
        setPassword(passwd);
      }else if(response.data === 'Access denied'){
        toast.update(id, { render: 'Wrong username or password', type: 'error' , autoClose: 2000, isLoading: false});
      }else{
        toast.update(id, { render: 'Login failed: ' + response.data, type: 'error' , autoClose: 2000, isLoading: false});
      }
    } catch(err) {
      console.error(err);
      toast.update(id, { render: 'Login failed: ' + err, type: 'error' , autoClose: 2000, isLoading: false});
    }
    setLoginPopupOpen(false);
  }

  useEffect(() => {
    const usernameCookie = cookies.get('username');
    const passwordCookie = cookies.get('password');
    if (usernameCookie && passwordCookie) {
      handleLogin(usernameCookie, passwordCookie);
    }
  }, [])

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (drawerOpen && drawerRef.current && !drawerRef.current.contains(event.target)) {
        setDrawerOpen(false)
      }
    }
    const handleEscape = (event) => {
      if (drawerOpen && event.key === 'Escape') {
        setDrawerOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClickOutside)
    document.addEventListener('keydown', handleEscape)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
      document.removeEventListener('keydown', handleEscape)
    }
  }, [drawerOpen])

  return (
    <div className="app-container">
      <ToastContainer
        position="bottom-right"
        autoClose={2000}
        hideProgressBar={false}
        newestOnTop={false}
        closeOnClick={true}
        rtl={false}
        pauseOnFocusLoss
        draggable
        pauseOnHover
        theme="dark"
        />

      <div ref={drawerRef} className={`drawer ${drawerOpen ? 'open' : ''}`}>
        <h2><button className="title-btn" onClick={toggleDrawer}> Unitricks </button></h2>
        <ul className="menu-list-top">
          <li onClick={() => handleMenuSelect('home')}>Home</li>
          <li onClick={() => handleMenuSelect('tricks')}>Tricks</li>
          <li onClick={() => handleMenuSelect('playlists')}>Playlists</li>
          <li onClick={() => handleMenuSelect('users')}>Users</li>
        </ul>
        <ul className="menu-list-bottom">
          <li onClick={() => handleMenuSelect('settings')}>Settings</li>
          <li onClick={() => handleMenuSelect('help')}>Help</li>
        </ul>
      </div>

      <div className="content">
        {/* App bar */}
        <header className="app-bar">
          <button className="menu-icon" onClick={toggleDrawer}>
            <MatIcon icon="menu" />
          </button>
          <h2>{getPageTitle()}</h2>
          <button className="account-icon" onClick={() => loginStatus ? setAccountPopupOpen(!accountPopupOpen):setLoginPopupOpen(true)}>
            <MatIcon icon={loginStatus ? "account_circle":"login"} />
          </button>
        </header>

        <main>
          {activePage === 'home' && <h1>Welcome to our website!</h1>}
          {activePage === 'tricks' && <Tricks />}
          {activePage === 'playlists' && <Playlists />}
          {activePage === 'users' && <Users />}
          {activePage === 'settings' && <h1>Settings Page</h1>}
          {activePage === 'help' && <h1>Help Page</h1>}
        </main>

        {loginPopupOpen && (
          <div className="login-modal">
            <div className="login-modal-content">
              <h2 className="login-header">Login</h2>
              <div className='login-inputs'>
                <input 
                  type="text" 
                  placeholder="Username" 
                  value={username} 
                  onChange={(e) => setUsername(e.target.value)} 
                />
                <input 
                  type="password" 
                  placeholder="Password" 
                  value={password} 
                  onChange={(e) => setPassword(e.target.value)} 
                />
              </div>
              <div className="login-buttons">
                <button onClick={() => setLoginPopupOpen(false)}><MatIcon icon="close"></MatIcon></button>
                <button type="submit" onClick={() => handleLogin(username, password)}><MatIcon icon="login"></MatIcon></button>
              </div>
            </div>
          </div>
        )}

        {accountPopupOpen && (
          <div className="account-modal-content">
            <h2 className="account-header">Account</h2>
            <span className='account-name'>{loginStatus ? "Logged in as " + username : ""}</span>
            <div className="account-buttons">
              <button onClick={() => setAccountPopupOpen(false)}><MatIcon icon="close"></MatIcon></button>
              <button onClick={() => {
                cookies.remove('username', { path: '/' });
                cookies.remove('password', { path: '/' });
                setLoginStatus(false);
                setUsername('');
                setPassword('');
                setAccountPopupOpen(false);
              }}><MatIcon icon="logout"></MatIcon></button>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

export default App
