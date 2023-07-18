import React, { useState, useEffect, useContext } from "react";
import PropTypes from 'prop-types';
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Divider from '@mui/material/Divider';
import { useHistory, useLocation } from 'react-router-dom'
import IconButton from '@mui/material/IconButton';
import List from '@mui/material/List';
import { Container } from "@material-ui/core";
import MenuIcon from '@mui/icons-material/Menu';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Drawer from '@mui/material/Drawer';
import WalletConnectProvider from "@walletconnect/web3-provider";
import Web3Modal from "web3modal";
import CoinbaseWalletSDK from "@coinbase/wallet-sdk";
import Web3Context from '../../store/web3-context';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemText from '@mui/material/ListItemText';
import { ethers, providers } from 'ethers';
import {
  BrowserRouter as Router,
  NavLink
} from "react-router-dom";

const Logo = (props) => {
  const {size} = props; 
  return (
    <img src={process.env.PUBLIC_URL + '/logo.png'} alt="Logo" style={{ width: size, marginTop:"20px" }} />
  )
}
const drawerWidth = 180;
const navItems = ['Staking', 'Inme Run', 'Connect'];

function Navbar(props) {
  let location = useLocation();
  const [haveMetamask, setHaveMetamask] = useState(true);
  const [accountAddress, setAccountAddress] = useState(null);
  const [accountBalance, setAccountBalance] = useState('');
  const [isConnected, setIsConnected] = useState(false);
  const [path, setPath] = useState('stake');

  const [web3Modal, setWeb3Modal] = useState(null);
  const [address, setAddress] = useState("");
  const [provider, setProvider] = useState();
  const [library, setLibrary] = useState();
  const [mainChain, setMainChain] = useState(0); // chain type 1: ethereum 0: polygon
  const [chain, setChain] = useState(0);
  const web3Ctx = useContext(Web3Context);
  const { window } = props;

  useEffect(() => {
    // initiate web3modal
    const providerOptions = {
      walletconnect: {
        package: WalletConnectProvider,
        options: {
          infuraId: process.env.REACT_APP_INFURA_KEY,
        }
      },
      walletlink: {
        package: CoinbaseWalletSDK, // Required
        options: {
          appName: "Web 3 Modal Demo", // Required
          infuraId: process.env.REACT_APP_INFURA_KEY // Required unless you provide a JSON RPC url; see `rpc` below
        }
      },
    };


    const newWeb3Modal = new Web3Modal({
      cacheProvider: true, // very important
      network: "mainnet",
      providerOptions,
    });

    setWeb3Modal(newWeb3Modal)
  }, []);


  // const provider = new ethers.providers.Web3Provider(window.ethereum);


  const [mobileOpen, setMobileOpen] = React.useState(false);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const drawer = (
    <Box onClick={handleDrawerToggle} sx={{ textAlign: 'center', backgroundColor: '#0B184F', height: '100%' }}>

      <Logo size='150px'/>
      <Divider />
      <List>
        <ListItem disablePadding >
          <ListItemButton sx={{ textAlign: 'center' }}>
            <NavLink to={'/'} style={{ fontSize: 20 }} className={location?.pathname == '/' ? 'stake navlink' : 'navlink'}>
              {'Staking'}
            </NavLink>
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton sx={{ textAlign: 'center' }}>
            <NavLink to={'/'} style={{ fontSize: 20 }} className={location?.pathname != '/' ? 'reward navlink' : 'navlink'}>
              {'Inme Run'}
            </NavLink>
          </ListItemButton>
        </ListItem>
        <ListItem disablePadding>
          <ListItemButton sx={{ textAlign: 'center' }}>
            <Button className='connectBtn' onClick={connectWallet}>
              {accountAddress ? `${accountAddress.slice(0, 4)}...
                ${accountAddress.slice(38, 42)}` : 'Connect'}
            </Button>
          </ListItemButton>
        </ListItem>

      </List>

    </Box>
  );

  async function connectWallet() {

    // check metamask  
    // if (typeof window.ethereum == 'undefined') {
    //   if (window.confirm("Please install metamask")) {
    //     window.open("https://metamask.io/download.html", "_blank");
    //   }
    //   return;
    // }

    const provider = await web3Modal.connect();
    await web3Ctx.addProvider(provider);

    setAccountAddress(provider.selectedAddress);
    // const library = new ethers.providers.Web3Provider(provider);
    // addListeners(provider);
    // setProvider(provider);
    // setLibrary(library);
    // setChain(provider.chainId);
    // const ethersProvider = new providers.Web3Provider(provider);
    // const userAddress = await ethersProvider.getSigner().getAddress();
    // setAddress(userAddress);
    // checkChain();
  }

  async function addListeners(web3ModalProvider) {
    web3ModalProvider.on("accountsChanged", (accounts) => {
      setAddress(accounts[0]);
    });

    // Subscribe to chainId change
    web3ModalProvider.on("chainChanged", (chainId) => {
      setChain(chainId);
    });
  }

  const container = window !== undefined ? () => window().document.body : undefined;
  function checkChain() {
    // if (chains[mainChain].chainId != chain) {
    //   switchNetwork();
    //   return false;
    // } else {
    //   return true;
    // }
  }


  return (
    <Box sx={{ display: 'flex', marginBottom:{ xs: '5px', sm:'30px' } }}>
      <Container>
        <AppBar component="nav" className='navbar' style={{ background: 'transparent', boxShadow: 'none' }}>
          <Toolbar style={{ marginTop: '10px', marginBottom: '20px' }}>
            <IconButton
              color="inherit"
              aria-label="open drawer"
              edge="start"
              onClick={handleDrawerToggle}
              sx={{ mr: 2, display: { sm: 'none' } }}
            >
              <MenuIcon />
            </IconButton>
            <Typography
              variant="h6"
              component="div"
              sx={{ flexGrow: 1, display: { xs: 'none', sm: 'block' } }}
            >
              <Logo size='200px'/>
            </Typography>
            <Box sx={{ display: { xs: 'none', sm: 'block' } }}>

              <NavLink to={'/'} style={{ fontSize: 20 }} className={location?.pathname == '/' ? 'stake navlink' : 'navlink'}
              >
                {'Staking'}
              </NavLink>

              <NavLink to={'/'} style={{ fontSize: 20 }} className={location?.pathname != '/' ? 'reward navlink' : 'navlink'}>
                {'Inme Run'}
              </NavLink>

              <Button className='connectBtn' sx={{ color: '#fff', marginLeft: '30px' }} onClick={connectWallet}>
                {accountAddress ? `${accountAddress.slice(0, 4)}...
                ${accountAddress.slice(38, 42)}` : 'Connect'}
              </Button>
            </Box>
          </Toolbar>
        </AppBar>
        <Box component="nav" >
          <Drawer
            container={container}
            variant="temporary"
            open={mobileOpen}
            onClose={handleDrawerToggle}
            ModalProps={{
              keepMounted: true, // Better open performance on mobile.
            }}
            sx={{
              display: { xs: 'block', sm: 'none' },
              '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
            }}
          >
            {drawer}
          </Drawer>
        </Box>
      </Container>
    </Box>
  );
}

Navbar.propTypes = {

  /**
   * Injected by the documentation to work in an iframe.
   * You won't need it on your project.
   */
  window: PropTypes.func,
};

export default Navbar;

