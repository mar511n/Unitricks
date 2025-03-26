import { useState, useEffect } from 'react';
import { CallBackendFunc } from './backend';
import './App';
import './Tricks.css';

function Tricks(props) {
  const [trickList, setTrickList] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    const getTricks = async () => {
      const response = await CallBackendFunc(
        props.databaseWebsite,
        props.username,
        props.password,
        'GetTrickListForUser',
        [props.username]
      );
      console.log('response:', response.status, response.data);
      setTrickList(response.data);
    };
    if (props.username && props.password) {
      getTricks();
    }
  }, [props.loginStatus]);

  const filteredTricks = trickList.filter((trick) =>
    trick.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className='tricks-container'>
      <div className='search-bar'>
        <input
          type="text"
          placeholder="Search..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className='search-input'
        />
      </div>
      <div className='tricks-table-container'>
      <table className="tricks-table" >
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Liked</th>
            <th>Wishlisted</th>
            <th>Landed</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {filteredTricks.map((trick) => (
            <tr key={trick.g_id} className="trick-row">
              <td>{trick.g_id}</td>
              <td>{trick.name}</td>
              <td>{trick.liked ? 'Yes' : 'No'}</td>
              <td>{trick.wishlisted ? 'Yes' : 'No'}</td>
              <td>{trick.landed ? 'Yes' : 'No'}</td>
              <td>{trick.landed_on}</td>
            </tr>
          ))}
        </tbody>
      </table>
      </div>
    </div>
  );
}

export default Tricks;