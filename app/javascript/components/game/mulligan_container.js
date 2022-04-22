import { useEffect, useRef } from 'react';

import html from '../htm_create_element';
import Mulligan from './mulligan';

export default function MulliganContainer(props) {
  const { gameData } = props;
  const { animationData } = props;

  useEffect(() => {
    console.log(friendlyCardInMulliganReference.current)
    if (animationData) { animateGamestate(animationData); }
  });

  // References for cards in the first-person player's hand
  const playerCardsInMulliganIds = gameData.player.cards.in_hand.map((c) => c.id);
  const friendlyCardInMulliganReference = useRef(playerCardsInMulliganIds.reduce((obj, id) => (obj[id] = undefined, obj), {}));

  // References for cards in the opponent player's hand
  const opponentCardsInHandIds = gameData.opponent.cards.in_hand.map((c) => c.id);
  const opponentCardInHandReference = useRef(opponentCardsInHandIds.reduce((obj, id) => (obj[id] = undefined, obj), {}));

  const thisGameReference = useRef({})

  // Object container to hold references together and forward them to children
  const gameReferences = useRef({ friendlyCardInMulliganReference, opponentCardInHandReference, thisGameReference });

  // REMINDER: OPPONENT CARD IN HAND REFERENCES
  const searchForElementInRefs = (id) => {
    const listOfAllReferences = [friendlyCardInMulliganReference.current, opponentCardInHandReference.current, thisGameReference.current];

    for (let i = 0; i < listOfAllReferences.length; i++) {
      if (listOfAllReferences[i][id]) return listOfAllReferences[i][id];
    }
  };

  // Animate the gamestate by assigning recieved dataset attributes to the elements referenced by the incoming JSON id list.
  const animateGamestate = (animationData) => {
    Object.entries(animationData.targets).forEach(([, values]) => {
      const targetElement = searchForElementInRefs(values.id);
      if (targetElement) (function applyAnimationTagToTarget(targetElement) { Object.keys(values.dataset).forEach((key) => { targetElement.dataset[key] = values.dataset[key]; }); }(targetElement));
    });
  };

  return html`<${Mulligan} gameData=${gameData} ref=${gameReferences} key=${gameData.id} />`;
};
