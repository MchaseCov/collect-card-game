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

  // References for cards in the opponent player's hand
  const opponentCardsInHandIds = gameData.opponent.cards.in_hand.map((c) => c.id);
  const opponentCardInHandReference = useRef(opponentCardsInHandIds.reduce((obj, id) => (obj[id] = undefined, obj), {}));

  // References for cards in the battlefield from both players perspective
  const cardsInBattle = gameData.opponent.cards.in_battlefield.concat(gameData.player.cards.in_battlefield).map((c) => c.id);
  const cardInBattleReference = useRef(cardsInBattle.reduce((obj, id) => (obj[id] = undefined, obj), {}));

  // Object container to hold references together and forward them to children
  const gameReferences = useRef({ cardInBattleReference, friendlyCardInHandReference, opponentCardInHandReference });

  // REMINDER: OPPONENT CARD IN HAND REFERENCES
  const searchForElementInRefs = (id) => {
    const listOfAllReferences = [cardInBattleReference.current, friendlyCardInHandReference.current, opponentCardInHandReference.current];

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

  return html`<${Game} gameData=${gameData} ref=${gameReferences} key=${gameData.id}/>`;
}
