import { createRoot } from 'react-dom/client';

import FriendlyPlayerHand from './fp_hand';
import PlayerPortrait from '../../components/player_portrait';

const fpInfoContainer = document.getElementById('fp-info');
const root = createRoot(fpInfoContainer);
const playerClasslist = 'absolute left-0 right-0 w-40 h-48 mx-auto bg-blue-200 rounded-t-full top-0';

export default function createFriendlyPlayerInfo(data) {
  const playerInfo = [PlayerPortrait(data.player_data, 'fp', playerClasslist), FriendlyPlayerHand(data.cards.in_hand)];
  root.render(playerInfo);
}
