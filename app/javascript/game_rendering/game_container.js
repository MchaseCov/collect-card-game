import { useEffect, useRef } from 'react';

import html from 'components/htm_create_element';
import Game from './game';

export default function GameContainer(props) {
  const { gameData } = props;
  const { animationData } = props;

  useEffect(() => {
    if (animationData) { animateGamestate(animationData); }
  });

  // References for cards in the first-person player's hand
  const playerCardsInHandIds = gameData.player.cards.in_hand.map((c) => c.id);
  const friendlyCardInHandReference = useRef(playerCardsInHandIds.reduce((obj, id) => (obj[id] = undefined, obj), {}));

  // References for cards in the battlefield from both players perspective
  const cardsInBattle = gameData.player.cards.in_battlefield.concat(gameData.opponent.cards.in_battlefield).map((c) => c.id);
  const cardInBattleReference = useRef(cardsInBattle.reduce((obj, id) => (obj[id] = undefined, obj), {}));

  // Object container to hold references together and forward them to children
  const gameReferences = useRef({ cardInBattleReference, friendlyCardInHandReference });

  // Animate the gamestate by assigning recieved dataset attributes to the elements referenced by the incoming JSON id list.
  const animateGamestate = (animationData) => {
    const listOfAllReferences = Object.assign({}, ...Object.values(gameReferences.current).map((o) => o.current));
    Object.entries(animationData.targets).forEach(([, values]) => {
      const targetElement = listOfAllReferences[values.id];
      (function applyAnimationTagToTarget(targetElement) { targetElement.dataset.animationsTarget = values.animationTag; }(targetElement));
    });
  };

  return html`<${Game} gameData=${gameData} ref=${gameReferences}/>`;
}
