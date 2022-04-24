import html from '../htm_create_element';

import CardInBattle from '../../components/cards/card_in_battle';
import CreateBlankSpace from './blank_space';

import { forwardRef } from 'react';

const createBattlefieldRow = forwardRef((props, ref) => {
  const cards = props.cards
  const playerSpecificData = props.playerSpecificData
  return html`<div id="${playerSpecificData.identifier}-cards-battle" className="flex flex-row items-center justify-center flex-auto w-full h-full border border-black border-t-1">
                <${CreateBlankSpace} position=0 key=0 playerSpecificData=${playerSpecificData.boardSpaceData}/>
                ${cards.map((card) => html`<${CardInBattle}id=${card.id}
                                                            key=${card.id}
                                                            cardConstant=${card.cardConstant}
                                                            health=${card.health}
                                                            attack=${card.attack}
                                                            health_cap=${card.health_cap}
                                                            status=${card.status}
                                                            dataset=${playerSpecificData.cardDataset(card)}
                                                            additionalClasses=${playerSpecificData.cardClasses}
                                                            firstPerson=${playerSpecificData.firstPerson}
                                                            keywords=${card.keywords}
                                                            cost=${card.cost}
                                                            ref=${ref}
                                                            type=${card.type}
                                            />
                                            <${CreateBlankSpace} position=${card.position}
                                                                  key=${[card.id, card.position]}
                                                                  playerSpecificData=${playerSpecificData.boardSpaceData}

                                            />`)}
               </div>`;
})

export default createBattlefieldRow
