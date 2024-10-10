import { AuthContextProps, useAuth } from 'react-oidc-context';

import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import CircularProgress from '@mui/material/CircularProgress';
import IconButton from '@mui/material/IconButton';
import LogoutIcon from '@mui/icons-material/Logout';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';

function AuthenticatedItems({ auth } : { auth: AuthContextProps }) {
  return (
    <>
      <Typography>
        {auth.user?.profile.name}
      </Typography>
      <IconButton color="inherit" onClick={() => auth.removeUser()}>
        <LogoutIcon />
      </IconButton>
    </>
  );
}

function AuthDispatch() {
  const auth = useAuth();

  const active = auth.activeNavigator;
  if (auth.isLoading || active === 'signinSilent' || active === 'signoutRedirect') {
    return <CircularProgress />;
  }

  if (auth.error) {
    return 'Error';
  }

  if (auth.isAuthenticated) {
    return <AuthenticatedItems auth={auth} />
  }

  return '';
}

export default function ButtonAppBar() {
  return (
    <Box sx={{ flexGrow: 1, mb: 2 }}>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Pipeline creation assistant
          </Typography>
          <AuthDispatch />
        </Toolbar>
      </AppBar>
    </Box>
  );
}
