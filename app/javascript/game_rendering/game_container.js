import { useRef } from 'react';

import html from 'components/htm_create_element';
import Game from './game';

export default function GameContainer(props) {
  const { gameData } = props;
  const { animationData } = props;
  const cardsInBattle = gameData.player.cards.in_battlefield.concat(gameData.opponent.cards.in_battlefield).map((c) => c.id);
  const cardInBattleReference = useRef(cardsInBattle.reduce((obj, id) => (obj[id] = undefined, obj), {}));

  const animateGamestate = (animationData) => {
    Object.entries(animationData.targets).forEach(([, values]) => {
      const targetElement = cardInBattleReference.current[values.id];
      (function applyAnimationTagToTarget (targetElement) {targetElement.dataset.animationsTarget = values.animationTag})(targetElement)
    });
  };
  if (animationData) animateGamestate(animationData);
  return html`<${Game} gameData=${gameData} ref=${cardInBattleReference}/>`;
}
