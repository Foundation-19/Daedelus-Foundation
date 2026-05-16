import { Box } from '../../components';
import { Window } from '../../layouts';

export function LoadoutUI() {
  return (
    <Window title="Loadout Manager" width={600} height={300}>
      <Window.Content>
        <Box mb={1}>Loadout manager initialized (static).</Box>
      </Window.Content>
    </Window>
  );
}

export default LoadoutUI;
