import html from '../../components/htm_create_element';

import CardInBattle from '../../components/cards/card_in_battle';
import CreateBlankSpace from './blank_space';

export default function createBattlefieldRow(cards, playerSpecificData) {
  const cardRow = cards.map((card) => [CardInBattle(card, playerSpecificData.cardDataset(card), playerSpecificData.cardClasses), CreateBlankSpace(card, playerSpecificData.boardSpaceData)]);
  return html`<div id="${playerSpecificData.identifier}-cards-battle" class="flex flex-row items-center justify-center w-full">
    ${CreateBlankSpace({ position: 0 }, playerSpecificData.boardSpaceData)}
    ${cardRow}
    </div>  
    `;
}
