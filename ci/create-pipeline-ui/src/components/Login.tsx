import Alert from "@mui/material/Alert";
import Button from "@mui/material/Button";
import CircularProgress from "@mui/material/CircularProgress";
import Container from "@mui/material/Container";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useAuth } from "react-oidc-context";

function Splash() {
  const auth = useAuth();
  return (
    <>
      {auth.error && (
        <Alert variant="filled" severity="error" sx={{ mt: 2 }}>
          Could not log in, this is the error message: {auth.error.message}.
        </Alert>
      )}
      <Typography>
        The pipeline creation assistant needs a gitlab user to properly work, please sign in.
      </Typography>
      <Button
        onClick={() => auth.signinRedirect()}
        variant="outlined"
      >
        Sign in with gitlab
      </Button>
    </>
  );
}

export default function Login() {
  const auth = useAuth();

  const active = auth.activeNavigator;
  const showProgress =
    auth.isLoading || active === 'signinSilent' || active === 'signinRedirect';

  return (
    <Container>
      <Stack direction="column" sx={{ mt:2 }} spacing={2}>
        {showProgress ? (
          <CircularProgress />
        ) : (
          <Splash />
        )}
      </Stack>
    </Container>
  );
}
