import { forwardRef } from 'react';
import html from '../../htm_create_element';
import StandardCard from '../../cards/standard_card';

const Deck = forwardRef((props, ref) => {

  const cardFromDeck = (() => {
    if (props.cardFromDeck) {
      const card = props.cardFromDeck;
      return html`<${StandardCard} 
      ref=${ref}
      id=${card.id}
      cardConstant=${card.cardConstant}
      health=${card.health}
      attack=${card.attack}
      health_cap=${card.health_cap}
      additionalClasses="hidden"
      keywords=${card.keywords}
      cost=${card.cost}
      type=${card.type}
      key=${card.id}
     />`;
    }
  });

  if (props.cardsInDeck <= 0) {
    return html`
  <div className="deck has-tooltip" >
  <div className="top-0 bottom-0 px-3 py-1 mx-auto my-auto text-center bg-white -left-60 tooltip w-60 h-max rounded-xl">
      No cards remaining! Instead of drawing a card, the player of this deck will take damage equal to half of their current health!!
  </div>
  <div className="deck-bottom deck-empty" ></div>
  ${cardFromDeck()}
  </div>
`;
  }
  const deckMaxHeight = 70;
  const deckProportionalHeight = (props.cardsInDeck / 30);
  let deckHeight = Math.round(deckMaxHeight * deckProportionalHeight);
  if (deckHeight % 2 != 0) deckHeight = 2 * Math.round(deckHeight / 2);
  const halfHeight = Math.round(deckHeight / 2);

  const deckFrontStyle = {
    height: `${deckHeight}px`,
    width: '180px',
    bottom: '0px',
    transform: `rotateX( 90deg) translateZ(-${halfHeight}px)`,
  };

  const deckLeftStyle = {
    height: '250px',
    width: `${deckHeight}px`,
    transform: `rotateY( 90deg) translateZ(-${halfHeight}px)`,
  };

  const deckTopStyle = {
    height: '250px',
    width: '180px',
    transform: `rotateY(0deg) translateZ(${halfHeight}px)`,
  };



  return html`
  <div className="deck has-tooltip" >
    <div className="top-0 bottom-0 px-3 py-1 mx-auto my-auto text-center bg-white -left-60 tooltip w-max h-max rounded-xl">
      Cards remaining in deck: ${props.cardsInDeck}
    </div>
    <div className="deck-face deck-front" style=${deckFrontStyle}  ></div>
    <div className="deck-face deck-left"  style=${deckLeftStyle}  ></div>
    <div className="deck-face deck-top"   style=${deckTopStyle}  ></div>
    <div className="deck-face deck-bottom" ></div>
    ${cardFromDeck()}
  </div>
  `;
});

export default Deck;
