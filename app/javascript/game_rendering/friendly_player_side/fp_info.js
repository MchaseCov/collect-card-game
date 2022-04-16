import html from '../../components/htm_create_element';

import FriendlyPlayerHand from './fp_hand';
import PlayerPortrait from '../../components/player_portrait';

const playerClasslist = 'absolute left-0 right-0 w-40 h-48 mx-auto bg-blue-200 rounded-t-full top-0';

export default function createFriendlyPlayerInfo(data) {
  return html`
  <section id='fp-info' class="relative w-full h-1/3">
  ${PlayerPortrait(data.gameData.player_data, 'fp', playerClasslist)}
  ${FriendlyPlayerHand(data.gameData.cards.in_hand)}
  </section>
`;
}
